# stx_proxy

This is an experimental rendition of Haskell Pipes in Haxe. 

```haxe
enum ProxySum<A,B,X,Y,R,E>{
 Await(a:A,arw:Unary<B,Proxy<A,B,X,Y,R,E>>);
 Yield(y:Y,arw:Unary<X,Proxy<A,B,X,Y,R,E>>);
 Defer(ft:Belay<A,B,X,Y,R,E>);
 Ended(res:Chunk<R,E>);
}
```