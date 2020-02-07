package stx.proxy.core.pack;

import stx.proxy.core.head.Data.Proxy in ProxyT;

@:forward abstract Proxy<A,B,X,Y,R,E>(ProxyT<A,B,X,Y,R,E>) from ProxyT<A,B,X,Y,R,E> to ProxyT<A,B,X,Y,R,E>{
  public function new(v){
    this = v;
  }
  static public inline function lift<A,B,X,Y,R,E>(prx:ProxyT<A,B,X,Y,R,E>):Proxy<A,B,X,Y,R,E>{
    return new Proxy(prx);
  }
  public function fmap<O>(fn:Arrowlet<R,Proxy<A,B,X,Y,O,E>>):Proxy<A,B,X,Y,O,E>{
    return Proxies.fmap(this,fn);
  }
  public function reflect():Proxy<Y,X,B,A,R,E>{
    return Proxies.reflect(this);
  }
  @:noUsing static public function pull<A,B,X,Y,R,E>(a:A):Proxy<A,B,A,B,R,E>{
    return Pulls.pure(a);
  }
  @:noUsing static public function push<A,B,R,E>(b:B):Proxy<A,B,A,B,R,E>{
    return Pushes.pure(b);
  }
  @:noUsing static public function request<A,B,X,Y,R,E>(a:A):Proxy<A,B,X,Y,B,E>{
    return Requests.pure(a);
  }
  @:noUsing static public function respond<A,B,X,Y,E>(y:Y):Proxy<A,B,X,Y,X,E>{
    return Responds.pure(y);
  }
}
