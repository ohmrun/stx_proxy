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
    var error     = __.report();
    final report  = (x:Report<E>) -> {
      error = x;
    }
    return Work.fromCycle(
      new AgendaCyclerCls(action,report)
    ).seq(
      Cycle.anon(() -> {
        return Future.lazy(cont.receive(cont.value(error)));
      })
    );
  }
}
private class AgendaCyclerCls<E> extends stx.stream.Cycle.CyclerCls{
  public var done : Bool;

  public final report : Report<E> -> Void;
  public var   action : Agenda<E>;
  public function new(action,report){
    this.action = action;
    this.report = report;
    this.done   = false;
  }
  public function get_state()  : CycleState{
    return switch(action){
      case Ended(_) : CYCLE_NEXT;
      default       : CYCLE_STOP;
    }
  }
  public function get_value()  : Null<Future<Cycle>>{
    if(value == null){
      final c = (x) -> new AgendaCyclerCls(Agenda.lift(x),report).toCyclerApi();
      value =  switch(action){
        case Await(_, arw)    : Future.irreversible((cb) -> cb(c(arw(null)).toCyclerApi()));
        case Yield(_, arw)    : Future.irreversible((cb) -> cb(c(arw(null)).toCyclerApi()));
        case Ended(End(null)) : null;
        case Ended(End(e))    : 
          report(__.report(f -> e));
          null;
        case Ended(Tap)       : null;
        case Ended(Val(_))    : null;
        case Defer(ft)        : Future.irreversible(
          (cb:Cycle->Void) -> {
            var next_agenda = null;
            final set_next_agenda = (x) -> {
              next_agenda = x;
            }
            final lhs = ft.prj().environment(
              Noise,
              (agenda)  -> set_next_agenda(c(agenda)),
              (e)       -> __.raise(e)            
            ).cycle();
            final rhs = Cycle.anon(
              () -> {
                return __.option(next_agenda).fold(
                  ok -> Future.irreversible(cb -> cb(ok)),
                  () -> null
                );
              }
            );
            cb(lhs.seq(rhs));
          }
        );
      }
      return value;
    }
  }
}