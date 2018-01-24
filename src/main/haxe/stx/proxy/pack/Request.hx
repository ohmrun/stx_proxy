package stx.proxy.pack;

@:forward abstract Request<A,B,M,N,Y>(Proxy<A,B,M,N,Y>) from Proxy<A,B,M,N,Y> to Proxy<A,B,M,N,Y>{
  public function new(self){
    this = self;
  }
}