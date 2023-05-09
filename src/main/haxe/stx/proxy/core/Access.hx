package stx.proxy.core;

typedef AccessDef<Y,E> = ProducerDef<Y,Nada,E>;

abstract Access<Y,E>(AccessDef<Y,E>) from AccessDef<Y,E> to AccessDef<Y,E>{
  public function new(self) this = self;
  @:noUsing static public function lift<Y,E>(self:AccessDef<Y,E>):Access<Y,E> return new Access(self);
  


  public function prj():AccessDef<Y,E> return this;
  private var self(get,never):Access<Y,E>;
  private function get_self():Access<Y,E> return lift(this);

  
}