package stx.proxy.body;

class Requests{
  @:noUsing static public function pure<A,B,X,Y,R>(a:A):Proxy<A,B,X,Y,B>{
    return Await(a,Ended);
  }
  @:noUsing static public function deferred<A,B,X,Y,R>(a:Future<A>):Proxy<A,B,X,Y,B>{
    return Later(a.map(pure));
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
  static public function requesting<A,B,X,Y,M,N,O>(fn0:Arrowlet<X,Proxy<A,B,M,N,Y>>,fn1:Arrowlet<M,Proxy<X,Y,M,N,O>>):Arrowlet<M,Proxy<A,B,M,N,O>>{
    return function(c:M,cont0:Proxy<A,B,M,N,O>->Void){
      return fn1(c,
        function(prx1){
          var a = requester(fn0,prx1);
          cont0(a);
        }
      );
      return null;
      //return then(fn0,fn1(c);
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
  static public function requester<A,B,X,Y,M,N,O>(prx0:Arrowlet<X,Proxy<A,B,M,N,Y>>,prx1:Proxy<X,Y,M,N,O>):Proxy<A,B,M,N,O>{
    var go : Proxy<X,Y,M,N,O> -> Proxy<A,B,M,N,O> = null;
        go = function(prx2:Proxy<X,Y,M,N,O>):Proxy<A,B,M,N,O>{
          return switch (prx2){
            case Ended(res)   : Ended(res);
            case Await(a,arw) : Proxies.flatMap(Later(prx0.apply(a)),arw.then(go));
            case Yield(y,arw) : Yield(y,arw.then(go));
            case Later(ft)    : Later(ft.map(requester.bind(prx0)));
          }
        }
    return go(prx1);
  }
}