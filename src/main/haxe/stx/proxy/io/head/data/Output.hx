package stx.proxy.io.head.data;

import stx.proxy.core.head.data.Client in ClientT;

typedef Output = Arrowlet<Packet,ClientT<Noise,Packet,Noise,IOFailure>>;
