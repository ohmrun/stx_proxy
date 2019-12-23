package stx.proxy.core.body;

class Proxies{
  static public function flatMap<A,B,X,Y,R,O,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Arrowlet<R,Proxy<A,B,X,Y,O,E>>):Proxy<A,B,X,Y,O,E>{
    return switch (prx) {
      case Await(a,arw) : Await(a,arw.then(flatMap.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(flatMap.bind(_,fn)));
      case Ended(res)   : 
        res.fold(
          (r) -> Later(fn.close(r)),
          (e) -> Ended(End(e)),
          ()  -> Ended(Tap)
        );
      case Later(ft)    : Later(ft.map(function(pr) return flatMap(pr,fn)));
    }
  }
  static public function map<A,B,X,Y,R,O,E>(prx:Proxy<A,B,X,Y,R,E>,fn:R->O):Proxy<A,B,X,Y,O,E>{
    return switch (prx) {
      case Ended(res)   : Ended(res.map(fn));
      case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(map.bind(_,fn)));
      case Later(ft)    : Later(ft.map(map.bind(_,fn)));
    }

  }
  static public function reflect<A,B,X,Y,R,E>(prx:Proxy<A,B,X,Y,R,E>):Proxy<Y,X,B,A,R,E>{
    return switch(prx) {
      case Await(a,arw) : Yield(a,arw.then(reflect));
      case Yield(a,arw) : Await(a,arw.then(reflect));
      case Ended(r)     : Ended(r);
      case Later(prx)   : Later(prx.map(reflect));
    }
  }
  static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1,E>(lhs:Arrowlet<P0,Proxy<A0,B0,X0,Y0,R0,E>>,rhs:Arrowlet<R0,Proxy<A1,B1,X1,Y1,R1,E>>):Arrowlet<P0,Proxy<A1,B1,X1,Y1,R1,E>>{
    return (p0:P0,cont:Strand<Proxy<A1,B1,X1,Y1,R1,E>>) -> 
      lhs.then(
        (p:Proxy<A0,B0,X0,Y0,R0,E>,cont:Strand<Proxy<A1,B1,X1,Y1,R1,E>>) ->
          switch p {
            case Ended(Val(r))  : rhs.withInput(r,cont);
            case Ended(End(e))  : cont.apply(Ended(End(e)));
            case Ended(Tap)     : cont.apply(Ended(Tap));
            default             : Proxies.then(lhs,rhs).withInput(p0,cont);
          }
      ).withInput(p0,cont);
  }
}
