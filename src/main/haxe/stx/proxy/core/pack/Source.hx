package stx.proxy.core.pack;

typedef SourceDef<Y,E> = ProducerDef<Y,Noise,E>;

abstract Source<Y,E>(SourceDef<Y,E>) from SourceDef<Y,E> to SourceDef<Y,E>{
  public function new(self) this = self;
  static public function lift<Y,E>(self:SourceDef<Y,E>):Source<Y,E> return new Source(self);
  


  public function prj():SourceDef<Y,E> return this;
  private var self(get,never):Source<Y,E>;
  private function get_self():Source<Y,E> return lift(this);

  
}