package stx.proxy.core;

typedef ProxyCatDef<P,A,B,X,Y,R,E> = Unary<P,Proxy<A,B,X,Y,R,E>>;

@:using(stx.proxy.core.ProxyCat.ProxyCatLift)
@:callable abstract ProxyCat<P,A,B,X,Y,R,E>(ProxyCatDef<P,A,B,X,Y,R,E>) from ProxyCatDef<P,A,B,X,Y,R,E> to ProxyCatDef<P,A,B,X,Y,R,E>{
  static public var _(default,never) = ProxyCatLift;
  public function new(self){
    this = self;
  }
}
class ProxyCatLift{
  @:noUsing static public function next<P,Ai,Bi,Xi,Yi,Ri,Aii,Bii,Xii,Yii,Rii,E>(lhs:Unary<P,Proxy<Ai,Bi,Xi,Yi,Ri,E>>,rhs:Unary<Ri,Proxy<Aii,Bii,Xii,Yii,Rii,E>>):Unary<P,Proxy<Aii,Bii,Xii,Yii,Rii,E>>{
    return (p0:P) -> 
      ((lhs.then(
          (p:Proxy<Ai,Bi,Xi,Yi,Ri,E>) -> switch p {
            case Ended(Val(r))  : rhs(r);
            case Ended(End(e))  : Ended(End(e));
            case Ended(Tap)     : Ended(Tap);
            default             : __.belay(next(lhs,rhs).bindI(p0));
          }
      ))(p0));
  }
}