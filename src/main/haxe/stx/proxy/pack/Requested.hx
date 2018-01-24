package stx.proxy.pack;

@:callable @:forward abstract Requested<X,A,B,M,N,Y>(Arrowlet<X,Proxy<A,B,M,N,Y>>) from Arrowlet<X,Proxy<A,B,M,N,Y>> to Arrowlet<X,Proxy<A,B,M,N,Y>>{
    public function new(self){
      this = self;
    }
    public function compose<O>(fn1:Arrowlet<M,Proxy<X,Y,M,N,O>>):Requested<M,A,B,M,N,O>{
      return Requesteds.compose(this,fn1);
    }
    public function then<O>(prx1:Proxy<X,Y,M,N,O>):Request<A,B,M,N,O>{
      return Requesteds.then(this,prx1);
    }
}