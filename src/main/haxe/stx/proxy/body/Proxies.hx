package stx.proxy.body;

class Proxies{
  static public function flatMap<A,B,X,Y,R,O>(prx:Proxy<A,B,X,Y,R>,fn:Arrowlet<R,Proxy<A,B,X,Y,O>>):Proxy<A,B,X,Y,O>{
    return switch (prx) {
      case Await(a,arw) : Await(a,arw.then(flatMap.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(flatMap.bind(_,fn)));
      case Ended(res)   : Later(fn.apply(res));
      case Later(ft)    : Later(ft.map(function(pr) return flatMap(pr,fn)));
    }
  }
  static public function map<A,B,X,Y,R,O>(prx:Proxy<A,B,X,Y,R>,fn:R->O):Proxy<A,B,X,Y,O>{
    return switch (prx) {
      case Ended(res)   : Ended(fn(res));
      case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(map.bind(_,fn)));
      case Later(ft)    : Later(ft.map(map.bind(_,fn)));
    }

  }
  static public function reflect<A,B,X,Y,R>(prx:Proxy<A,B,X,Y,R>):Proxy<Y,X,B,A,R>{
    return switch(prx) {
      case Await(a,arw) : Yield(a,arw.then(reflect));
      case Yield(a,arw) : Await(a,arw.then(reflect));
      case Ended(r)     : Ended(r);
      case Later(prx)   : Later(prx.map(reflect));
    }
  }
  static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1>(lhs:Arrowlet<P0,Proxy<A0,B0,X0,Y0,R0>>,rhs:Arrowlet<R0,Proxy<A1,B1,X1,Y1,R1>>):Arrowlet<P0,Proxy<A1,B1,X1,Y1,R1>>{
    return function(p0:P0,cont){
      lhs.then(
        function(p,cont){
          switch(p){
            case Ended(r) : rhs(r,cont);
            default       : then(lhs,rhs)(p0,cont);
          }
          return function(){};
        }
      )(p0,cont);
      return function(){}
    }
  }
}
