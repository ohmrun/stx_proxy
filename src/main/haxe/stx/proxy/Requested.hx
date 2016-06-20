package stx.proxy;

import stx.Proxy in AProxy;
import stx.proxy.data.Proxy;
using stx.async.Arrowlet;

@:forward abstract Request<A,B,M,N,Y>(AProxy<A,B,M,N,Y>) from AProxy<A,B,M,N,Y> to AProxy<A,B,M,N,Y>{
  public function new(self){
    this = self;
  }
}
@:callable @:forward abstract Requested<X,A,B,M,N,Y>(Arrowlet<X,Proxy<A,B,M,N,Y>>) from Arrowlet<X,Proxy<A,B,M,N,Y>> to Arrowlet<X,Proxy<A,B,M,N,Y>>{
    public function new(self){
      this = self;
    }
    public function compose<O>(fn1:Arrowlet<M,Proxy<X,Y,M,N,O>>):Requested<M,A,B,M,N,O>{
      return Requesteds.compose(this,fn1);
    }
    public function then<O>(prx1:Proxy<X,Y,M,N,O>):Request<A,B,M,N,O>{
      return Requesteds.then(this,prx1);
    }
}
class Requesteds{
  static public function asRequested<X,A,B,M,N,Y>(fn0:Arrowlet<X,Proxy<A,B,M,N,Y>>):Requested<X,A,B,M,N,Y>{
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
  static public function compose<A,B,X,Y,M,N,O>(fn0:Arrowlet<X,Proxy<A,B,M,N,Y>>,fn1:Arrowlet<M,Proxy<X,Y,M,N,O>>):Arrowlet<M,Proxy<A,B,M,N,O>>{
    return function(c:M,cont0:Proxy<A,B,M,N,O>->Void){
      return fn1(c,
        function(prx1){
          var a = then(fn0,prx1);
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
  static public function then<A,B,X,Y,M,N,O>(prx0:Arrowlet<X,Proxy<A,B,M,N,Y>>,prx1:Proxy<X,Y,M,N,O>):Proxy<A,B,M,N,O>{
    var go : Proxy<X,Y,M,N,O> -> Proxy<A,B,M,N,O> = null;
        go = function(prx2:Proxy<X,Y,M,N,O>):Proxy<A,B,M,N,O>{
          return switch (prx2){
            case Ended(res)   : Ended(res);
            case Await(a,arw) : stx.Proxy.Proxies.flatMap(Later(prx0.apply(a)),arw.then(go));
            case Yield(y,arw) : Yield(y,arw.then(go));
            case Later(ft)    : Later(ft.then(then.bind(prx0)));
          }
        }
    return go(prx1);
  }
}
