package stx.proxy.core.head;

class Sources{
  static public function fromUIO<T>(uio:UIO<T>):Source<T,Noise>{
    var f0 = (next:T->Void) -> uio(Automation.unit())(next);
    var f1 = Receiver.lift(f0);
    var f2 = f1.map(
      (t:T) -> {
        var rcv = Arrowlets.fromReceiverArrowlet( (_:Noise) -> f0 );
        var nxt = rcv.postfix(
          function rec(t:T) return Yield(t,rcv.postfix(rec))
        );
        //$type(nxt);
        return Yield(t,nxt);
      }
    );
    var f3 = Later(f2);
    //$type(f0);
    //$type(f1);
    //$type(f2);
    //$type(f3);
    return f3;
  }
}