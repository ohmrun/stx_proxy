package stx.proxy.core;
        
typedef ClientDef<A,B,R,E>  = ProxySum<A,B,Nada,Closed,R,E>;

@:using(stx.proxy.core.Client.ClientLift)
abstract Client<A,B,R,E>(ClientDef<A,B,R,E>) from ClientDef<A,B,R,E> to ClientDef<A,B,R,E>{
  static public var _(default,never) = ClientLift;
  public function new(self) this = self;
  @:noUsing static public function lift<A,B,R,E>(self:ClientDef<A,B,R,E>):Client<A,B,R,E> return new Client(self);
  

  public function prj():ClientDef<A,B,R,E> return this;
  private var self(get,never):Client<A,B,R,E>;
  private function get_self():Client<A,B,R,E> return lift(this);
}
class ClientLift{
  static public function actuate<A,B,R,E>(client:Client<A,B,R,E>,actuator:Actuator<B,E>):Client<A,B,R,E>{
    var lift = Client.lift;
    function rec(client:ClientDef<A,B,R,E>,actuator:ActuatorDef<B,E>):ClientDef<A,B,R,E>{
      return switch([client,actuator]){
        case [Await(_,nxtI),Yield(b,nxtII)]       : __.belay(Belay.fromThunk(() ->rec(nxtI(b),nxtII(Nada))));
        case [Ended(e),_]                         : lift(__.ended(e));
        case [_,Ended(End(e))]                    : lift(__.ended(End(e)));
        case [_,Ended(e)]                         : client;
        case [Yield(_,nxtI),Await(_,nxtII)]       : rec(nxtI(Nada),nxtII(Nada));
        case [Await(_,_),Await(_,nxt)]            : rec(client,nxt(Nada));
        case [Yield(_,nxt),Yield(_,_)]            : __.belay(Belay.fromThunk(() -> rec(nxt(Nada),actuator)));
        case [Defer(deferI),Defer(deferII)]       : __.belay(deferI.and_with(deferII,rec));
        case [Defer(defer),_]                     : __.belay(defer.mod(rec.bind(_,actuator)));
        case [_,Defer(defer)]                     : __.belay(defer.mod(rec.bind(client)));
      }
    }
    return Client.lift(rec(client,actuator));
  }
  static public function completion<A,B,R,E>(client:Client<A,B,R,E>,def:A->Chunk<R,E>):Producer<B,R,E>{
    function rec(client:ClientDef<A,B,R,E>):ProducerDef<B,R,E>{
      return Producer.lift(switch(client){
        case Await(a,nxt) : __.ended(def(a));
        case Yield(_,nxt) : __.belay(Belay.fromThunk(rec.bind(nxt(Nada))));
        case Defer(ft)    : __.belay(ft.mod(rec));
        case Ended(end)   : __.ended(end);
      });
    }
    return Producer.lift(rec(client));
  }
}