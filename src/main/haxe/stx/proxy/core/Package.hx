package stx.proxy.core;

#if test
  import stx.proxy.test.*;
#end

class Package{
  #if test
    static public function tests(){
      return [
        new ProxyTest()
      ];
    }
  #end
}
typedef Proxied<P,A,B,X,Y,R,E>    = stx.proxy.core.pack.Proxied<P,A,B,X,Y,R,E>;
typedef Proxify<P,A,B,X,Y,R,E>    = stx.proxy.core.pack.Proxify<P,A,B,X,Y,R,E>;
typedef Proxy<A,B,X,Y,R,E>        = stx.proxy.core.pack.Proxy<A,B,X,Y,R,E>;
typedef Request<A,B,M,N,Y,E>      = stx.proxy.core.pack.Request<A,B,M,N,Y,E>;
typedef Requested<X,A,B,M,N,Y,E>  = stx.proxy.core.pack.Requested<X,A,B,M,N,Y,E>;
typedef Server<X,Y,R,E>           = stx.proxy.core.pack.Server<X,Y,R,E>;

typedef Proxieds                = stx.proxy.core.body.Proxieds;
typedef Proxies                 = stx.proxy.core.body.Proxies;
typedef Pulls                   = stx.proxy.core.body.Pulls;
typedef Pushes                  = stx.proxy.core.body.Pushes;
typedef Requesteds              = stx.proxy.core.body.Requesteds;
typedef Requests                = stx.proxy.core.body.Requests;
typedef Respondeds              = stx.proxy.core.body.Respondeds;
typedef Responds                = stx.proxy.core.body.Responds;
typedef Yielders                = stx.proxy.core.body.Yielders;