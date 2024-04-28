(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)


 class Main inherits IO  {

    stack: Stack;
 
    and(a: Bool, b: Bool): Bool {
       if(a = false) then false else 
          if(b = false) then false else  true fi 
       fi
    };
 
    includes(target: String, input: String ): Bool {
       if (target.length() = 0) then
          false
       else
          if(target.substr(0, 1) = input) then
             true
          else
             includes(target.substr(1, target.length()-1), input)
          fi
       fi
    };
 
    main() : Object {
      {
       stack <- new Stack;
       let input: String <- in_string() in
       while(not(input = "")) loop
       {
 
          out_string(">".concat(input).concat("\n"));
          if (includes("edx",input)) then 
          {
             --Action
             if(and(input = "e", not(stack.is__null()))) then
             {
                if(and(stack.peek().is_int() = false, stack.peek().to_string() = "+")) then
                { 
                   stack.pop();
                   let v: Int <- stack.peek().get_sum() in {
                      stack.pop_int();
                      stack.pop_int();
                      stack.push(v);
                   };
                }
                else 
                {
 
                   if(and(stack.peek().is_int() = false , stack.peek().to_string() = "s")) then {
                      --- Swap Value
                      stack.pop();
                      stack.swap();
                   } else {
                      0;
                   } fi;
                } 
                fi;
             } else
                stack.print()
             fi;
          }
          else
          {
             --Push
             if (includes("+s",input)) then
                stack.push(input)
             else
                stack.push(new A2I.a2i(input))
             fi;
          }
          fi;
 
          input <- in_string();
       }
       pool;
       
     --     out_string("Stack\n");
     --  
     --     stack <- new Stack.push(1).push(2).push(3).push("s").push("+");
     --     stack.print();
     --     stack.pop();
     --     stack.print();
     --     stack.pop();
     --     stack.print();
     --     stack.pop();
     --     stack.print();
     --     stack.pop();
     --     stack.print();
     }
    };
 
 };
 
 
 
 class Node inherits A2I{
    value: Object;
    next: Node;
    is__root: Bool <- false;
    is__null: Bool <- true;
    is__int: Bool <- false;
 
    set_value(v: Object): Node {
       {
          is__null <- false;
         case v of
             i: Int => {
                   is__int <- true;
                   value <- new A2I.i2a(i);
                };
             s: String =>  value <- s;
             esac;
          self;
       }
    };
    set_next(n: Node): Node {
       {
          next <- n ;
          self;
       }
    };
 
    get_next(): Node { next };
    get_value(): Int {
       if(is__int) then 
          a2i(to_string())
       else
          0
       fi
    };
 
    get_v(): Object {
       value
    };
 
    get_sum(): Int { next.get_value() + get_value() };
    to_string(): String { 
       if (is__null) then
          "null" 
       else 
          case value of
             i: Int =>  new A2I.i2a(i);
             s: String => s;
             o: Object => {  " "; };
             b: Bool => {  "__ "; };
          esac
       fi
    };
    is_int(): Bool { is__int };
    set_null(): Node { { is__null <- true; self;}};
    is_root(): Bool { is__root };
    is_null(): Bool { is__null };
    set_root(): Node { {is__root <- true; self; }};
  
  };
  
 class Stack inherits IO {
 
    root: Node;
    aux_n: Node;
    is_null: Bool <- true;
 
 
    peek(): Node { root };
    is__null(): Bool { is_null};
    push(v: Object): Stack {
       if (is_null)  then 
       {
          root <- new Node;
          root.set_value(v);
          root.set_root();
          is_null <- false;
          self;
       }
       else 
       {
          aux_n <- new Node.set_value(v);
          aux_n.set_next(root);
          root <- aux_n;
          self;
       }
       fi
    };
 
    swap(): Stack {
       if(root.get_next().is_null()) then
          self
       else {
          let v: Object <- root.get_next().get_v() in {
             root.get_next().set_value(root.get_v());
             root.set_value(v);
          };
          self;
       }
       fi
    };
 
    pop() : Stack {
 
       if (root.is_root()) then
       {
          is_null <- true;
          root.set_null();
          self;
       }
       else
       {
          root <- root.get_next();
          self;
       }
       fi
    };
 
    pop_int() : Stack {
       if (root.is_int()) then
          if (root.is_root()) then
          {
             is_null <- true;
             root.set_null();
             self;
          }
          else
          {
             root <- root.get_next();
             self;
          }
          fi
       else 
          self
       fi
    };
 
    print(): Object {
       {
          let aux: Node <- root
          in
          while (isvoid aux  = false) loop
          {
             out_string(aux.to_string().concat("\n"));
             aux <- aux.get_next();
          }
          pool;
       }
    };
 
 };