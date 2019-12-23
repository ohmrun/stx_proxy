package stx.proxy.core.pack;

@:forward abstract Request<A,B,M,N,Y,E>(Proxy<A,B,M,N,Y,E>) from Proxy<A,B,M,N,Y,E> to Proxy<A,B,M,N,Y,E>{
  public function new(self){
    this = self;
  }
}