package stx.proxy.core;

typedef ActuatorDef<Y,E> = ProxySum<Nada,Closed,Closed,Y,Nada,E>;

@:using(stx.proxy.core.Actuator.ActuatorLift)
abstract Actuator<Y,E>(ActuatorDef<Y,E>) from ActuatorDef<Y,E> to ActuatorDef<Y,E>{
  public function new(self) this = self;
  @:noUsing static public function lift<Y,E>(self:ActuatorDef<Y,E>):Actuator<Y,E> return new Actuator(self);
  
  @:from static public function fromIterable<Y,E>(iterable:Iterable<Y>):Actuator<Y,E>{
    return lift(__.belay(
      Belay.fromThunk(() -> {
        var iter = iterable.iterator();
        function rec(){
          return iter.hasNext() ? __.yield(iter.next(),(_) -> rec()) : __.ended(Val(Nada));
        }
        return rec();
      }
    )));
  }
  

  public function prj():ActuatorDef<Y,E> return this;
  private var self(get,never):Actuator<Y,E>;
  private function get_self():Actuator<Y,E> return lift(this);
}
class ActuatorLift{
  //static public function fold<Y,E,Z>(self:Actuator<Y,E>,fn:Y->Z->Z,init:Z):Server<Z,Z,Z,E>{}
}