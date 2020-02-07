package stx.proxy.core.pack;

import stx.proxy.core.head.data.Consumer in ConsumerT;

@:forward abstract Consumer<B,R,E>(ConsumerT<B,R,E>) from ConsumerT<B,R,E> to ConsumerT<B,R,E>{
  public function new(self:ConsumerT<B,R,E>){
    this = self;
  }
  // public function toServer(){
  //   switch this {
  //     case Await(v, arw): arw.then(
  //       function rec(prx){ 
  //         return switch(prx){
  //           case Ended(Val(r))  : Yield(r,arw.then(rec));
  //           case Ended(End(e))  : Ended(End(e));
  //           case Ended(Tap)     : Ended();
  //           case Yield(v, arw)  : Await(Noise,(_:Noise) -> Yield())
  //         }
  //       }
  //     )
  //     case Yield(v, arw):
  //   }
  // }
}