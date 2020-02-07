package stx.proxy.core.body;

class Responds{
  //x' x a' a m a'
  @:noUsing static public function deferred<A,B,X,Y,E>(v:Future<Y>):Proxy<A,B,X,Y,X,E>{
    return Later(Receivers.fromFuture(v.map(v->pure(v))));
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
