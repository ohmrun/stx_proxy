package stx.proxy.io.pack;

import stx.proxy.core.head.data.Client  in ClientT;
import stx.proxy.core.head.data.Server  in ServerT;
import stx.asys.io.pack.StdOut          in AsysStdOut;
import stx.proxy.io.head.data.Output    in OutputT;

@:forward abstract Output(OutputT) from OutputT to OutputT{
  public function new(opt:AsysStdOut){
    var rec = null;
        rec = 
          function rec(pkt:Packet):ClientT<Noise,Packet,Noise,IOFailure>{ 
            return Later(
              Receiver.lift(opt.apply(pkt).fold(
                (err:TypedError<IOFailure>) -> Ended(End(err)),
                ()                          -> Await(Noise,rec)
              )(Automation.unit()))
            );
          }
    return __.arw().fn()(rec);
  }
}