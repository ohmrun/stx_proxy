package stx.proxy.core.pack;

typedef PipeDef<B,Y,R,E>   = ProxySum<Noise,B,Noise,Y,R,E>;

@:forward abstract Pipe<B,Y,R,E>(PipeDef<B,Y,R,E>) from PipeDef<B,Y,R,E> to PipeDef<B,Y,R,E> {
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