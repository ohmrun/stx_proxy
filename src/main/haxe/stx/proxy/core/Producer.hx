package stx.proxy.core;

typedef ProducerDef<Y,R,E> = ProxySum<Closed,Noise,Noise,Y,R,E>;

@:using(stx.proxy.core.Producer.ProducerLift)
@:forward abstract Producer<Y,R,E>(ProducerDef<Y,R,E>) from ProducerDef<Y,R,E> to ProducerDef<Y,R,E> {
  static public var _(default,never) = ProducerLift;
  @:noUsing static public function lift<Y,R,E>(self:ProducerDef<Y,R,E>):Producer<Y,R,E>{
    return new Producer(self);
  }
  public function new(self:ProducerDef<Y,R,E>){
    this = self;
  }
  @:noUsing static public function pure<Y,R,E>(self:R){
    return lift(Ended(Val(self)));
  }
  public function prj():ProducerDef<Y,R,E>{
    return this;
  }
  //public function consume(cns:Consumer<Y,R,E>):Outlet<R,E>{
    
  //}
} 
class ProducerLift{
  /*
  static public function absolute<Y,R,E>(self:Producer<Y,R,E>,dispatch:Dispatch<R,E>):Actuator<Y,E>{
    
    function rec(self:ProducerDef<Y,R,E>,dispatch:DispatchDef<R,E>):ActuatorDef<Y,E>{
      return switch()
    }
    return Actuator.lift(rec(self,dispatch));
  }*/
}
