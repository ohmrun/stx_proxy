package stx.proxy.core.pack;

typedef RecureDef<B,Y,R,E>   = ProxySum<Noise,B,Noise,Y,R,E>;

@:forward abstract Recure<B,Y,R,E>(RecureDef<B,Y,R,E>) from RecureDef<B,Y,R,E> to RecureDef<B,Y,R,E> {
  public function new(self){
    this = self;
  }
  public function fill(th:Thunk<B>):Producer<Y,R,E>{
    var a                                   = PullCat._.next.bind(_,this);
    var b                                   = function rec(_:Noise) return Yield(th(),rec);
    var c : Proxy<Closed,Noise,Noise,Y,R,E> = a(b);
    return new Producer(c);
  }
}