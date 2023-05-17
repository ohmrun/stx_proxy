package stx.proxy.core;

typedef OutletDef<R,E>     = ProxySum<Closed,Nada,Nada,Closed,R,E>;

@:using(stx.proxy.core.Outlet.OutletLift)
abstract Outlet<R,E>(OutletDef<R,E>) from OutletDef<R,E> to OutletDef<R,E>{
  public function new(self) this = self;
  @:noUsing static public function lift<R,E>(self:OutletDef<R,E>) return new Outlet(self);
  
  public function flat_map<O>(fn:Unary<R,Outlet<O,E>>):Outlet<O,E>{
    return lift(
      ProxyLift.flat_map(
        this,
        fn.then((x:Outlet<O,E>)->x.prj())
      )
    );
  }
  public function prj():OutletDef<R,E>{
    return this;
  }
  @:noUsing static public function pure<R,E>(self:R):Outlet<R,E>{
    return lift(Ended(Val(self)));
  }
  @:noUsing static public function make<R,E>(self:Chunk<R,E>){
    return lift(Ended(self));
  }
}
class OutletLift{
  static public function toAgenda<R,E>(self:OutletDef<R,E>,fn:R->Void):Agenda<E>{
    return agenda(self,fn);
  }
  static public function agenda<R,E>(self:OutletDef<R,E>,fn:R->Void):Agenda<E>{
    __.assert().that().exists(self);
    __.log().debug('outlet agenda: $self');
    function f(me:OutletDef<R,E>){
      __.log().debug('outlet: $self');
      return switch(me){
        case Await(_,await) : f(await(Nada));
        case Yield(_,yield) : f(yield(Nada));
        case Defer(belay)   : 
          __.log().trace(_ -> _.thunk(() -> 'outlet belay $belay'));
          __.belay(
            belay.mod(
              (x) -> { 
                return f(x); 
              }
            )
          );
        case Ended(Val(r))  : 
          fn(r);
          __.ended(Tap);
        case Ended(End(x))  : Ended(End(x));
        case Ended(Tap)     : Ended(Tap);
        case null           : Ended(__.fault().explain(_ -> _.e_undefined()));
      }
    }
    return Agenda.lift(f(self));
  }
  static public function pledge<R,E>(self:OutletDef<R,E>):Pledge<R,E>{
    final source  = Pledge.trigger();
    final Agenda  = agenda(self,(r) -> source.trigger(__.accept(r)));
    final execute = Agenda.toExecute();
          execute.environment(
            ()  -> {},
            (e) -> source.trigger(__.reject(e))
          ).submit();
    return source.toPledge();
  }
}