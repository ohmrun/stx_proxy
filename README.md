# Proxy
## An experimental rendition of Haskell Pipes in Haxe. 

A `Proxy` can be described as two coroutines bound together.

From a position inside of a function, one coroutine represents the interface to the incoming function parameter, the other represents the interface of the return value.

```haxe
enum ProxySum<A,B,X,Y,R,E>{
 Await(a:A,arw:Unary<B,Proxy<A,B,X,Y,R,E>>);
 Yield(y:Y,arw:Unary<X,Proxy<A,B,X,Y,R,E>>);
 Defer(ft:Belay<A,B,X,Y,R,E>);
 Ended(res:Chunk<R,E>);
}
```

`Yield` and `Await` are reflections of each other,
`Defer` is the abstraction of the runtime necessary to work in a polyglot environment.

Currently I'm working on `ProcessServer` and `ProcessClient` in [stx_asys](https://github.com/ohmrun/stx_asys/tree/develop) on a bunch of combinators that will allow composition of behaviours over console programs.