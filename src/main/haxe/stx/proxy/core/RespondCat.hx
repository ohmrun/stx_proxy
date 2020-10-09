package stx.proxy.core;

typedef RespondCatDef<P,A,B,X,Y,R,E> = Unary<P,Proxy<A,B,X,Y,R,E>>;

abstract RespondCat<P,A,B,X,Y,R,E>(RespondCatDef<P,A,B,X,Y,R,E>) from RespondCatDef<P,A,B,X,Y,R,E> to RespondCatDef<P,A,B,X,Y,R,E>{
  static public var _(default,never) = RespondCatLift;
  public function new(self){
    this = self;
  }
}
class RespondCatLift{
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
  static public function compose<A,B,X,Y,M,N,P,Q,R,E>(fn:Unary<Q,Proxy<A,B,X,Y,P,E>>,fn0:Unary<Y,Proxy<A,B,M,N,X,E>>):Unary<Q,Proxy<A,B,M,N,P,E>>{
    return function(x:Q){
      return next(__.belay(fn.bindI(x)),fn0);
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
  static public function next<A,B,X,Y,M,N,R,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Unary<Y,Proxy<A,B,M,N,X,E>>):Proxy<A,B,M,N,R,E>{
    var go : Proxy<A,B,X,Y,R,E> -> Proxy<A,B,M,N,R,E>  = null;
        go = function(p1:Proxy<A,B,X,Y,R,E>){
          return switch (p1) {
            case Ended(res)   : Ended(res);
            case Await(a,arw) : Await(a,arw.then(go));
            case Yield(y,arw) : Proxy._.flat_map(Defer(Belay.lazy(fn.bindI(y))),arw.then(go));
            case Defer(ft)    : Defer(ft.mod(next.bind(_,fn)));
          }
        }
    return go(prx);
  }
}