package stx;

//Drain
/**
  Gabriel Gonzalez' "Haskell Pipes"
**/
typedef ProxySum<A,B,X,Y,R,E>             = stx.proxy.core.Proxy.ProxySum<A,B,X,Y,R,E>;
typedef Proxy<A,B,X,Y,R,E>                = stx.proxy.core.Proxy<A,B,X,Y,R,E>;

typedef Server<X,Y,R,E>                   = stx.proxy.core.Server<X,Y,R,E>;
typedef Client<A,B,R,E>                   = stx.proxy.core.Client<A,B,R,E>;

typedef ActuatorDef<Y,E>                  = stx.proxy.core.Actuator.ActuatorDef<Y,E>;
typedef Actuator<Y,E>                     = stx.proxy.core.Actuator<Y,E>;

typedef ProducerDef<Y,R,E>                = stx.proxy.core.Producer.ProducerDef<Y,R,E>;
typedef Producer<Y,R,E>                   = stx.proxy.core.Producer<Y,R,E>;

typedef ConsumerDef<B,R,E>                = stx.proxy.core.Consumer.ConsumerDef<B,R,E>;
typedef Consumer<B,R,E>                   = stx.proxy.core.Consumer<B,R,E>;

typedef DispatchDef<B,E>                  = Dispatch<B,E>;
typedef Dispatch<B,E>                     = ProxySum<Noise,B,Closed,Noise,Noise,E>;

typedef Defect<E>                         = stx.proxy.core.Defect<E>;
typedef Outlet<R,E>                       = stx.proxy.core.Outlet<R,E>;
typedef Access<Y,E>                       = stx.proxy.core.Access<Y,E>;  
typedef Recure<B,Y,R,E>                   = stx.proxy.core.Recure<B,Y,R,E>;

typedef ProxyCatDef<P0,A,B,X,Y,R,E>       = stx.proxy.core.ProxyCat.ProxyCatDef<P0,A,B,X,Y,R,E>;
typedef ProxyCat<P0,A,B,X,Y,R,E>          = stx.proxy.core.ProxyCat<P0,A,B,X,Y,R,E>;
typedef Closed                            = stx.proxy.core.Closed;
typedef Belay<A,B,X,Y,R,E>                = stx.proxy.core.Belay<A,B,X,Y,R,E>;

typedef Request<A,B,X,Y,R,E>              = stx.proxy.core.Request<A,B,X,Y,R,E>;
typedef RequestLift                       = stx.proxy.core.Request.RequestLift;
typedef RequestCat<P,A,B,X,Y,R,E>         = stx.proxy.core.RequestCat<P,A,B,X,Y,R,E>;
typedef RequestCatLift                    = stx.proxy.core.RequestCat.RequestCatLift;

typedef Respond<A,B,X,Y,R,E>              = stx.proxy.core.Respond<A,B,X,Y,R,E>;
typedef RespondLift                       = stx.proxy.core.Respond.RespondLift;
typedef RespondCat<P,A,B,X,Y,R,E>         = stx.proxy.core.RespondCat<P,A,B,X,Y,R,E>;
typedef RespondCatLift                    = stx.proxy.core.RespondCat.RespondCatLift;

typedef Pull<A,B,X,Y,R,E>                 = stx.proxy.core.Pull<A,B,X,Y,R,E>;
typedef PullLift                          = stx.proxy.core.Pull.PullLift;
typedef PullCat<P,A,B,X,Y,R,E>          = stx.proxy.core.PullCat<P,A,B,X,Y,R,E>;
typedef PullCatLift                     = stx.proxy.core.PullCat.PullCatLift;

typedef Push<A,B,X,Y,R,E>                 = stx.proxy.core.Push<A,B,X,Y,R,E>;
typedef PushLift                          = stx.proxy.core.Push.PushLift;
typedef PushCat<P,A,B,X,Y,R,E>          = stx.proxy.core.PushCat<P,A,B,X,Y,R,E>;
typedef PushCatLift                     = stx.proxy.core.PushCat.PushCatLift;


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
