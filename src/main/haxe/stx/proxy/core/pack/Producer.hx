package stx.proxy.core.pack;


typedef ProducerDef<Y,R,E> = ProxySum<Closed,Noise,Noise,Y,R,E>;

@:forward abstract Producer<Y,R,E>(ProducerDef<Y,R,E>) from ProducerDef<Y,R,E> to ProducerDef<Y,R,E> {
  public function new(self:ProducerDef<Y,R,E>){
    this = self;
  }
  //public function consume(cns:Consumer<Y,R,E>):Outlet<R,E>{
    
  //}
}