package stx.proxy.body;

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
      case Later(ft)    : Later(ft.map(puller.bind(prx0)));
    }
  }
}