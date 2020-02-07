package stx.proxy.core.pack;

import stx.proxy.core.head.Data.Server in TServer;

@:forward abstract Server<X,Y,R,E>(TServer<X,Y,R,E>) from TServer<X,Y,R,E> to TServer<X,Y,R,E>{
  public function new(v:TServer<X,Y,R,E>){
    this = v;
  }
  public function prj():TServer<X,Y,R,E>{
    return this;
  }
  public function reflect():Client<Y,X,R,E>{
    return Proxies.reflect(this);
  }
}