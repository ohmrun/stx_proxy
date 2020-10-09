package stx.proxy.core;


abstract Closed(Dynamic) from Dynamic to Dynamic{
  static public var ZERO = new Closed();

  public function new(){
    this = null;
  }
  public function zero():Bool{
    return this == ZERO;
  }
}