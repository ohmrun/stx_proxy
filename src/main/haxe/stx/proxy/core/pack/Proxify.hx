package stx.proxy.core.pack;

import stx.proxy.core.head.Data.Proxify in ProxifyA;

@:forward @:callable abstract Proxify<P,A,B,X,Y,R,E>(ProxifyA<P,A,B,X,Y,R,E>) from ProxifyA<P,A,B,X,Y,R,E> to ProxifyA<P,A,B,X,Y,R,E>{

}