package stx.proxy.core.pack;

import stx.proxy.core.head.data.Arrow in ArrowT;

import stx.proxy.core.body.Arrows;

abstract Arrow<P,A,B,X,Y,R,E>(ArrowT<P,A,B,X,Y,R,E>) from ArrowT<P,A,B,X,Y,R,E> to ArrowT<P,A,B,X,Y,R,E>{
  public function new(self){
    this = self;
  }
  public function then<A1,B1,X1,Y1,R1,E>(that:Arrow<R,A1,B1,X1,Y1,R1,E>):Arrowlet<P,Proxy<A1,B1,X1,Y1,R1,E>>{
    return Arrows.then(this,that);
  }
}