package stx.proxy.core.pack;

import stx.proxy.core.head.data.Producer in ProducerT;

@:forward abstract Producer<Y,R,E>(ProducerT<Y,R,E>) from ProducerT<Y,R,E> to ProducerT<Y,R,E> {
  public function new(self:ProducerT<Y,R,E>){
    this = self;
  }
  public function consume(cns:Consumer<Y,R,E>):Effect<R,E>{
    function rec(prd,cns){
      switch([prd,cns]){
        
      }
    }
    return null;
  }
}