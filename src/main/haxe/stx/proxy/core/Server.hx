package stx.proxy.core;

typedef ServerDef<X,Y,R,E> = ProxySum<Closed,Noise,X,Y,R,E>;

@:forward abstract Server<X,Y,R,E>(ServerDef<X,Y,R,E>) from ServerDef<X,Y,R,E> to ServerDef<X,Y,R,E>{
  public function new(v:ServerDef<X,Y,R,E>){
    this = v;
  }
  public function prj():ServerDef<X,Y,R,E>{
    return this;
  }
  public function reflect():Client<Y,X,R,E>{
    return Client.lift(Proxy._.reflect(this));
  }
}