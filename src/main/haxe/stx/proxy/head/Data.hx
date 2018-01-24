package stx.proxy.head;

typedef Client<A,B,R>       = stx.proxy.head.data.Client<A,B,R>;
typedef Closed              = stx.proxy.head.data.Closed;
typedef Consumer<B,R>       = stx.proxy.head.data.Consumer<B,R>;
typedef Effect<R>           = stx.proxy.head.data.Effect<R>;
typedef Pipe<B,Y,R>         = stx.proxy.head.data.Pipe<B,Y,R>;
typedef Producer<Y,R>       = stx.proxy.head.data.Producer<Y,R>;
typedef Proxy<A,B,X,Y,R>    = stx.proxy.head.data.Proxy<A,B,X,Y,R>;
typedef Server<X,Y,R>       = stx.proxy.head.data.Server<X,Y,R>;