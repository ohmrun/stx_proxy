package stx.proxy.core;

/**
 * Represents two intercommunicating Coroutines bundled together.
 */
enum ProxySum<A,B,X,Y,R,E>{
  /**
   * Upstream Coroutine.
   */
  Await(a:A,arw:Unary<B,Proxy<A,B,X,Y,R,E>>);
  /**
   * Downstream Coroutine.
   */
  Yield(y:Y,arw:Unary<X,Proxy<A,B,X,Y,R,E>>);
  /**
   * Indicates an unready resource
   */
  Defer(ft:Belay<A,B,X,Y,R,E>);
  /**
   * Completion with a value or an error.
   */
  Ended(res:Chunk<R,E>);
}

@:using(stx.proxy.core.Proxy.ProxyLift)
@:transitive
@:forward abstract Proxy<A,B,X,Y,R,E>(ProxySum<A,B,X,Y,R,E>) from ProxySum<A,B,X,Y,R,E> to ProxySum<A,B,X,Y,R,E>{

  static public var _(default,never) = ProxyLift;
  public function new(v) this = v;
  
  @:noUsing static public inline function lift<A,B,X,Y,R,E>(self:ProxySum<A,B,X,Y,R,E>):Proxy<A,B,X,Y,R,E>{
    return new Proxy(self);
  }
  @:noUsing static public function pull<A,B,X,Y,R,E>(a:A):Proxy<A,B,A,B,R,E>{
    return Pull.pure(a);
  }
  // @:noUsing static public function push<A,B,R,E>(b:B):Proxy<A,B,A,B,R,E>{
  //   return Push.pure(b);
  // }
  // @:noUsing static public function request<A,B,X,Y,R,E>(a:A):Proxy<A,B,X,Y,B,E>{
  //   return Requesting.pure(a);
  // }
  // @:noUsing static public function respond<A,B,X,Y,E>(y:Y):Proxy<A,B,X,Y,X,E>{
  //   return Respond.pure(y);
  // }
  public var error(get,never):Report<E>;
  public function get_error():Report<E>{
    return switch(this){
      case Ended(End(e)) if(e!=null)  : __.report(f -> e);
      default                         : __.report();
    }
  }
}
class ProxyLift{ 
  //static public function fold<A,B,X,Y,R,E,Z>(self:Proxy<A,B,X,Y,R,E,Z>,await:A->(B->Proxy<A,B,X>)
  // static public function mod<A,B,X,Y,R,Ri,E>():YCombinator<Proxy<A,B,X,Y,R,E>,Proxy<A,B,X,Y,Ri,E>>{
  //   return function rec(fn:YCombinator<Proxy<A,B,X,Y,R,E>,Proxy<A,B,X,Y,Ri,E>>){
  //     return function (self:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y,Ri,E>{
  //       function f(self:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y,Ri,E> return fn(rec)(self);
  //       return switch(self){
  //         case Await(a,arw)   : __.await(a,arw.then(f));
  //         case Yield(y,arw)   : __.yield(y,arw.then(f));
  //         case Defer(ft)      : __.belay(ft.mod(f));//careful
  //         case Ended(res)     : f(__.ended(res));//careful
  //       }
  //     }
  //   }
  // }
  static public function flat_map<A,B,X,Y,R,Ri,E>(self:ProxySum<A,B,X,Y,R,E>,fn:Unary<R,Proxy<A,B,X,Y,Ri,E>>):Proxy<A,B,X,Y,Ri,E>{
    var f = flat_map.bind(_,fn);
    return switch(self){
      case Await(a,arw) : Await(a,arw.then(f));
      case Yield(y,arw) : Yield(y,arw.then(f));
      case Defer(ft)    : Defer(ft.mod(f));
      case Ended(res)   : res.fold(
        fn,
        (e) -> Ended(End(e)),
        ()  -> Ended(Tap)
      );
    }
  }
  static public function map<A,B,X,Y,R,O,E>(self:ProxySum<A,B,X,Y,R,E>,fn:R->O):Proxy<A,B,X,Y,O,E>{
    return switch (self) {
      case Ended(res)   : Ended(res.map(fn));
      case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(map.bind(_,fn)));
      case Defer(ft)    : __.belay(ft.mod(map.bind(_,fn)));
    }
  }
  static public function errata<A,B,X,Y,R,E,EE>(self:ProxySum<A,B,X,Y,R,E>,fn:Refuse<E>->Refuse<EE>):Proxy<A,B,X,Y,R,EE>{
    return switch (self) {
      case Ended(res)   : Ended(res.errata(fn));
      case Await(a,arw) : Await(a,arw.then(errata.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(errata.bind(_,fn)));
      case Defer(ft)    : __.belay(ft.mod(errata.bind(_,fn)));
    }
  }
  static public function errate<A,B,X,Y,R,E,EE>(self:ProxySum<A,B,X,Y,R,E>,fn:E->EE):Proxy<A,B,X,Y,R,EE>{
    return errata(self,e -> e.errate(fn));
  }
  static public function reflect<A,B,X,Y,R,E>(self:ProxySum<A,B,X,Y,R,E>):Proxy<Y,X,B,A,R,E>{
    return switch(self) {
      case Await(a,arw) : Yield(a,arw.then(reflect));
      case Yield(a,arw) : Await(a,arw.then(reflect));
      case Ended(r)     : Ended(r);
      case Defer(self)   : __.belay(self.mod(reflect));
    }
  }
  static public function adjust<A,B,X,Y,R,Ri,E>(self:ProxySum<A,B,X,Y,R,E>,fn:R->Upshot<Ri,E>):Proxy<A,B,X,Y,Ri,E>{
    final f = adjust.bind(_,fn);
    return switch(self) {
      case Await(a,arw)       : __.await(a,arw.then(f));
      case Yield(a,arw)       : __.yield(a,arw.then(f));
      case Ended(Val(r))      : switch(fn(r)){
        case Accept(ok) : __.ended(Val(ok));
        case Reject(no) : __.ended(End(no));
      }
      case Ended(Tap)         : __.ended(Tap);
      case Ended(End(e))      : __.ended(End(e));
      case Defer(self)        : __.belay(self.mod(f));
    }
  }
}