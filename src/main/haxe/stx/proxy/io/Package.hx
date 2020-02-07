package stx.proxy.io;

#if test
  import stx.proxy.io.test.*;
#end

typedef Inputs  = stx.proxy.io.body.Inputs;

typedef Input   = stx.proxy.io.pack.Input;
typedef Output  = stx.proxy.io.pack.Output;
//typedef Duplex  = Proxy<Packet,Packet,ByteSize,Noise,Noise,IOFailure>;


class Package{
  #if test
    static public function tests():Array<utest.Test>{
      return [
        new ProcessTest(),
      ];
    }
  #end
}