package stx;

import tink.CoreApi;

using stx.async.Arrowlet;

import stx.proxy.data.Proxy in TProxy;

import stx.proxy.Yield;

abstract Proxy<A,B,X,Y,R>(TProxy<A,B,X,Y,R>) from TProxy<A,B,X,Y,R> to TProxy<A,B,X,Y,R>{
  public function new(v){
    this = v;
  }
  public function flatMap<O>(fn:Arrowlet<R,Proxy<A,B,X,Y,O>>):Proxy<A,B,X,Y,O>{
    return Proxies.flatMap(this,fn);
  }
  public function reflect():Proxy<Y,X,B,A,R>{
    return Proxies.reflect(this);
  }
  /*
  public function asYield():Yield<A,B,X,Y,R>{
    return new Yield(this);
  }*/

  @:noUsing static public function pull<A,B,X,Y,R>(a:A):Proxy<A,B,A,B,R>{
    return Pulls.pure(a);
  }
  //push :: Monad m => a -> Proxy a' a a' a m r
  @:noUsing static public function push<A,B,R>(b:B):Proxy<A,B,A,B,R>{
    return Pushes.pure(b);
  }
  @:noUsing static public function request<A,B,X,Y,R>(a:A):Proxy<A,B,X,Y,B>{
    return Requests.pure(a);
  }
  @:noUsing static public function respond<A,B,X,Y>(y:Y):Proxy<A,B,X,Y,X>{
    return Responds.pure(y);
  }
}

class Proxies{
  static public function flatMap<A,B,X,Y,R,O>(prx:Proxy<A,B,X,Y,R>,fn:Arrowlet<R,Proxy<A,B,X,Y,O>>):Proxy<A,B,X,Y,O>{
    return switch (prx) {
      case Await(a,arw) : Await(a,arw.then(flatMap.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(flatMap.bind(_,fn)));
      case Ended(res)   : Later(fn.apply(res));
      case Later(ft)    : Later(ft.map(function(pr) return flatMap(pr,fn)));
    }
  }
  static public function map<A,B,X,Y,R,O>(prx:Proxy<A,B,X,Y,R>,fn:R->O):Proxy<A,B,X,Y,O>{
    return switch (prx) {
      case Ended(res)   : Ended(fn(res));
      case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
      case Yield(y,arw) : Yield(y,arw.then(map.bind(_,fn)));
      case Later(ft)    : Later(ft.map(map.bind(_,fn)));
    }

  }
  static public function reflect<A,B,X,Y,R>(prx:Proxy<A,B,X,Y,R>):Proxy<Y,X,B,A,R>{
    return switch(prx) {
      case Await(a,arw) : Yield(a,arw.then(reflect));
      case Yield(a,arw) : Await(a,arw.then(reflect));
      case Ended(r)     : Ended(r);
      case Later(prx)   : Later(prx.map(reflect));
    }
  }
  static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1>(lhs:Arrowlet<P0,Proxy<A0,B0,X0,Y0,R0>>,rhs:Arrowlet<R0,Proxy<A1,B1,X1,Y1,R1>>):Arrowlet<P0,Proxy<A1,B1,X1,Y1,R1>>{
    return function(p0:P0,cont){
      lhs.then(
        function(p,cont){
          switch(p){
            case Ended(r) : rhs(r,cont);
            default       : then(lhs,rhs)(p0,cont);
          }
          return function(){};
        }
      )(p0,cont);
      return function(){}
    }
  }
}
class Pulls{
  @:noUsing static public function pure<A,B,X,Y,R>(a:A):Proxy<A,B,A,B,R>{
    return Await(a,
      function(b:B){
        return Yield(b,pure);
      }
    );
  }
  @:noUsing static public function signal<A,B,X,Y,R>(a:A):Proxy<A,B,A,B,R>{
    return Await(a,
      function(b:B){
        return signal(a);
      }
    );
  }
  @:noUsing static public function fromSignal<A,B,X,Y,R>(sig:Signal<A>):Proxy<A,B,A,B,R>{
    return Later(
      sig.next().map(
        function(v:A){
          return Await(v,
            function(b:B,cont):Void{
              cont(fromSignal(sig));
            }
          );
        }
      )
    );
  }
  @:noUsing static public function fromArray<A,B,X,Y,R>(arr:Array<A>):Proxy<A,B,A,B,R>{
    return if(arr.length == 0){
      Ended(null);
    }else{
      var next  = arr.copy();
      var fst   = next.shift();
      var rst   = next;
      return Await(fst,
        function(b:B,cont){
          cont(fromArray(rst));
          return function(){};
        }
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
  static public function pulling<A,B,C,D,X,Y,R>(prx0:Arrowlet<X,Proxy<A,B,X,Y,R>>,prx1:Arrowlet<C,Proxy<X,Y,C,D,R>>):Arrowlet<C,Proxy<A,B,C,D,R>>{
    return function(c:C,cont){
      return prx1.then(puller.bind(prx0))(c,cont);
    }
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
  static public function puller<A,B,C,D,X,Y,R>(prx0:Arrowlet<X,Proxy<A,B,X,Y,R>>,prx1:Proxy<X,Y,C,D,R>):Proxy<A,B,C,D,R>{
    return switch (prx1){
      case Await(a,arw) : Pushes.pusher(Later(prx0.apply(a)),arw);
      case Yield(y,arw) : Yield(y,function(c:C){ return Pulls.puller(prx0,Later(arw.apply(c)));});
      case Ended(res)   : Ended(res);
      case Later(ft)    : Later(ft.then(puller.bind(prx0)));
    }
  }
}
class Pushes{
  @:noUsing static public function pure<A,B,R>(b:B):Proxy<A,B,A,B,R>{
    return Yield(b,
      function(a:A){
        return Await(a,pure);
      }
    );
  }
  @:noUsing static public function fromSignal<A,B,X,Y,R>(sig:Signal<B>):Proxy<A,B,A,B,R>{
    return Later(
      sig.next().map(
        function(v){
          return Yield(v,
            function(b,cont):Void{
              cont(fromSignal(sig));
            }
          );
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
  static public function pushing<A,B,X,Y,C,D,R>(prx0:Arrowlet<B,Proxy<A,B,X,Y,R>>,prx1:Arrowlet<Y,Proxy<X,Y,C,D,R>>):Arrowlet<B,Proxy<A,B,C,D,R>>{
    return function(b:B,cont):Void{
      prx0.apply(b).handle(
        function(br){
          cont(Pushes.pusher(br,prx1));
        }
      );
    }
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
  static public function pusher<A,B,C,D,X,Y,R>(prx0:Proxy<A,B,X,Y,R>,prx1:Arrowlet<Y,Proxy<X,Y,C,D,R>>):Proxy<A,B,C,D,R>{
    return switch(prx0){
      case Ended(res)   : Ended(res);
      case Yield(y,arw) : Later(prx1.then(Pulls.puller.bind(arw)).apply(y));
      case Await(a,arw) : Await(a,arw.then(Pushes.pusher.bind(_,prx1)));
      case Later(ft)    : Later(ft.then(pusher.bind(_,prx1)));
    }
  }
}
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
            case Await(a,arw) : stx.Proxy.Proxies.flatMap(Later(prx0.apply(a)),arw.then(go));
            case Yield(y,arw) : Yield(y,arw.then(go));
            case Later(ft)    : Later(ft.then(requester.bind(prx0)));
          }
        }
    return go(prx1);
  }
}
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
            case Later(ft)    : Later(ft.then(responder.bind(_,fn)));
          }
        }
    return go(prx);
  }
}
