package stx.proxy.core.pack;


typedef ProducerDef<Y,R,E> = ProxySum<Closed,Noise,Noise,Y,R,E>;

@:using(stx.proxy.core.pack.Producer.ProducerLift)
@:forward abstract Producer<Y,R,E>(ProducerDef<Y,R,E>) from ProducerDef<Y,R,E> to ProducerDef<Y,R,E> {
  static public var _(default,never) = ProducerLift;
  @:noUsing static public function lift<Y,R,E>(self:ProducerDef<Y,R,E>):Producer<Y,R,E>{
    return new Producer(self);
  }
  public function new(self:ProducerDef<Y,R,E>){
    this = self;
  }
  @:from static public function fromIterable<Y,E>(iterable:Iterable<Y>):Producer<Y,Noise,E>{
    return lift(__.belay(
      () -> {
        var iter = iterable.iterator();
        function rec(){
          return iter.hasNext() ? __.yield(iter.next(),(_) -> rec()) : __.ended(Val(Noise));
        }
        return rec();
      }
    ));
  }
  //public function consume(cns:Consumer<Y,R,E>):Outlet<R,E>{
    
  //}
} 
class ProducerLift{

}
