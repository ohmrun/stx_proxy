package stx.proxy.core.pack;

typedef ConsumerDef<B,R,E> = ProxySum<Noise,B,Noise,Closed,R,E>; 

@:forward abstract Consumer<B,R,E>(ConsumerDef<B,R,E>) from ConsumerDef<B,R,E> to ConsumerDef<B,R,E>{
  public function new(self:ConsumerDef<B,R,E>){
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