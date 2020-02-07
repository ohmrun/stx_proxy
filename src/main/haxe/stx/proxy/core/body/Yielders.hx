package stx.proxy.core.body;

class Yielders{
  @:noUsing static public function map<A,B,X,Y,R,Y1,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Y->Y1):Proxy<A,B,X,Y1,R,E>{
    return (function rec(prx:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y1,R,E>{
      return switch (prx) {
        case Yield(y,arw) : Yield(fn(y),arw.then(map.bind(_,fn)));
        case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
        case Ended(res)   : Ended(res);
        case Later(ft)    : Later(ft.map(map.bind(_,fn)));
      }
    })(prx);
  }
  @:noUsing static public function mapa<A,B,X,Y,R,Y1,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Arrowlet<Y,Y1>):Proxy<A,B,X,Y1,R,E>{
    return (function rec(prx:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y1,R,E>{
      return switch (prx) {
        case Yield(y,arw) :
          Later(
            fn.receive(y).map(
              (y1) -> Yield(y1,arw.then(mapa.bind(_,fn)))
            )
          );
        case Await(a,arw) : Await(a,arw.then(mapa.bind(_,fn)));
        case Ended(res)   : Ended(res);
        case Later(ft)    : Later(ft.map(mapa.bind(_,fn)));
      }
    })(prx);
  }
  @:noUsing static public function tap<A,B,X,Y,R,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Y->Void):Proxy<A,B,X,Y,R,E>{
    return map(prx,function(x) {fn(x);return x;});
  }}
