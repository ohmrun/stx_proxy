package stx.proxy.core;

/**
  Gabriel Gonzalez' "Haskell Pipes"
**/
typedef ProxySum<A,B,X,Y,R,E>             = stx.proxy.core.pack.Proxy.ProxySum<A,B,X,Y,R,E>;
typedef Proxy<A,B,X,Y,R,E>                = stx.proxy.core.pack.Proxy<A,B,X,Y,R,E>;

//typedef Proxied<P,A,B,X,Y,R,E>    = stx.proxy.core.pack.Proxied<P,A,B,X,Y,R,E>;
//typedef Proxify<P,A,B,X,Y,R,E>            = stx.proxy.core.pack.Proxify<P,A,B,X,Y,R,E>;

typedef Request<A,B,M,N,Y,E>              = stx.proxy.core.pack.Request<A,B,M,N,Y,E>;
typedef Requested<X,A,B,M,N,Y,E>          = stx.proxy.core.pack.Requested<X,A,B,M,N,Y,E>;
typedef Server<X,Y,R,E>                   = stx.proxy.core.pack.Server<X,Y,R,E>;
typedef Effect<R,E>                       = stx.proxy.core.pack.Effect<R,E>;

typedef Pipe<B,Y,R,E>                     = stx.proxy.core.pack.Pipe<B,Y,R,E>;
typedef Producer<Y,R,E>                   = stx.proxy.core.pack.Producer<Y,R,E>;
typedef Consumer<B,R,E>                   = stx.proxy.core.pack.Consumer<B,R,E>;
typedef Source<Y,E>                       = stx.proxy.core.pack.Source<Y,E>;

typedef ProxyArrowDef<P0,A,B,X,Y,R,E>     = stx.proxy.core.pack.ProxyArrow.ProxyArrowDef<P0,A,B,X,Y,R,E>;
typedef ProxyArrow<P0,A,B,X,Y,R,E>        = stx.proxy.core.pack.ProxyArrow<P0,A,B,X,Y,R,E>;
typedef Closed                            = stx.proxy.core.pack.Closed;

//typedef Proxieds                  = stx.proxy.core.body.Proxieds;
typedef Proxies                   = stx.proxy.core.body.Proxies;
typedef Pulls                     = stx.proxy.core.body.Pulls;
typedef Pushes                    = stx.proxy.core.body.Pushes;
typedef Requesteds                = stx.proxy.core.body.Requesteds;
typedef Requests                  = stx.proxy.core.body.Requests;
typedef Respondeds                = stx.proxy.core.body.Respondeds;
typedef Responds                  = stx.proxy.core.body.Responds;
typedef Yielders                  = stx.proxy.core.body.Yielders;


typedef Sources                  = stx.proxy.core.head.Sources;

class Requested{
  /*{-| Compose two folds, creating a new fold

  > (f \>\ g) x = f >\\ g x

      ('\>\') is the composition operator of the request category.
  -}
  (\>\)
      :: (Monad m)
      => (b' -> Proxy a' a y' y m b)
      -> (c' -> Proxy b' b y' y m c)
      -> (c' -> Proxy a' a y' y m c)
  (fb' \>\ fc') c' = fb' >\\ fc' c'
  {-# INLINABLE (\>\) #-}*/
  static public function compose<A,B,X,Y,M,N,O,E>(fn0:Unary<X,Proxy<A,B,M,N,Y,E>>,fn1:Unary<M,Proxy<X,Y,M,N,O,E>>):Unary<M,Proxy<A,B,M,N,O,E>>{
    return __.arw().cont()(
      (c:M,cont0:Strand<Proxy<A,B,M,N,O,E>>) -> 
        fn1.prepare(c,(prx1,auto) -> cont0(then(fn0,prx1),auto))
    );
  }
  /*  {-| @(f >\\\\ p)@ replaces each 'request' in @p@ with @f@.

      Point-ful version of ('\>\')
  -}
  (>\\)
      :: (Monad m)
      => (b' -> Proxy a' a y' y m b)
      ->        Proxy b' b y' y m c

      ->        Proxy a' a y' y m c
  fb' >\\ p0 = go p0
    where
      go p = case p of
          Request b' fb  -> fb' b' >>= \b -> go (fb b)
          Respond x  fx' -> Respond x (\x' -> go (fx' x'))
          M          m   -> M (m >>= \p' -> return (go p'))
          Pure       a   -> Pure a*/
  static public function then<A,B,X,Y,M,N,O,E>(prx0:Unary<X,Proxy<A,B,M,N,Y,E>>,prx1:Proxy<X,Y,M,N,O,E>):Proxy<A,B,M,N,O,E>{
    var go : Proxy<X,Y,M,N,O,E> -> Proxy<A,B,M,N,O,E> = null;
        go = function(prx2:Proxy<X,Y,M,N,O,E>):Proxy<A,B,M,N,O,E>{
          return switch (prx2){
            case Ended(res)   : Ended(res);
            case Await(a,arw) : Proxies.fmap(Later(prx0.receive(a)),arw.then(go));
            case Yield(y,arw) : Yield(y,arw.then(go));
            case Later(ft)    : Later(ft.map(then.bind(prx0)));
          }
        }
    return go(prx1);
  }
}
class Pull{
  @:noUsing static public function pure<A,B,X,Y,R,E>(a:A):Proxy<A,B,A,B,R,E>{
    return Await(a,
      function(b:B){
        return Yield(b,pure);  
      }
    );
  }
  @:noUsing static public function gen<A,B,R,E>(thk:Thunk<Option<A>>):Proxy<A,B,A,B,R,E>{
    var fn = Options._.fold.bind(
      (v) -> Await(v,__.arw().fn()((_) -> gen(thk))),
      ()  -> Ended(Tap)
    );
    return Later(
      Receiver.lift(
        (next) -> {
          next(thk());
          return Automation.unit();
        } 
      ).map(fn)
    );
  }
  @:noUsing static public function signal<A,B,X,Y,R,E>(a:A):Proxy<A,B,A,B,R,E>{
    return Await(a,
      function(b:B){
        return signal(a);
      }
    );
  }
  @:noUsing static public function fromSignal<A,B,X,Y,R,E>(sig:Signal<A>):Proxy<A,B,A,B,R,E>{
    return Later(
      Receiver.inj.fromFuture(sig.nextTime()).map(
        (v:A) -> Await(v,__.arw().cont()((b:B,cont:Strand<Proxy<A,B,A,B,R,E>>) ->
          cont(fromSignal(sig),Automation.unit())
        ))
      )
    );
  }
  @:noUsing static public function fromArray<A,B,X,Y,R,E>(arr:Array<A>):Proxy<A,B,A,B,R,E>{
    return if(arr.length == 0){
      Ended(Tap);
    }else{
      var next  = arr.copy();
      var fst   = next.shift();
      var rst   = next;
      return Await(fst,
        __.arw().cont()(function(b:B,cont:Strand<Proxy<A,B,A,B,R,E>>){
          return cont(fromArray(rst),Automation.unit());
        })
      );
    }
  }
  /*
  (>->)
    :: (Monad m)
    => ( b' -> Proxy a' a b' b m r)
    -> (_c' -> Proxy b' b c' c m r)
    -> (_c' -> Proxy a' a c' c m r)
  (fb' >-> fc') c' = fb' ->> fc' c'
  {-# INLINABLE (>->) #-}
  */
  //(>->)
  static public function pulling<A,B,C,D,X,Y,R,E>(prx0:Arrowlet<X,Proxy<A,B,X,Y,R,E>>,prx1:Arrowlet<C,Proxy<X,Y,C,D,R,E>>):Arrowlet<C,Proxy<A,B,C,D,R,E>>{
    return __.arw().cont()((c:C,cont) -> 
      prx1.then(puller.bind(prx0)).prepare(c,cont)
    );
  }
  /**
    (->>)
      :: (Monad m)
      => (b' -> Proxy a' a b' b m r)
      ->        Proxy b' b c' c m r
      ->        Proxy a' a c' c m r
  fb' ->> p = case p of
      Request b' fb  -> fb' b' >>~ fb
      Respond c  fc' -> Respond c (\c' -> fb' ->> fc' c')
      M          m   -> M (m >>= \p' -> return (fb' ->> p'))
      Pure       r   -> Pure r
  {-# INLINABLE (->>) #-}
  */
  //(->>)
  static public function puller<A,B,C,D,X,Y,R,E>(prx0:Arrowlet<X,Proxy<A,B,X,Y,R,E>>,prx1:Proxy<X,Y,C,D,R,E>):Proxy<A,B,C,D,R,E>{
    return switch (prx1){
      case Await(a,arw) : Pushes.pusher(Later(prx0.receive(a)),arw);
      case Yield(y,arw) : Yield(y,function(c:C){ return Pulls.puller(prx0,Later(arw.receive(c)));});
      case Ended(res)   : Ended(res);
      case Later(ft)    : Later(ft.map(puller.bind(prx0)));
    }
  }
}
class Push{
  @:noUsing static public function pure<A,B,R,E>(b:B):Proxy<A,B,A,B,R,E>{
    return Yield(b,
      __.arw().fn()(function(a:A){
        return Await(a,pure);
      })
    );
  }
  @:noUsing static public function fromSignal<A,B,X,Y,R,E>(sig:Signal<B>):Proxy<A,B,A,B,R,E>{
    return Later(
      Receiver.lift(
        (next) -> {
          var a     = Receiver.inj().fromFuture(sig.nextTime());
          var b     = a.map(
            (b) -> Yield(b,
              __.arw().cont()(
                (b,cont) -> cont(fromSignal(sig),Automation.unit())
              )  
            )
          );
          return b(next);
        }
      )
    );
  }
  /*
  */
  
  /*
  (>~>)
      :: (Monad m)
      => (_a -> Proxy a' a b' b m r)
      -> ( b -> Proxy b' b c' c m r)
      -> (_a -> Proxy a' a c' c m r)
  (fa >~> fb) a = fa a >>~ fb
  {-# INLINABLE (>~>) #-}
  */
  //(>~>)
  static public function pushing<A,B,X,Y,C,D,R,E>(prx0:Arrowlet<B,Proxy<A,B,X,Y,R,E>>,prx1:Arrowlet<Y,Proxy<X,Y,C,D,R,E>>):Arrowlet<B,Proxy<A,B,C,D,R,E>>{
    return __.arw().cont()((b:B,cont:Strand<Proxy<A,B,C,D,R,E>>) ->
      prx0.postfix(
        (br) -> Pushes.pusher(br,prx1)
      ).prepare(b,cont));
  }
  /*
  {-| @(p >>~ f)@ pairs each 'respond' in @p@ with a 'request' in @f@.

    Point-ful version of ('>~>')
  -}
  (>>~)
      :: (Monad m)
      =>       Proxy a' a b' b m r
      -> (b -> Proxy b' b c' c m r)
      ->       Proxy a' a c' c m r
  p >>~ fb = case p of
      Request a' fa  -> Request a' (\a -> fa a >>~ fb)
      Respond b  fb' -> fb' ->> fb b
      M          m   -> M (m >>= \p' -> return (p' >>~ fb))
      Pure       r   -> Pure r
  {-# INLINABLE (>>~) #-}
  */
  //(>>~)
  static public function pusher<A,B,C,D,X,Y,R,E>(prx0:Proxy<A,B,X,Y,R,E>,prx1:Arrowlet<Y,Proxy<X,Y,C,D,R,E>>):Proxy<A,B,C,D,R,E>{
    return switch(prx0){
      case Ended(res)   : Ended(res);
      case Yield(y,arw) : Later(prx1.then(__.arw().fn()((x) -> Pulls.puller(arw,x))).receive(y));
      case Await(a,arw) : Await(a,arw.then(Pushes.pusher.bind(_,prx1)));
      case Later(ft)    : Later(ft.map(pusher.bind(_,prx1)));
    }
  }
}
class Request{
  @:noUsing static public function pure<A,B,X,Y,R,E>(a:A):Proxy<A,B,X,Y,B,E>{
    return Await(a,Val.fn().then(Ended));
  }
  @:noUsing static public function deferred<A,B,X,Y,R,E>(a:Future<A>):Proxy<A,B,X,Y,B,E>{
    return Later(Receiver.inj.fromFuture(a.map(pure)));
  }
  /*{-| Compose two folds, creating a new fold

  > (f \>\ g) x = f >\\ g x

      ('\>\') is the composition operator of the request category.
  -}
  (\>\)
      :: (Monad m)
      => (b' -> Proxy a' a y' y m b)
      -> (c' -> Proxy b' b y' y m c)
      -> (c' -> Proxy a' a y' y m c)
  (fb' \>\ fc') c' = fb' >\\ fc' c'
  {-# INLINABLE (\>\) #-}*/
  static public function requesting<A,B,X,Y,M,N,O,E>(fn0:Arrowlet<X,Proxy<A,B,M,N,Y,E>>,fn1:Arrowlet<M,Proxy<X,Y,M,N,O,E>>):Arrowlet<M,Proxy<A,B,M,N,O,E>>{
    return (function(c:M,cont0:Strand<Proxy<A,B,M,N,O,E>>){
      return fn1.prepare(c,
        (prx1,auto)-> cont0(requester(fn0,prx1),auto)
      );
    }).broker(
      (F) -> __.arw().cont()
    );
  }
  /*  {-| @(f >\\\\ p)@ replaces each 'request' in @p@ with @f@.

      Point-ful version of ('\>\')
  -}
  (>\\)
      :: (Monad m)
      => (b' -> Proxy a' a y' y m b)
      ->        Proxy b' b y' y m c

      ->        Proxy a' a y' y m c
  fb' >\\ p0 = go p0
    where
      go p = case p of
          Request b' fb  -> fb' b' >>= \b -> go (fb b)
          Respond x  fx' -> Respond x (\x' -> go (fx' x'))
          M          m   -> M (m >>= \p' -> return (go p'))
          Pure       a   -> Pure a*/
  static public function requester<A,B,X,Y,M,N,O,E>(prx0:Arrowlet<X,Proxy<A,B,M,N,Y,E>>,prx1:Proxy<X,Y,M,N,O,E>):Proxy<A,B,M,N,O,E>{
    var go : Proxy<X,Y,M,N,O,E> -> Proxy<A,B,M,N,O,E> = null;
        go = function(prx2:Proxy<X,Y,M,N,O,E>):Proxy<A,B,M,N,O,E>{
          return switch (prx2){
            case Ended(res)   : Ended(res);
            case Await(a,arw) : Proxies.fmap(Later(prx0.receive(a)),arw.then(go));
            case Yield(y,arw) : Yield(y,arw.then(go));
            case Later(ft)    : Later(ft.map(requester.bind(prx0)));
          }
        }
    return go(prx1);
  }
}
class Respond{
  //x' x a' a m a'
  @:noUsing static public function deferred<A,B,X,Y,E>(v:Future<Y>):Proxy<A,B,X,Y,X,E>{
    return Later(Receiver.inj.fromFuture(v.map(v->pure(v))));
  }
  //x' x a' a m a'
  @:noUsing static public function pure<A,B,X,Y,E>(v:Y):Proxy<A,B,X,Y,X,E>{
    return Yield(v,__.arw().fn()(Val.fn().then(Ended)));
  }
  /*{-| Compose two unfolds, creating a new unfold

  > (f />/ g) x = f x //> g

      ('/>/') is the composition operator of the respond category.
  -}
  (/>/)
      :: (Monad m)
      => (a -> Proxy x' x b' b m a')
      -> (b -> Proxy x' x c' c m b')
      -> (a -> Proxy x' x c' c m a')
  (fa />/ fb) a = fa a //> fb
  {-# INLINABLE (/>/) #-}*/
  static public function responding<A,B,X,Y,M,N,P,Q,R,E>(fn:Arrowlet<Q,Proxy<A,B,X,Y,P,E>>,fn0:Arrowlet<Y,Proxy<A,B,M,N,X,E>>):Arrowlet<Q,Proxy<A,B,M,N,P,E>>{
    return function(x:Q){
      return Responds.responder(Later(fn.receive(x)),fn0);
    }
  }
  /*{-| @(p \/\/> f)@ replaces each 'respond' in @p@ with @f@.

      Point-ful version of ('/>/')
  -}
  (//>)
      :: (Monad m)
      =>       Proxy x' x b' b m a'
      -> (b -> Proxy x' x c' c m b')
      ->       Proxy x' x c' c m a'
  p0 //> fb = go p0
    where
      go p = case p of
          Request x' fx  -> Request x' (\x -> go (fx x))
          Respond b  fb' -> fb b >>= \b' -> go (fb' b')
          M          m   -> M (m >>= \p' -> return (go p'))
          Pure       a   -> Pure a*/
  static public function responder<A,B,X,Y,M,N,R,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Arrowlet<Y,Proxy<A,B,M,N,X,E>>):Proxy<A,B,M,N,R,E>{
    var go : Proxy<A,B,X,Y,R,E> -> Proxy<A,B,M,N,R,E>  = null;
        go = function(p1:Proxy<A,B,X,Y,R,E>){
          return switch (p1) {
            case Ended(res)   : Ended(res);
            case Await(a,arw) : Await(a,arw.then(go));
            case Yield(y,arw) : Proxies.fmap(Later(fn.receive(y)),arw.then(go));
            case Later(ft)    : Later(ft.map(responder.bind(_,fn)));
          }
        }
    return go(prx);
  }
}

class Yielder{
  @:noUsing static public function map<A,B,X,Y,R,Y1,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Y->Y1):Proxy<A,B,X,Y1,R,E>{
    return (function rec(prx:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y1,R,E>{
      return switch (prx) {
        case Yield(y,arw) : Yield(fn(y),arw.then(map.bind(_,fn)));
        case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
        case Ended(res)   : Ended(res);
        case Later(ft)    : Later(ft.map(map.bind(_,fn)));
      }
    })(prx);
  }
  // @:noUsing static public function map_a<A,B,X,Y,R,Y1,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Arrowlet<Y,Y1>):Proxy<A,B,X,Y1,R,E>{
  //   return (function rec(prx:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y1,R,E>{
  //     return switch (prx) {
  //       case Yield(y,arw) :
  //         Later(
  //           fn.receive(y).map(
  //             (y1) -> Yield(y1,arw.then(map_a.bind(_,fn)))
  //           )
  //         );
  //       case Await(a,arw) : Await(a,arw.then(map_a.bind(_,fn)));
  //       case Ended(res)   : Ended(res);
  //       case Later(ft)    : Later(ft.map(map_a.bind(_,fn)));
  //     }
  //   })(prx);
  // }
  @:noUsing static public function tap<A,B,X,Y,R,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Y->Void):Proxy<A,B,X,Y,R,E>{
    return map(prx,function(x) {fn(x);return x;});
  }
}
class Proxieds{
  static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1,E>(lhs:Unary<P0,Proxy<A0,B0,X0,Y0,R0,E>>,rhs:Unary<R0,Proxy<A1,B1,X1,Y1,R1,E>>):Unary<P0,Proxy<A1,B1,X1,Y1,R1,E>>{
    return (p0:P0) ->
      lhs.then(
        (p) -> switch(p){
          case Ended(r) : 
            r.fold(
              (x) -> Later(rhs.suspend(x)),
              (e) -> Ended(End(e)),
              ()  -> Ended(Tap)
            );
          default : Later(then.bind(lhs,rhs));
        }
      );
  }
}
