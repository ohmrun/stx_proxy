package stx.proxy.core.body;

class Proxies{
  static public function fmap<A,B,X,Y,R,O,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Arrowlet<R,Proxy<A,B,X,Y,O,E>>):Proxy<A,B,X,Y,O,E>{
    return switch (prx) {
      case Await(a,arw) : Await(a,arw.then(fmap.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(fmap.bind(_,fn)));
      case Ended(res)   : 
        //TODO
        res.fold(
          (r) -> Later(fn.receive(r)), 
          (e) -> Ended(End(e)),
          ()  -> Ended(Tap)
        );
      case Later(ft)    : Later(ft.map(pr -> fmap(pr,fn)));
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
}
