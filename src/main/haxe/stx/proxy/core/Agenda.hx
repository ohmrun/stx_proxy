package stx.proxy.core;

typedef AgendaDef<E>     = ProxySum<Closed,Noise,Noise,Closed,Noise,E>;

@:using(stx.proxy.core.Agenda.AgendaLift)
abstract Agenda<E>(AgendaDef<E>) from AgendaDef<E> to AgendaDef<E>{
  public function new(self) this = self;
  @:noUsing static public function lift<E>(self:AgendaDef<E>) return new Agenda(self);
  
  public function prj():AgendaDef<E>{
    return this;
  }
  @:from static public function fromEffect<E>(self:Effect<E>):Agenda<E>{
    function handler(self:EffectDef<E>):AgendaDef<E>{
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
  public var error(get,never):Report<E>;
  public function get_error():Report<E>{
    return switch(this){
      case Ended(End(e)) if(e!=null)  : __.report(f -> e);
      default                         : __.report();
    }
  }
}
class AgendaLift{
  static public function toExecute<E>(self:AgendaDef<E>):Execute<E>{
    return Execute.lift(Fletcher.fromApi(new AgendaExecute(self)));
  }
}
class AgendaExecute<E> extends FletcherCls<Noise,Report<E>,Noise>{
  public var action : Agenda<E>;
  public function new(action){
    super();
    this.action = action;
  }
  public function defer(_:Noise,cont:Terminal<Report<E>,Noise>):Work{
    return Work.lift(
      Cycler.pure(Future.irreversible(
        (cb:Cycle->Void) -> {
          cb(handler(action,(report) -> cont.receive(cont.value(report))));
        }
      ))
    );
  }
  private final function handler(self:AgendaDef<Dynamic>,cont:Report<E>->Void):Cycle{
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