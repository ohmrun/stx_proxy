package stx.proxy.core;

@:using(stx.proxy.core.Respond.RespondLift)
@:forward abstract Respond<A,B,M,N,Y,E>(ProxySum<A,B,M,N,Y,E>) from ProxySum<A,B,M,N,Y,E> to ProxySum<A,B,M,N,Y,E>{
  static public var _(default,never) = RespondLift;
  public function new(self){
    this = self;
  }
   //x' x a' a m a'
   @:noUsing static public function deferred<A,B,X,Y,E>(v:Future<Y>):Proxy<A,B,X,Y,X,E>{
    return Defer(Belay.fromFuture(() -> v.map(pure)));
  }
  //x' x a' a m a'
  @:noUsing static public function pure<A,B,X,Y,E>(v:Y):Proxy<A,B,X,Y,X,E>{
    return Yield(v,Val.fn().then(Ended));
  }
}
class RespondLift{
  
}