package stx.proxy.core;

typedef PullCatDef<P,A,B,X,Y,R,E> = Unary<P,Proxy<A,B,X,Y,R,E>>;

@:using(stx.proxy.core.PullCat.PullCatLift)
abstract PullCat<P,A,B,X,Y,R,E>(PullCatDef<P,A,B,X,Y,R,E>) from PullCatDef<P,A,B,X,Y,R,E> to PullCatDef<P,A,B,X,Y,R,E>{
  static public var _(default,never) = PullCatLift;
  public function new(self){
    this = self;
  }
}
class PullCatLift{
   
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
  static public function compose<A,B,C,D,X,Y,R,E>(prx0:Unary<X,Proxy<A,B,X,Y,R,E>>,prx1:Unary<C,Proxy<X,Y,C,D,R,E>>):Unary<C,Proxy<A,B,C,D,R,E>>{
    return (c:C) -> (prx1.then(next.bind(prx0)))(c);
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
  static public function next<A,B,C,D,X,Y,R,E>(prx0:Unary<X,Proxy<A,B,X,Y,R,E>>,prx1:Proxy<X,Y,C,D,R,E>):Proxy<A,B,C,D,R,E>{
    __.log().trace('next $prx0 $prx1');
    return switch (prx1){
      case Await(a,arw) : PushCat._.next(__.belay(prx0.bindI(a)),arw);
      case Yield(y,arw) : Yield(y,function(c:C){ return next(prx0,__.belay(arw.bindI(c)));});
      case Ended(res)   : Ended(res);
      case Defer(ft)    : Defer(ft.mod(next.bind(prx0)));
    }
  }
}