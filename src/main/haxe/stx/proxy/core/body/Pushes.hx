package stx.proxy.core.body;
import stx.run.head.data.Receiver in ReceiverT;

class Pushes{
  @:noUsing static public function pure<A,B,R,E>(b:B):Proxy<A,B,A,B,R,E>{
    return Yield(b,
      __.arw().fn()(function(a:A){
        return Await(a,pure);
      })
    );
  }
  @:noUsing static public function fromSignal<A,B,X,Y,R,E>(sig:Signal<B>):Proxy<A,B,A,B,R,E>{
    return Later(
      Receiver.lift(
        (next) -> {
          var a     = Receivers.fromFuture(sig.nextTime());
          var b     = a.map(
            (b) -> Yield(b,
              __.arw().cont()(
                (b,cont) -> cont(fromSignal(sig),__)
              )  
            )
          );
          return b(next);
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
  static public function pushing<A,B,X,Y,C,D,R,E>(prx0:Arrowlet<B,Proxy<A,B,X,Y,R,E>>,prx1:Arrowlet<Y,Proxy<X,Y,C,D,R,E>>):Arrowlet<B,Proxy<A,B,C,D,R,E>>{
    return __.arw().cont()((b:B,cont:Continue<Proxy<A,B,C,D,R,E>>) ->
      prx0.postfix(
        (br) -> Pushes.pusher(br,prx1)
      ).prepare(b,cont));
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
  static public function pusher<A,B,C,D,X,Y,R,E>(prx0:Proxy<A,B,X,Y,R,E>,prx1:Arrowlet<Y,Proxy<X,Y,C,D,R,E>>):Proxy<A,B,C,D,R,E>{
    return switch(prx0){
      case Ended(res)   : Ended(res);
      case Yield(y,arw) : Later(prx1.then(__.arw().fn()((x) -> Pulls.puller(arw,x))).receive(y));
      case Await(a,arw) : Await(a,arw.then(Pushes.pusher.bind(_,prx1)));
      case Later(ft)    : Later(ft.map(pusher.bind(_,prx1)));
    }
  }
}