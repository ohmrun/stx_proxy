package stx.proxy.head.data;

import stx.proxy.Package.Proxy in AProxy;

enum Proxy<A,B,X,Y,R>{
  Await(v:A,arw:Arrowlet<B,AProxy<A,B,X,Y,R>>);
  Yield(v:Y,arw:Arrowlet<X,AProxy<A,B,X,Y,R>>);
  Later(ft:Future<AProxy<A,B,X,Y,R>>);
  Ended(res:R);
}
