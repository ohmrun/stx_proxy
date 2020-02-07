package stx.proxy.core.body;

class Proxieds{
  static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1,E>(lhs:Arrowlet<P0,Proxy<A0,B0,X0,Y0,R0,E>>,rhs:Arrowlet<R0,Proxy<A1,B1,X1,Y1,R1,E>>):Arrowlet<P0,Proxy<A1,B1,X1,Y1,R1,E>>{
    return __.arw().fn( (p0:P0) ->
      lhs.then(
        __.arw().fn(
            (p) -> switch(p){
              case Ended(r) : 
                r.fold(
                  (x) -> Later(rhs.suspend(x)),
                  (e) -> Ended(End(e)),
                  ()  -> Ended(Tap)
                );
              default : Later(then.bind(lhs,rhs));
          }
        )
      )
    );
  }
}

// class Proxieds{
//   static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1,E>(lhs:Arrowlet<P0,Proxy<A0,B0,X0,Y0,R0,E>>,rhs:Arrowlet<R0,Proxy<A1,B1,X1,Y1,R1,E>>):Arrowlet<P0,Proxy<A1,B1,X1,Y1,R1,E>>{
//     return __.arw().fn( (p0:P0) ->
//       lhs.then(
//         __.arw().fn(
//             (p) -> switch(p){
//               case Ended(r) : 
//                 r.fold(
//                   (x) -> Later(rhs.suspend(x)),
//                   (e) -> Ended(End(e)),
//                   ()  -> Ended(Tap)
//                 )
//               default : Later(then.bind(lhs,rhs))
//           }
//         )
//       )
//     );
//   }
// }