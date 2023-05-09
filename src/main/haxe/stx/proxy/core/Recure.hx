package stx.proxy.core;

typedef RecureDef<B,Y,R,E>   = ProxySum<Nada,B,Nada,Y,R,E>;

@:using(stx.proxy.core.Proxy.ProxyLift)
@:forward abstract Recure<B,Y,R,E>(RecureDef<B,Y,R,E>) from RecureDef<B,Y,R,E> to RecureDef<B,Y,R,E> {
  public function new(self){
    this = self;
  }
  public function produce(th:Thunk<B>):Producer<Y,R,E>{
    var a                                   = PullCat._.next.bind(_,this);
    var b                                   = function rec(_:Nada) return Yield(th(),rec);
    var c : Proxy<Closed,Nada,Nada,Y,R,E> = a(b);
    return new Producer(c);
  }
  static public function fromTunnel<I,O,E>(self:CoroutineSum<I,O,Nada,E>):Recure<I,O,Nada,E>{
    function rec(self:CoroutineSum<I,O,Nada,E>):RecureDef<I,O,Nada,E>{
      return switch(self){
        case Emit(o,next) : __.yield(o,(_) -> rec(next));
        case Wait(tran)   : __.await(Nada,(b:I) -> rec(tran(b)));
        case Hold(held)   : __.belay(held.map(rec)); 
        case Halt(r)      : switch(r){
          case Terminated(Stop)               : __.ended(Tap);
          case Terminated(Exit(rejection))    : __.ended(End(rejection));
          case Production(_)                  : __.ended(Val(Nada));
        }
      }
    }
    return rec(self);
  }
}