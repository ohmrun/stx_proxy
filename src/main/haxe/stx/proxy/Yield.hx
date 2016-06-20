package stx.proxy;

import tink.core.Future;
import stx.proxy.data.Proxy in TPrx;
using stx.async.Arrowlet;

@:forward abstract Yield<A,B,X,Y,R>(Proxy<A,B,X,Y,R>) from Proxy<A,B,X,Y,R> to Proxy<A,B,X,Y,R>{
  public function new(proxy){
    this = proxy;
  }
  public function map<Y1>(fn:Y->Y1):Yield<A,B,X,Y1,R>{
    return Yields.map(this,fn);
  }
  public function tap(fn:Y->Void):Yield<A,B,X,Y,R>{
    return Yields.tap(this,fn);
  }
  public function then<Y1>(fn:Arrowlet<Y,Y1>):Yield<A,B,X,Y1,R>{
    return Yields.then(this,fn);
  }
  public function asProxy():Proxy<A,B,X,Y,R>{
    return this;
  }
}
class Yields{
  @:noUsing static public function map<A,B,X,Y,R,Y1>(prx:Proxy<A,B,X,Y,R>,fn:Y->Y1):Proxy<A,B,X,Y1,R>{
    return function rec(prx:Proxy<A,B,X,Y,R>):Proxy<A,B,X,Y1,R>{
      return switch (prx) {
        case TPrx.Yield(y,arw) : TPrx.Yield(fn(y),arw.then(map.bind(_,fn)));
        case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
        case Ended(res)   : Ended(res);
        case Later(ft)    : Later(ft.then(map.bind(_,fn)));
      }
    }(prx);
  }
  @:noUsing static public function then<A,B,X,Y,R,Y1>(prx:Proxy<A,B,X,Y,R>,fn:Arrowlet<Y,Y1>):Proxy<A,B,X,Y1,R>{
    return function rec(prx:Proxy<A,B,X,Y,R>):Proxy<A,B,X,Y1,R>{
      return switch (prx) {
        case TPrx.Yield(y,arw) :
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
        case Later(ft)    : Later(ft.then(then.bind(_,fn)));
      }
    }(prx);
  }
  @:noUsing static public function tap<A,B,X,Y,R>(prx:Proxy<A,B,X,Y,R>,fn:Y->Void):Proxy<A,B,X,Y,R>{
    return map(prx,function(x) {fn(x);return x;});
  }}
