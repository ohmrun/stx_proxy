package stx.proxy;

using stx.Arrays;
import stx.Proxy;
using stx.Tuple;
import tink.core.Signal;
import tink.core.Error;
import stx.data.Thunk;
import tink.core.Future;
using stx.async.Arrowlet;

using stx.async.Futures;
import stx.proxy.data.Closed;
import stx.proxy.data.Proxy;
import stx.proxy.data.Server in TServer;
import tink.core.Noise;
using stx.Pointwise;


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
