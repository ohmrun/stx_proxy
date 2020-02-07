package stx.proxy.core.pack;

@:forward abstract Yielder<A,B,X,Y,R,E>(Proxy<A,B,X,Y,R,E>) from Proxy<A,B,X,Y,R,E> to Proxy<A,B,X,Y,R,E>{
  public function new(proxy){
    this = proxy;
  }
  public function prj():Proxy<A,B,X,Y,R,E>{
    return this;
  }
}