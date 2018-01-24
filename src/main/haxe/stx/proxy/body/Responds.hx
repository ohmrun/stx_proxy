package stx.proxy.body;

class Responds{
  //x' x a' a m a'
  @:noUsing static public function deferred<A,B,X,Y>(v:Future<Y>):Proxy<A,B,X,Y,X>{
    return Later(v.map(pure));
  }
  //x' x a' a m a'
  @:noUsing static public function pure<A,B,X,Y>(v:Y):Proxy<A,B,X,Y,X>{
    return Yield(v,Ended);
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
  static public function responding<A,B,X,Y,M,N,P,Q,R>(fn:Arrowlet<Q,Proxy<A,B,X,Y,P>>,fn0:Arrowlet<Y,Proxy<A,B,M,N,X>>):Arrowlet<Q,Proxy<A,B,M,N,P>>{
    return function(x:Q){
      return Responds.responder(Later(fn.apply(x)),fn0);
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
  static public function responder<A,B,X,Y,M,N,R>(prx:Proxy<A,B,X,Y,R>,fn:Arrowlet<Y,Proxy<A,B,M,N,X>>):Proxy<A,B,M,N,R>{
    var go : Proxy<A,B,X,Y,R> -> Proxy<A,B,M,N,R>  = null;
        go = function(p1:Proxy<A,B,X,Y,R>){
          return switch (p1) {
            case Ended(res)   : Ended(res);
            case Await(a,arw) : Await(a,arw.then(go));
            case Yield(y,arw) : Proxies.flatMap(Later(fn.apply(y)),arw.then(go));
            case Later(ft)    : Later(ft.map(responder.bind(_,fn)));
          }
        }
    return go(prx);
  }
}
