package stx.proxy.core.pack;

@:callable @:forward abstract Proxied<P,A,B,X,Y,R,E>(Arrowlet<P,Proxy<A,B,X,Y,R,E>>) from Arrowlet<P,Proxy<A,B,X,Y,R,E>> to Arrowlet<P,Proxy<A,B,X,Y,R,E>>{
  public function new(self){
    this = self;
  }
  public function then<A1,B1,X1,Y1,R1>(fn:Arrowlet<R,Proxy<A1,B1,X1,Y1,R1,E>>):Proxied<P,A1,B1,X1,Y1,R1,E>{
    return Proxieds.then(this,fn);
  }
}