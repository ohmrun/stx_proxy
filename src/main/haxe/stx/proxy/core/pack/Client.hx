package stx.proxy.core.pack;

typedef ClientDef<A,B,R,E>  = ProxySum<A,B,Noise,Closed,R,E>;

@:using(stx.proxy.core.pack.Client.ClientLift)
abstract Client<A,B,R,E>(ClientDef<A,B,R,E>) from ClientDef<A,B,R,E> to ClientDef<A,B,R,E>{
  static public var _(default,never) = ClientLift;
  public function new(self) this = self;
  static public function lift<A,B,R,E>(self:ClientDef<A,B,R,E>):Client<A,B,R,E> return new Client(self);
  

  public function prj():ClientDef<A,B,R,E> return this;
  private var self(get,never):Client<A,B,R,E>;
  private function get_self():Client<A,B,R,E> return lift(this);
}
class ClientLift{
  static public function drive<A,B,R,E>(client:Client<A,B,R,E>,producer:Producer<B,R,E>):Producer<A,R,E>{
    var lift = Producer.lift;
    function rec(client:ClientDef<A,B,R,E>,producer:ProducerDef<B,R,E>):ProducerDef<A,R,E>{
      return switch([client,producer]){
        case [Await(_,nxtI),Yield(b,nxtII)]       : __.belay(() ->rec(nxtI(b),nxtII(Noise)));
        case [Ended(e),_]                         : lift(__.ended(e));
        case [_,Ended(e)]                         : lift(__.ended(e));
        case [Yield(_,nxtI),Await(_,nxtII)]       : rec(nxtI(Noise),nxtII(Noise));
        case [Await(_,_),Await(_,nxt)]            : rec(client,nxt(Noise));
        case [Yield(_,nxt),Yield(_,_)]            : __.belay(() -> rec(nxt(Noise),producer));
        case [Defer(deferI),Defer(deferII)]       : __.belay(deferI.and_with(deferII,rec));
        case [Defer(defer),_]                     : __.belay(defer.mod(rec.bind(_,producer)));
        case [_,Defer(defer)]                     : __.belay(defer.mod(rec.bind(client)));
      }
    }
    return Producer.lift(rec(client,producer));
  }
}