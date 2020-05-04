package stx.proxy.core.pack;

@:forward abstract Request<A,B,M,N,Y,E>(ProxySum<A,B,M,N,Y,E>) from ProxySum<A,B,M,N,Y,E> to ProxySum<A,B,M,N,Y,E>{
  public function new(self){
    this = self;
  }
}