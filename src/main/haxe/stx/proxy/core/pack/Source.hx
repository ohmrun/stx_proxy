package stx.proxy.core.pack;

import stx.proxy.core.head.data.Source in SourceT;

abstract Source<Y,E>(SourceT<Y,E>) from SourceT<Y,E> to SourceT<Y,E>{
  public function new(self) this = self;
  static public function lift<Y,E>(self:SourceT<Y,E>):Source<Y,E> return new Source(self);
  


  public function prj():SourceT<Y,E> return this;
  private var self(get,never):Source<Y,E>;
  private function get_self():Source<Y,E> return lift(this);

  
}