package stx.proxy.core;

abstract Pull<A,B,X,Y,R,E>(ProxySum<A,B,X,Y,R,E>) from ProxySum<A,B,X,Y,R,E> to ProxySum<A,B,X,Y,R,E>{
  static public var _(default,never) = PullLift;
  public function new(self) this = self;

  @:noUsing static public function pure<A,B,X,Y,R,E>(a:A):Proxy<A,B,A,B,R,E>{
    return Await(a,
      function(b:B){
        return Yield(b,pure);  
      }
    );
  }
  @:noUsing static public function gen<A,B,R,E>(thk:Thunk<Option<A>>):Proxy<A,B,A,B,R,E>{
    return Defer(
      Belay.lazy( 
        () -> thk().fold(
          (v) -> Await(v,(_) -> gen(thk)),
          ()  -> Ended(Tap)
        )
      )
    );
  }
  @:noUsing static public function signal<A,B,X,Y,R,E>(a:A):Proxy<A,B,A,B,R,E>{
    return Await(a,
      function(b:B){
        return signal(a);
      }
    );
  }
  @:noUsing static public function fromSignal<A,B,X,Y,R,E>(sig:Signal<A>):Proxy<A,B,A,B,R,E>{
    return __.belay(
      Belay.fromFuture(() -> sig.nextTime().map(
        (v:A) -> Await(v,
          (b:B) -> fromSignal(sig)
        )
      ))
    );
  }
  @:noUsing static public function fromArray<A,B,X,Y,R,E>(arr:Array<A>):Proxy<A,B,A,B,R,E>{
    return if(arr.length == 0){
      Ended(Tap);
    }else{
      var next  = arr.copy();
      var fst   = next.shift();
      var rst   = next;
      return Await(fst,
        (b:B) -> fromArray(rst)
      );
    }
  }

  @:to public function toProxy():Proxy<A,B,X,Y,R,E>{
    return this;
  }
}
class PullLift{
 
}