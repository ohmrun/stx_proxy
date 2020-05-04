package stx.proxy.core.pack;

typedef ProxyArrowDef<P,A,B,X,Y,R,E> = Unary<P,Proxy<A,B,X,Y,R,E>>;

@:using(stx.proxy.core.pack.ProxyArrow.ProxyArrowLift)
abstract ProxyArrow<P,A,B,X,Y,R,E>(ProxyArrowDef<P,A,B,X,Y,R,E>) from ProxyArrowDef<P,A,B,X,Y,R,E> to ProxyArrowDef<P,A,B,X,Y,R,E>{
  public function new(self){
    this = self;
  }
  public function then<A1,B1,X1,Y1,R1,E>(that:Arrow<R,A1,B1,X1,Y1,R1,E>):Arrowlet<P,Proxy<A1,B1,X1,Y1,R1,E>>{
    return Arrows.then(this,that);
  }
}
class ProxyArrowLift{
  @:noUsing static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1,E>(lhs:Arrowlet<P0,Proxy<A0,B0,X0,Y0,R0,E>>,rhs:Arrowlet<R0,Proxy<A1,B1,X1,Y1,R1,E>>):Arrowlet<P0,Proxy<A1,B1,X1,Y1,R1,E>>{
    return __.arw().cont()((p0:P0,cont:Strand<Proxy<A1,B1,X1,Y1,R1,E>>) -> 
      lhs.then(
        __.arw().cont()(
          (p:Proxy<A0,B0,X0,Y0,R0,E>,cont:Strand<Proxy<A1,B1,X1,Y1,R1,E>>) ->
            switch p {
              case Ended(Val(r))  : rhs.prepare(r,cont);
              case Ended(End(e))  : cont(Ended(End(e)),Automation.unit());
              case Ended(Tap)     : cont(Ended(Tap),Automation.unit());
              default             : Arrows.then(lhs,rhs).prepare(p0,cont);
            }
        )
      ).prepare(p0,cont));
  }
}