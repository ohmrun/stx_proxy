package stx.proxy.pack;

import stx.proxy.head.Data.Server in TServer;

abstract Server<X,Y,R>(TServer<X,Y,R>) from TServer<X,Y,R> to TServer<X,Y,R>{
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