package stx.proxy.body;

class Yields{
  @:noUsing static public function map<A,B,X,Y,R,Y1>(prx:Proxy<A,B,X,Y,R>,fn:Y->Y1):Proxy<A,B,X,Y1,R>{
    return function rec(prx:Proxy<A,B,X,Y,R>):Proxy<A,B,X,Y1,R>{
      return switch (prx) {
        case Yield(y,arw) : Yield(fn(y),arw.then(map.bind(_,fn)));
        case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
        case Ended(res)   : Ended(res);
        case Later(ft)    : Later(ft.map(map.bind(_,fn)));
      }
    }(prx);
  }
  @:noUsing static public function then<A,B,X,Y,R,Y1>(prx:Proxy<A,B,X,Y,R>,fn:Arrowlet<Y,Y1>):Proxy<A,B,X,Y1,R>{
    return function rec(prx:Proxy<A,B,X,Y,R>):Proxy<A,B,X,Y1,R>{
      return switch (prx) {
        case Yield(y,arw) :
        var trg = Future.trigger();
        fn.apply(y).handle(
          function(fnr){
            trg.trigger(
              Yield(fnr,arw.then(then.bind(_,fn)))
            );
          }
        );
        Later(trg.asFuture());
        case Await(a,arw) : Await(a,arw.then(then.bind(_,fn)));
        case Ended(res)   : Ended(res);
        case Later(ft)    : Later(ft.map(then.bind(_,fn)));
      }
    }(prx);
  }
  @:noUsing static public function tap<A,B,X,Y,R>(prx:Proxy<A,B,X,Y,R>,fn:Y->Void):Proxy<A,B,X,Y,R>{
    return map(prx,function(x) {fn(x);return x;});
  }}
