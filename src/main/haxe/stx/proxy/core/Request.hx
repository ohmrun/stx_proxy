package stx.proxy.core;

@:using(stx.proxy.core.Request.RequestLift)
@:forward abstract Request<A,B,M,N,Y,E>(ProxySum<A,B,M,N,Y,E>) from ProxySum<A,B,M,N,Y,E> to ProxySum<A,B,M,N,Y,E>{
  static public var _(default,never) = RequestLift;
  public function new(self){
    this = self;
  }
  @:noUsing static public function pure<A,B,X,Y,R,E>(a:A):Proxy<A,B,X,Y,B,E>{
    return Await(a,Val.fn().then(Ended));
  }
  @:noUsing static public function deferred<A,B,X,Y,R,E>(a:Future<A>):Proxy<A,B,X,Y,B,E>{
    return __.belay(
      Belay.fromFuture(() -> a.map(Request.pure))
    );
  }
}
class RequestLift{
  @:noUsing static public function feed<A,Ai,B,Bi,X,Y,R,M,N,O,E>(prx0:Proxy<A,B,X,Y,R,E>,prx1:Unary<A,Proxy<Ai,Bi,X,Y,B,E>>):Proxy<Ai,Bi,X,Y,R,E>{
    return RequestCat._.next(prx1,prx0);
  }
}