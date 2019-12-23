package stx.proxy.core.head.data;

import stx.proxy.core.Package.Proxy    in ProxyA;
import stx.proxy.core.Package.Proxify  in ProxifyA;

enum Proxy<A,B,X,Y,R,E>{
  Await(v:A,arw:Arrowlet<B,ProxyA<A,B,X,Y,R,E>>);
  Yield(v:Y,arw:Arrowlet<X,ProxyA<A,B,X,Y,R,E>>);
  Later(ft:UIO<ProxyA<A,B,X,Y,R,E>>);
  Ended(res:Chunk<R,E>);
}
