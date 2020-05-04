package stx.proxy.core.pack;

@:callable @:forward abstract Requested<X,A,B,M,N,Y,E>(Arrowlet<X,Proxy<A,B,M,N,Y,E>>) from Arrowlet<X,Proxy<A,B,M,N,Y,E>> to Arrowlet<X,Proxy<A,B,M,N,Y,E>>{
    public function new(self){
      this = self;
    }
    public function compose<O>(fn1:Arrowlet<M,Proxy<X,Y,M,N,O,E>>):Requested<M,A,B,M,N,O,E>{
      return Requesteds.compose(this,fn1);
    }
    public function then<O>(prx1:Proxy<X,Y,M,N,O,E>):Request<A,B,M,N,O,E>{
      return Requesteds.then(this,prx1);
    }
}