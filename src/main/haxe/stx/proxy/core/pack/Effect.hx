package stx.proxy.core.pack;

import stx.proxy.core.head.data.Effect in EffectT;

abstract Effect<R,E>(EffectT<R,E>) from EffectT<R,E> to EffectT<R,E>{
  public function new(self){
    this = self;
  }
  public function fmap<O>(fn:Arrowlet<R,Effect<O,E>>):Effect<O,E>{
    return new Effect(Proxies.fmap(this,fn.then(__.arw().fn()((x:Effect<O,E>)->x.prj()))));
  }
  public function prj():EffectT<R,E>{
    return this;
  }
}