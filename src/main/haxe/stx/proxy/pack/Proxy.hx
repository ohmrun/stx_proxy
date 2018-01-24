package stx.proxy.pack;

import stx.proxy.head.Data.Proxy in ProxyT;

@:forward abstract Proxy<A,B,X,Y,R>(ProxyT<A,B,X,Y,R>) from ProxyT<A,B,X,Y,R> to ProxyT<A,B,X,Y,R>{
  public function new(v){
    this = v;
  }
  public function flatMap<O>(fn:Arrowlet<R,Proxy<A,B,X,Y,O>>):Proxy<A,B,X,Y,O>{
    return Proxies.flatMap(this,fn);
  }
  public function reflect():Proxy<Y,X,B,A,R>{
    return Proxies.reflect(this);
  }
  /*
  public function asYield():Yield<A,B,X,Y,R>{
    return new Yield(this);
  }*/

  @:noUsing static public function pull<A,B,X,Y,R>(a:A):Proxy<A,B,A,B,R>{
    return Pulls.pure(a);
  }
  //push :: Monad m => a -> Proxy a' a a' a m r
  @:noUsing static public function push<A,B,R>(b:B):Proxy<A,B,A,B,R>{
    return Pushes.pure(b);
  }
  @:noUsing static public function request<A,B,X,Y,R>(a:A):Proxy<A,B,X,Y,B>{
    return Requests.pure(a);
  }
  @:noUsing static public function respond<A,B,X,Y>(y:Y):Proxy<A,B,X,Y,X>{
    return Responds.pure(y);
  }
}
