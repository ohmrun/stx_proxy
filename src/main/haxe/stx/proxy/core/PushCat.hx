package stx.proxy.core;

typedef PushCatDef<P,A,B,X,Y,R,E> = Unary<P,Proxy<A,B,X,Y,R,E>>;

@:using(stx.proxy.core.PushCat.PushCatLift)
abstract PushCat<P,A,B,X,Y,R,E>(PushCatDef<P,A,B,X,Y,R,E>) from PushCatDef<P,A,B,X,Y,R,E> to PushCatDef<P,A,B,X,Y,R,E>{
  static public var _(default,never) = PushCatLift;
  public function new(self){
    this = self;
  }
}
class PushCatLift{
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
  static public function compose<A,B,X,Y,C,D,R,E>(prx0:Unary<B,Proxy<A,B,X,Y,R,E>>,prx1:Unary<Y,Proxy<X,Y,C,D,R,E>>):Unary<B,Proxy<A,B,C,D,R,E>>{
    return (b:B) ->
      __.belay(prx0.then(
        (br) -> next(br,prx1)
      ).bindI(b));
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
  static public function next<A,B,C,D,X,Y,R,E>(prx0:Proxy<A,B,X,Y,R,E>,prx1:Unary<Y,Proxy<X,Y,C,D,R,E>>):Proxy<A,B,C,D,R,E>{
    __.log().trace('next $prx0 $prx1');
    return switch(prx0){
      case Ended(res)   : Ended(res);
      case Yield(y,arw) : __.belay(prx1.then(PullCat._.next.bind(arw)).bindI(y));
      case Await(a,arw) : Await(a,arw.then(PushCat._.next.bind(_,prx1)));
      case Defer(ft)    : Defer(ft.mod(next.bind(_,prx1)));
    }
  }
}