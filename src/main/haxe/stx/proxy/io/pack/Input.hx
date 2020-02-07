package stx.proxy.io.pack;

import stx.proxy.core.head.data.Server  in ServerT;
import stx.asys.io.pack.StdIn           in AsysStdIn;
import stx.proxy.io.head.data.Input     in InputT;

@:forward abstract Input(Arrow<InputRequest,Closed,Noise,InputRequest,InputResponse,Noise,IOFailure>) from Arrow<InputRequest,Closed,Noise,InputRequest,InputResponse,Noise,IOFailure>{
  public function new(ipt:AsysStdIn){
    var rec : Arrow<InputRequest,Closed,Noise,InputRequest,InputResponse,Noise,IOFailure> = null;
        rec = new Arrow(
          Attempts.fromIOConstructor(ipt.apply).prj().postfix(
            Chunks._.fold.bind(
              (x)         -> Yield(x,rec),
              (e)         -> Ended(End(e)),
              ()          -> Ended(Val(Noise))
            )
          )
        );
    this = (rec:InputT);
  }
}