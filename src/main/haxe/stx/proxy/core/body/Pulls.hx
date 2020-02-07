package stx.proxy.core.body;

class Pulls{
  @:noUsing static public function pure<A,B,X,Y,R,E>(a:A):Proxy<A,B,A,B,R,E>{
    return Await(a,
      function(b:B){
        return Yield(b,pure);  
      }
    );
  }
  @:noUsing static public function gen<A,B,R,E>(thk:Thunk<Option<A>>):Proxy<A,B,A,B,R,E>{
    var fn = Options._.fold.bind(
      (v) -> Await(v,__.arw().fn()((_) -> gen(thk))),
      ()  -> Ended(Tap)
    );
    return Later(
      Receiver.lift(
        (next) -> {
          next(thk());
          return Automation.unit();
        } 
      ).map(fn)
    );
  }
  @:noUsing static public function signal<A,B,X,Y,R,E>(a:A):Proxy<A,B,A,B,R,E>{
    return Await(a,
      function(b:B){
        return signal(a);
      }
    );
  }
  @:noUsing static public function fromSignal<A,B,X,Y,R,E>(sig:Signal<A>):Proxy<A,B,A,B,R,E>{
    return Later(
      Receivers.fromFuture(sig.nextTime()).map(
        (v:A) -> Await(v,__.arw().cont()((b:B,cont:Continue<Proxy<A,B,A,B,R,E>>) ->
          cont(fromSignal(sig),Automation.unit())
        ))
      )
    );
  }
  @:noUsing static public function fromArray<A,B,X,Y,R,E>(arr:Array<A>):Proxy<A,B,A,B,R,E>{
    return if(arr.length == 0){
      Ended(Tap);
    }else{
      var next  = arr.copy();
      var fst   = next.shift();
      var rst   = next;
      return Await(fst,
        __.arw().cont()(function(b:B,cont:Continue<Proxy<A,B,A,B,R,E>>){
          return cont(fromArray(rst),Automation.unit());
        })
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
  static public function pulling<A,B,C,D,X,Y,R,E>(prx0:Arrowlet<X,Proxy<A,B,X,Y,R,E>>,prx1:Arrowlet<C,Proxy<X,Y,C,D,R,E>>):Arrowlet<C,Proxy<A,B,C,D,R,E>>{
    return __.arw().cont()((c:C,cont) -> 
      prx1.then(puller.bind(prx0)).prepare(c,cont)
    );
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
  static public function puller<A,B,C,D,X,Y,R,E>(prx0:Arrowlet<X,Proxy<A,B,X,Y,R,E>>,prx1:Proxy<X,Y,C,D,R,E>):Proxy<A,B,C,D,R,E>{
    return switch (prx1){
      case Await(a,arw) : Pushes.pusher(Later(prx0.receive(a)),arw);
      case Yield(y,arw) : Yield(y,function(c:C){ return Pulls.puller(prx0,Later(arw.receive(c)));});
      case Ended(res)   : Ended(res);
      case Later(ft)    : Later(ft.map(puller.bind(prx0)));
    }
  }
}