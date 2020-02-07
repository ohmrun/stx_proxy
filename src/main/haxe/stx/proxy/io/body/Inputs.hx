package stx.proxy.io.body;

import stx.proxy.core.head.data.Server  in ServerT;
import stx.asys.io.pack.StdIn           in AsysStdIn;
import stx.proxy.io.head.data.Input     in InputT;

class Inputs{ 
  static public function request(ipt:StdIn):Consumer<InputRequest,InputResponse,IOFailure>{
    var folder = Chunks._.fold.bind(
      (x)         -> Ended(Val(x)),
      (e)         -> Ended(End(e)),
      ()          -> Ended(Tap)
    );
    var arw    = Attempts.fromIOConstructor((ipt:AsysStdIn).apply);
    return Await(Noise,
      arw.prj().postfix(folder)
    );
  }
}