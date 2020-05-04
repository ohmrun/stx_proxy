package stx.proxy.core.pack;

typedef ClientDef<A,B,R,E>  = ProxySum<A,B,Noise,Closed,R,E>;
typedef Client<A,B,R,E>     = ClientDef<A,B,R,E>;
