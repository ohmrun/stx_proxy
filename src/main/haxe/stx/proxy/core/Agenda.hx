package stx.proxy.core;

using stx.Stream;
using stx.stream.Cycle;
using stx.stream.Work;

/**
 * Def for `stx.proxy.core.Agenda`
 */
typedef AgendaDef<E>     = ProxySum<Closed,Nada,Nada,Closed,Nada,E>;

/**
 * Represents a sequence of closed over function calls, possibly yielding
 * an error.
 * 
 * Analogous to `stx.coroutine.Effect`
 */
@:using(stx.proxy.core.Agenda.AgendaLift)
abstract Agenda<E>(AgendaDef<E>) from AgendaDef<E> to AgendaDef<E>{
  public function new(self) this = self;
  @:noUsing static public function lift<E>(self:AgendaDef<E>) return new Agenda(self);
  
  public function prj():AgendaDef<E>{
    return this;
  }
  @:from static public function fromRefuse<E>(self:Refuse<E>):Agenda<E>{
    return Ended(End(self));
  }
  @:from static public function fromEffect<E>(self:Effect<E>):Agenda<E>{
    function handler(self:EffectDef<E>):AgendaDef<E>{
      return switch(self){
        case Wait(fn)                     : Await(Closed.ZERO, (_:Nada) -> handler(fn(Nada)) );
        case Emit(head,tail)              : Await(Nada, (_:Nada) -> handler(tail));
        case Hold(slot)                   : __.belay(slot.map(handler));
        case Halt(Production(_))          : Ended(Val(Nada));
        case Halt(Terminated(Stop))       : Ended(Tap);
        case Halt(Terminated(Exit(e)))    : Ended(End(e));
      }
    }
    return lift(__.belay(Belay.fromThunk(handler.bind(self))));
  }
  @:to public function toProxy():Proxy<Closed,Nada,Nada,Closed,Nada,E>{
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
class AgendaExecute<E> extends FletcherCls<Nada,Report<E>,Nada>{
  public var action : Agenda<E>;
  public function new(action){
    super();
    this.action = action;
  }
  public function defer(_:Nada,cont:Terminal<Report<E>,Nada>):Work{
    var error     = __.report();
    final report  = (x:Report<E>) -> {
      error = x;
    }
    final lhs = new AgendaCyclerCls(action,report);
    final rhs = Cycle.anon(() -> {
      __.log().trace('calling: $error');
      return Future.irreversible(
        (cb) -> {
          __.log().trace('called');
          final conted    = cont.value(error);
          final received  = cont.receive(conted);     
          cb(received);
        }
      );
    });
    return Work.fromCycle(
      lhs.seq(rhs)
    );
  }
}
private class AgendaCyclerCls<E> implements stx.stream.Cycle.CyclerApi{
  public var done     : Bool;
  public final uuid   : String;
  public final report : Report<E> -> Void;
  public var   action : Agenda<E>;
  public var working  : Bool;
  public final pos    : Position;

  public function new(action:Agenda<E>,report,?pos:Pos){
    this.pos        = pos;
    this.action     = action;
    this.report     = report;
    this.done       = false;
    this.uuid       = __.uuid("xxxxx");
    this.working    = false;
    __.log().trace('next agenda: ${this.uuid} $action ${this.pos}');
  }
  public var state(get,null)    : CycleState;
  public function get_state()   : CycleState{
    return switch(action){
      case Ended(_) : CYCLE_STOP;
      default       : CYCLE_NEXT;
    }
  }
  @:isVar public var value(get,null)          : Null<Future<Cycle>>;
  public function get_value()  : Null<Future<Cycle>>{
    __.log().trace('$uuid: ${this.value} ${this.pos}');
    if(this.value == null && !this.working){
      this.working = true;
      __.log().debug('$action');
      final c = (x) -> {
        __.log().trace('constructor');
        return new AgendaCyclerCls(Agenda.lift(x),report).toCyclerApi();
      }
      this.value = (switch(action){
        case Await(_, arw)    : Future.irreversible((cb) -> cb(c(arw(Nada)).toCyclerApi()));
        case Yield(_, arw)    : Future.irreversible((cb) -> cb(c(arw(Nada)).toCyclerApi()));
        case Ended(End(null)) : null;
        case Ended(End(e))    : 
          __.log().debug('ready to report $e');
          report(__.report(f -> e));
          null;
        case Ended(Tap)       : null;
        case Ended(Val(_))    : null;
        case Defer(ft)        : Future.irreversible(
          (cb:Cycle->Void) -> {
            __.log().trace('call cycle');
            var next_agenda = null;
            final set_next_agenda = (x) -> {
              __.log().trace('set next agenda');
              next_agenda = x;
            }
            final lhs = ft.prj().environment(
              Nada,
              (agenda)  -> set_next_agenda(c(agenda)),
              (e)       -> __.crack(e)            
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
      });
    }
    return this.value;
  }
  public inline function toString(){
    final type  = __.definition(this).identifier();
    final val   = get_value();
    return '$type[$uuid]($state:$val:$pos)';
  } 
  public function toCyclerApi():CyclerApi{
    return this;
  }
}