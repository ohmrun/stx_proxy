package stx.proxy.core;

abstract Push<A,B,X,Y,R,E>(ProxySum<A,B,X,Y,R,E>) from ProxySum<A,B,X,Y,R,E> to ProxySum<A,B,X,Y,R,E>{
  static public var _(default,never) = PushLift;
  public function new(self) this = self;

  @:noUsing static public function pure<A,B,R,E>(b:B):Proxy<A,B,A,B,R,E>{
    return Yield(b,
      (a:A) -> Await(a,pure)
    );
  }
  @:noUsing static public function fromSignal<A,B,X,Y,R,E>(sig:Signal<B>):Proxy<A,B,A,B,R,E>{
    return __.belay(
      Belay.fromFuture(() -> sig.nextTime().map(
        (b) -> Yield(
          b,
          (_) -> fromSignal(sig)
        )
      ))
    );
  }  

  @:to public function toProxy():Proxy<A,B,X,Y,R,E>{
    return this;
  }
}
class PushLift{
  
}