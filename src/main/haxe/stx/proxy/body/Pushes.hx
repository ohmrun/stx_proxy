package stx.proxy.body;

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
      case Later(ft)    : Later(ft.map(pusher.bind(_,prx1)));
    }
  }
}