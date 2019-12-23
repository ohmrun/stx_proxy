package stx.proxy.core.pack;

import stx.proxy.core.head.Data.Server in TServer;

abstract Server<X,Y,R,E>(TServer<X,Y,R,E>) from TServer<X,Y,R,E> to TServer<X,Y,R,E>{
  public function new(v){
    this = v;
  }
  /*
  @:from public static function fromArrow<I,O>(arw:Arrowlet<I,O>){
    return Await(null,
      arw.split(Arrowlet.unit().inject(fromArrow(arw))).then(Yield.tupled())
    );
  }*/
}