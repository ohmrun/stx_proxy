package stx.proxy.core.body;

class Proxieds{
  static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1,E>(lhs:Arrowlet<P0,Proxy<A0,B0,X0,Y0,R0,E>>,rhs:Arrowlet<R0,Proxy<A1,B1,X1,Y1,R1,E>>):Arrowlet<P0,Proxy<A1,B1,X1,Y1,R1,E>>{
    return function(p0:P0,cont:Strand<Proxy<A1,B1,X1,Y1,R1,E>>){
      return lhs.then(
        function(p,cont0:Strand<Proxy<A1,B1,X1,Y1,R1,E>>){
          return switch(p){
            case Ended(r) : cont0.apply(r.fold(
              (x) -> Later(rhs.close(x)),
              (e) -> Ended(End(e)),
              ()  -> Ended(Tap)
            ));
            default       : then(lhs,rhs).withInput(p0,cont0);
          }
        }
      ).withInput(p0,cont);
    }
  }
}