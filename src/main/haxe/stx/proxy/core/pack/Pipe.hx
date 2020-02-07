package stx.proxy.core.pack;

import stx.proxy.core.head.data.Pipe in PipeT;

@:forward abstract Pipe<B,Y,R,E>(PipeT<B,Y,R,E>) from PipeT<B,Y,R,E> to PipeT<B,Y,R,E> {
  public function new(self){
    this = self;
  }
  public function fill(th:Thunk<B>):Producer<Y,R,E>{
    var a                                   = Pulls.puller.bind(_,this);
    var b                                   = function rec(_:Noise) return Yield(th(),rec);
    var c : Proxy<Closed,Noise,Noise,Y,R,E> = a(b);
    return new Producer(c);
  }
}