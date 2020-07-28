package stx.proxy;

//Drain
/**
  Gabriel Gonzalez' "Haskell Pipes"
**/
typedef ProxySum<A,B,X,Y,R,E>             = stx.proxy.core.pack.Proxy.ProxySum<A,B,X,Y,R,E>;
typedef Proxy<A,B,X,Y,R,E>                = stx.proxy.core.pack.Proxy<A,B,X,Y,R,E>;

typedef Server<X,Y,R,E>                   = stx.proxy.core.pack.Server<X,Y,R,E>;
typedef Client<A,B,R,E>                   = stx.proxy.core.pack.Client<A,B,R,E>;

typedef ActuatorDef<Y,E>                  = stx.proxy.core.pack.Actuator.ActuatorDef<Y,E>;
typedef Actuator<Y,E>                     = stx.proxy.core.pack.Actuator<Y,E>;

typedef ProducerDef<Y,R,E>                = stx.proxy.core.pack.Producer.ProducerDef<Y,R,E>;
typedef Producer<Y,R,E>                   = stx.proxy.core.pack.Producer<Y,R,E>;

typedef ConsumerDef<B,R,E>                = stx.proxy.core.pack.Consumer.ConsumerDef<B,R,E>;
typedef Consumer<B,R,E>                   = stx.proxy.core.pack.Consumer<B,R,E>;

typedef DispatchDef<B,E>                  = Dispatch<B,E>;
typedef Dispatch<B,E>                     = ProxySum<Noise,B,Closed,Noise,Noise,E>;

typedef Defect<E>                         = stx.proxy.core.pack.Defect<E>;
typedef Outlet<R,E>                       = stx.proxy.core.pack.Outlet<R,E>;
typedef Access<Y,E>                       = stx.proxy.core.pack.Access<Y,E>;  
typedef Recure<B,Y,R,E>                   = stx.proxy.core.pack.Recure<B,Y,R,E>;

typedef ProxyCatDef<P0,A,B,X,Y,R,E>       = stx.proxy.core.pack.ProxyCat.ProxyCatDef<P0,A,B,X,Y,R,E>;
typedef ProxyCat<P0,A,B,X,Y,R,E>          = stx.proxy.core.pack.ProxyCat<P0,A,B,X,Y,R,E>;
typedef Closed                            = stx.proxy.core.pack.Closed;
typedef Belay<A,B,X,Y,R,E>                = stx.proxy.core.pack.Belay<A,B,X,Y,R,E>;

typedef Request<A,B,X,Y,R,E>              = stx.proxy.core.pack.Request<A,B,X,Y,R,E>;
typedef RequestLift                       = stx.proxy.core.pack.Request.RequestLift;
typedef RequestCat<P,A,B,X,Y,R,E>         = stx.proxy.core.pack.RequestCat<P,A,B,X,Y,R,E>;
typedef RequestCatLift                    = stx.proxy.core.pack.RequestCat.RequestCatLift;

typedef Respond<A,B,X,Y,R,E>              = stx.proxy.core.pack.Respond<A,B,X,Y,R,E>;
typedef RespondLift                       = stx.proxy.core.pack.Respond.RespondLift;
typedef RespondCat<P,A,B,X,Y,R,E>         = stx.proxy.core.pack.RespondCat<P,A,B,X,Y,R,E>;
typedef RespondCatLift                    = stx.proxy.core.pack.RespondCat.RespondCatLift;

typedef Pull<A,B,X,Y,R,E>                 = stx.proxy.core.pack.Pull<A,B,X,Y,R,E>;
typedef PullLift                          = stx.proxy.core.pack.Pull.PullLift;
typedef PullCat<P,A,B,X,Y,R,E>          = stx.proxy.core.pack.PullCat<P,A,B,X,Y,R,E>;
typedef PullCatLift                     = stx.proxy.core.pack.PullCat.PullCatLift;

typedef Push<A,B,X,Y,R,E>                 = stx.proxy.core.pack.Push<A,B,X,Y,R,E>;
typedef PushLift                          = stx.proxy.core.pack.Push.PushLift;
typedef PushCat<P,A,B,X,Y,R,E>          = stx.proxy.core.pack.PushCat<P,A,B,X,Y,R,E>;
typedef PushCatLift                     = stx.proxy.core.pack.PushCat.PushCatLift;


class LiftProxyCommands{
  static public function belay<A,B,X,Y,R,E>(wildcard:Wildcard,belay:Belay<A,B,X,Y,R,E>):Proxy<A,B,X,Y,R,E>{
    return Defer(belay);
  }  
  static public function await<A,B,X,Y,R,E>(wildcard:Wildcard,await:A,recure:B->Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y,R,E>{
    return Await(await,recure);
  }
  static public function yield<A,B,X,Y,R,E>(wildcard:Wildcard,yield:Y,recure:X->Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y,R,E>{
    return Yield(yield,recure);
  }
  static public function ended<A,B,X,Y,R,E>(wildcard:Wildcard,ended:Chunk<R,E>):Proxy<A,B,X,Y,R,E>{
    return Ended(ended);
  }
}
