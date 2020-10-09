package stx.proxy.core;


typedef RequestCatDef<P,A,B,X,Y,R,E> = Unary<P,Proxy<A,B,X,Y,R,E>>;

abstract RequestCat<P,A,B,X,Y,R,E>(RequestCatDef<P,A,B,X,Y,R,E>) from RequestCatDef<P,A,B,X,Y,R,E> to RequestCatDef<P,A,B,X,Y,R,E>{
  static public var _(default,never) = RequestCatLift;
  public function new(self){
    this = self;
  }
}
class RequestCatLift{
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
    return (m:M) -> Belay.lazy(
      () -> next(fn0,fn1(m))
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
  @:noUsing static public function next<A,B,X,Y,M,N,O,E>(prx0:Unary<X,Proxy<A,B,M,N,Y,E>>,prx1:Proxy<X,Y,M,N,O,E>):Proxy<A,B,M,N,O,E>{
    var go : Proxy<X,Y,M,N,O,E> -> Proxy<A,B,M,N,O,E> = null;
        go = function(prx2:Proxy<X,Y,M,N,O,E>):Proxy<A,B,M,N,O,E>{
          return switch (prx2){
            case Ended(res)   : Ended(res);
            case Await(a,arw) : Proxy._.flat_map(__.belay(prx0.bindI(a)),arw.then(go));
            case Yield(y,arw) : Yield(y,arw.then(go));
            case Defer(ft)    : __.belay(ft.mod(next.bind(prx0)));
          }
        }
    return go(prx1);
  }
}