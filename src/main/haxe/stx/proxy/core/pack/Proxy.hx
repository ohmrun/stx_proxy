package stx.proxy.core.pack;

enum ProxySum<A,B,X,Y,R,E>{
  Await(v:A,arw:Unary<B,ProxyA<A,B,X,Y,R,E>>);
  Yield(v:Y,arw:Unary<X,ProxyA<A,B,X,Y,R,E>>);
  Later(ft:Void->Future<<ProxyA<A,B,X,Y,R,E>>>);
  Ended(res:Chunk<R,E>);
}

@:using(stx.proxy.core.pack.ProxyLift)
@:forward abstract Proxy<A,B,X,Y,R,E>(ProxySum<A,B,X,Y,R,E>) from ProxySum<A,B,X,Y,R,E> to ProxySum<A,B,X,Y,R,E>{
  static public var _(default,never) = ProxyLift;
  public function new(v) this = v;
  
  static public inline function lift<A,B,X,Y,R,E>(prx:ProxySum<A,B,X,Y,R,E>):Proxy<A,B,X,Y,R,E>{
    return new Proxy(prx);
  }
  @:noUsing static public function pull<A,B,X,Y,R,E>(a:A):Proxy<A,B,A,B,R,E>{
    return Pulls.pure(a);
  }
  @:noUsing static public function push<A,B,R,E>(b:B):Proxy<A,B,A,B,R,E>{
    return Pushes.pure(b);
  }
  @:noUsing static public function request<A,B,X,Y,R,E>(a:A):Proxy<A,B,X,Y,B,E>{
    return Requests.pure(a);
  }
  @:noUsing static public function respond<A,B,X,Y,E>(y:Y):Proxy<A,B,X,Y,X,E>{
    return Responds.pure(y);
  }
}
class ProxyLift{ 
  static public function flat_map<A,B,X,Y,R,O,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Arrowlet<R,Proxy<A,B,X,Y,O,E>>):Proxy<A,B,X,Y,O,E>{
    return switch (prx) {
      case Await(a,arw) : Await(a,arw.then(flat_map.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(flat_map.bind(_,fn)));
      case Ended(res)   : 
        //TODO
        res.fold(
          (r) -> Later(fn.receive(r)), 
          (e) -> Ended(End(e)),
          ()  -> Ended(Tap)
        );
      case Later(ft)    : Later(ft.map(pr -> flat_map(pr,fn)));
    }
  }
  static public function map<A,B,X,Y,R,O,E>(prx:Proxy<A,B,X,Y,R,E>,fn:R->O):Proxy<A,B,X,Y,O,E>{
    return switch (prx) {
      case Ended(res)   : Ended(res.map(fn));
      case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(map.bind(_,fn)));
      case Later(ft)    : Later(ft.map(map.bind(_,fn)));
    }

  }
  static public function reflect<A,B,X,Y,R,E>(prx:Proxy<A,B,X,Y,R,E>):Proxy<Y,X,B,A,R,E>{
    return switch(prx) {
      case Await(a,arw) : Yield(a,arw.then(reflect));
      case Yield(a,arw) : Await(a,arw.then(reflect));
      case Ended(r)     : Ended(r);
      case Later(prx)   : Later(prx.map(reflect));
    }
  }
}