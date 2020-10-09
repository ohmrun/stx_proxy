package stx.proxy.core;

typedef DefectDef<E>     = ProxySum<Closed,Noise,Noise,Closed,Closed,E>;

abstract Defect<E>(DefectDef<E>) from DefectDef<E> to DefectDef<E>{
  public function new(self) this = self;
  static public function lift<E>(self:DefectDef<E>) return new Defect(self);
  
  public function prj():DefectDef<E>{
    return this;
  }
  @:from static public function fromEffect<E>(eff:Effect<E>):Defect<CoroutineFailure<E>>{
    function handler(eff:EffectDef<E>):DefectDef<CoroutineFailure<E>>{
      return switch(eff){
        case Wait(fn)                     : Await(Closed.ZERO, (_:Noise) -> handler(fn(Noise)) );
        case Emit(head,tail)              : Await(Noise, (_:Noise) -> handler(tail));
        case Hold(slot)                   : __.belay(slot.postfix(handler));
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
class DefectLift{
  static public function submit<E>(def:Defect<E>){
    function handler(def){
      
    }
    handler(def);
  }
}