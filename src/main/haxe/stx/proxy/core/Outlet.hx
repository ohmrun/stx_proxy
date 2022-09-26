package stx.proxy.core;

typedef OutletDef<R,E>     = ProxySum<Closed,Noise,Noise,Closed,R,E>;

@:using(stx.proxy.core.Outlet.OutletLift)
abstract Outlet<R,E>(OutletDef<R,E>) from OutletDef<R,E> to OutletDef<R,E>{
  public function new(self) this = self;
  @:noUsing static public function lift<R,E>(self:OutletDef<R,E>) return new Outlet(self);
  
  public function flat_map<O>(fn:Unary<R,Outlet<O,E>>):Outlet<O,E>{
    return lift(
      Proxy._.flat_map(
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
  static public function agenda<R,E>(self:OutletDef<R,E>,fn:R->Void):Agenda<E>{
    __.assert().exists(self);
    function f(self:OutletDef<R,E>){
      return switch(self){
        case Await(_,await) : f(await(Noise));
        case Yield(y,yield) : f(yield(Noise));
        case Defer(belay)   : __.belay(belay.mod(f));
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