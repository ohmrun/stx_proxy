package stx.proxy.body;

class Proxieds{
  static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1>(lhs:Arrowlet<P0,Proxy<A0,B0,X0,Y0,R0>>,rhs:Arrowlet<R0,Proxy<A1,B1,X1,Y1,R1>>):Arrowlet<P0,Proxy<A1,B1,X1,Y1,R1>>{
    return function(p0:P0,cont){
      lhs.then(
        function(p,cont0){
          switch(p){
            case Ended(r) : rhs(r,cont0);
            default       : then(lhs,rhs)(p0,cont0);
          }
          return function(){};
        }
      )(p0,cont);
      return function(){}
    }
  }
}