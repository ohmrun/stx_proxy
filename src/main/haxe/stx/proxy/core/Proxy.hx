package stx.proxy.core;


enum ProxySum<A,B,X,Y,R,E>{
  Await(a:A,arw:Unary<B,Proxy<A,B,X,Y,R,E>>);
  Yield(y:Y,arw:Unary<X,Proxy<A,B,X,Y,R,E>>);
  Defer(ft:Belay<A,B,X,Y,R,E>);
  Ended(res:Chunk<R,E>);
}

@:using(stx.proxy.core.Proxy.ProxyLift)
@:forward abstract Proxy<A,B,X,Y,R,E>(ProxySum<A,B,X,Y,R,E>) from ProxySum<A,B,X,Y,R,E> to ProxySum<A,B,X,Y,R,E>{

  static public var _(default,never) = ProxyLift;
  public function new(v) this = v;
  
  @:noUsing static public inline function lift<A,B,X,Y,R,E>(prx:ProxySum<A,B,X,Y,R,E>):Proxy<A,B,X,Y,R,E>{
    return new Proxy(prx);
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
}
class ProxyLift{ 
  //static public function fold<A,B,X,Y,R,E,Z>(self:Proxy<A,B,X,Y,R,E,Z>,await:A->(B->Proxy<A,B,X>)
  // static public function mod<A,B,X,Y,R,Ri,E>():YCombinator<Proxy<A,B,X,Y,R,E>,Proxy<A,B,X,Y,Ri,E>>{
  //   return function rec(fn:YCombinator<Proxy<A,B,X,Y,R,E>,Proxy<A,B,X,Y,Ri,E>>){
  //     return function (prx:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y,Ri,E>{
  //       function f(prx:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y,Ri,E> return fn(rec)(prx);
  //       return switch(prx){
  //         case Await(a,arw)   : __.await(a,arw.then(f));
  //         case Yield(y,arw)   : __.yield(y,arw.then(f));
  //         case Defer(ft)      : __.belay(ft.mod(f));//careful
  //         case Ended(res)     : f(__.ended(res));//careful
  //       }
  //     }
  //   }
  // }
  static public function flat_map<A,B,X,Y,R,O,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Unary<R,Proxy<A,B,X,Y,O,E>>):Proxy<A,B,X,Y,O,E>{
    var f = flat_map.bind(_,fn);
    return switch(prx){
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
  static public function map<A,B,X,Y,R,O,E>(prx:Proxy<A,B,X,Y,R,E>,fn:R->O):Proxy<A,B,X,Y,O,E>{
    return switch (prx) {
      case Ended(res)   : Ended(res.map(fn));
      case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(map.bind(_,fn)));
      case Defer(ft)    : __.belay(ft.mod(map.bind(_,fn)));
    }

  }
  static public function reflect<A,B,X,Y,R,E>(prx:Proxy<A,B,X,Y,R,E>):Proxy<Y,X,B,A,R,E>{
    return switch(prx) {
      case Await(a,arw) : Yield(a,arw.then(reflect));
      case Yield(a,arw) : Await(a,arw.then(reflect));
      case Ended(r)     : Ended(r);
      case Defer(prx)   : __.belay(prx.mod(reflect));
    }
  }
}