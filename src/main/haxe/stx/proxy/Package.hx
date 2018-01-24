package stx.proxy;

typedef Proxied<P,A,B,X,Y,R>    = stx.proxy.pack.Proxied<P,A,B,X,Y,R>;
typedef Proxy<A,B,X,Y,R>        = stx.proxy.pack.Proxy<A,B,X,Y,R>;
typedef Request<A,B,M,N,Y>      = stx.proxy.pack.Request<A,B,M,N,Y>;
typedef Requested<X,A,B,M,N,Y>  = stx.proxy.pack.Requested<X,A,B,M,N,Y>;
typedef Server<X,Y,R>           = stx.proxy.pack.Server<X,Y,R>;

typedef Proxieds                = stx.proxy.body.Proxieds;
typedef Proxies                 = stx.proxy.body.Proxies;
typedef Pulls                   = stx.proxy.body.Pulls;
typedef Pushes                  = stx.proxy.body.Pushes;
typedef Requesteds              = stx.proxy.body.Requesteds;
typedef Requests                = stx.proxy.body.Requests;
typedef Respondeds              = stx.proxy.body.Respondeds;
typedef Responds                = stx.proxy.body.Responds;
typedef Yields                  = stx.proxy.body.Yields;