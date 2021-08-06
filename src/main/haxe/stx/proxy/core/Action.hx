package stx.proxy.core;

typedef ActionDef<E>     = ProxySum<Closed,Noise,Noise,Closed,Closed,E>;

abstract Action<E>(ActionDef<E>) from ActionDef<E> to ActionDef<E>{
  public function new(self) this = self;
  static public function lift<E>(self:ActionDef<E>) return new Action(self);
  
  public function prj():ActionDef<E>{
    return this;
  }
  @:from static public function fromEffect<E>(eff:Effect<E>):Action<CoroutineFailure<E>>{
    function handler(eff:EffectDef<E>):ActionDef<CoroutineFailure<E>>{
      return switch(eff){
        case Wait(fn)                     : Await(Closed.ZERO, (_:Noise) -> handler(fn(Noise)) );
        case Emit(head,tail)              : Await(Noise, (_:Noise) -> handler(tail));
        case Hold(slot)                   : __.belay(slot.map(handler));
        case Halt(Production(_))          : Ended(Val(Closed.ZERO));
        case Halt(Terminated(Stop))       : Ended(Tap);
        case Halt(Terminated(Exit(e)))    : Ended(End(e));
      }
    }
    return lift(__.belay(Belay.fromThunk(handler.bind(eff))));
  }
  @:to public function toProxy():Proxy<Closed,Noise,Noise,Closed,Closed,E>{
    return this;
  }
}
class ActionLift{
  static public function submit<E>(def:Action<E>){
    function handler(def){
      
    }
    handler(def);
  }
}