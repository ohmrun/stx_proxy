package stx.proxy.core;

typedef ActionDef<E>     = ProxySum<Closed,Noise,Noise,Closed,Noise,E>;

@:using(stx.proxy.core.Action.ActionLift)
abstract Action<E>(ActionDef<E>) from ActionDef<E> to ActionDef<E>{
  public function new(self) this = self;
  static public function lift<E>(self:ActionDef<E>) return new Action(self);
  
  public function prj():ActionDef<E>{
    return this;
  }
  @:from static public function fromEffect<E>(self:Effect<E>):Action<CoroutineFailure<E>>{
    function handler(self:EffectDef<E>):ActionDef<CoroutineFailure<E>>{
      return switch(self){
        case Wait(fn)                     : Await(Closed.ZERO, (_:Noise) -> handler(fn(Noise)) );
        case Emit(head,tail)              : Await(Noise, (_:Noise) -> handler(tail));
        case Hold(slot)                   : __.belay(slot.map(handler));
        case Halt(Production(_))          : Ended(Val(Noise));
        case Halt(Terminated(Stop))       : Ended(Tap);
        case Halt(Terminated(Exit(e)))    : Ended(End(e));
      }
    }
    return lift(__.belay(Belay.fromThunk(handler.bind(self))));
  }
  @:to public function toProxy():Proxy<Closed,Noise,Noise,Closed,Noise,E>{
    return this;
  }
}
class ActionLift{
  static public function toExecute<E>(self:ActionDef<E>):Execute<CoroutineFailure<E>>{
    return Execute.lift(Fletcher.fromApi(new ActionExecute(self)));
  }
}
class ActionExecute<E> implements FletcherApi<Noise,Report<CoroutineFailure<E>>,Noise>{
  public var action : Action<E>;
  public function new(action){
    this.action = action;
  }
  public function defer(_:Noise,cont:Terminal<Report<CoroutineFailure<E>>,Noise>):Work{
    return __.option(
      () -> Future.irreversible(
        (cb:Cycle->Void) -> {
          cb(handler(action,(report) -> cont.receive(cont.value(report))));
        }
      )
    );
  }
  private final function handler(self:ActionDef<Dynamic>,cont:Report<CoroutineFailure<E>>->Void):Cycle{
    final f = handler.bind(_,cont);
    return switch(self){
      case Await(_,b)     : Future.irreversible(cb -> cb(f(b(null))));
      case Yield(_,x)     : Future.irreversible(cb -> cb(f(x(null))));
      case Defer(held)    : 
        final provide : Provide<Cycle>  = Provide.lift(held.map(f));
        provide.then(
          Fletcher.Anon(
            (inpt:Cycle,cont:Terminal<Noise,Noise>) -> {
              return Work.fromCycle(inpt).seq(cont.receive(cont.value(Noise)));
            }
          )
        ).environment(
          (noise:Noise) -> {}
        ).cycle();
      case Ended(Val(_))                : 
        cont(__.report());
        Cycle.unit();
      case Ended(Tap)                   :   
        cont(__.report());
        Cycle.unit();
      case Ended(End(x))                : 
        cont(__.report(_ -> x));
        Cycle.unit();
    }
  }
}