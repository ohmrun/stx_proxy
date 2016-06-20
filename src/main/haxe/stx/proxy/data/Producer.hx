package stx.proxy.data;

import tink.core.Noise;

typedef Producer<Y,R> = Proxy<Closed,Noise,Noise,Y,R>;