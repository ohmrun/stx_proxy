package stx.proxy.core.body;

class Requesteds{
  static public function asRequested<X,A,B,M,N,Y,E>(fn0:Arrowlet<X,Proxy<A,B,M,N,Y,E>>):Requested<X,A,B,M,N,Y,E>{
    return new Requested(fn0);
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
  static public function compose<A,B,X,Y,M,N,O,E>(fn0:Arrowlet<X,Proxy<A,B,M,N,Y,E>>,fn1:Arrowlet<M,Proxy<X,Y,M,N,O,E>>):Arrowlet<M,Proxy<A,B,M,N,O,E>>{
    return function(c:M,cont0:Strand<Proxy<A,B,M,N,O,E>>){
      return fn1.withInput(c,
        function(prx1){
          var a = then(fn0,prx1);
          return cont0.apply(a);
        }
      );
    }
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
  static public function then<A,B,X,Y,M,N,O,E>(prx0:Arrowlet<X,Proxy<A,B,M,N,Y,E>>,prx1:Proxy<X,Y,M,N,O,E>):Proxy<A,B,M,N,O,E>{
    var go : Proxy<X,Y,M,N,O,E> -> Proxy<A,B,M,N,O,E> = null;
        go = function(prx2:Proxy<X,Y,M,N,O,E>):Proxy<A,B,M,N,O,E>{
          return switch (prx2){
            case Ended(res)   : Ended(res);
            case Await(a,arw) : Proxies.flatMap(Later(prx0.apply(a)),arw.then(go));
            case Yield(y,arw) : Yield(y,arw.then(go));
            case Later(ft)    : Later(ft.map(then.bind(prx0)));
          }
        }
    return go(prx1);
  }
}