package stx.proxy.core.pack;

typedef ProxyArrowDef<P,A,B,X,Y,R,E> = Unary<P,Proxy<A,B,X,Y,R,E>>;

from ProxyArrowDef<P,A,B,X,Y,R,E>
@:using(stx.proxy.core.pack.ProxyArrow.ProxyArrowLift)
abstract ProxyArrow<P,A,B,X,Y,R,E>(ProxyArrowDef<P,A,B,X,Y,R,E>) to ProxyArrowDef<P,A,B,X,Y,R,E>{
  public function new(self){
    this = self;
  }
}
class ProxyArrowLift{
  @:noUsing static public function next<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1,E>(lhs:Unary<P0,Proxy<A0,B0,X0,Y0,R0,E>>,rhs:Unary<R0,Proxy<A1,B1,X1,Y1,R1,E>>):Unary<P0,Proxy<A1,B1,X1,Y1,R1,E>>{
    return (p0:P0) -> 
      ((lhs.then(
          (p:Proxy<A0,B0,X0,Y0,R0,E>) -> switch p {
            case Ended(Val(r))  : rhs(r);
            case Ended(End(e))  : Ended(End(e));
            case Ended(Tap)     : Ended(Tap);
            default             : __.belay(next(lhs,rhs).bindI(p0));
          }
      ))(p0));
  }
}