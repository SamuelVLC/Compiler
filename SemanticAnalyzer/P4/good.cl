-- good.cl: Casos de Teste para combinações semânticas válidas


class C {
	a : Int;
	b : Bool;
	init(x : Int, y : Bool) : C {
           {
		a <- x;
		b <- y;
		self;
           }
	};
};


-- Definição de uma classe básica iniciando a Classe C
Class Main {
	main():C {
	  (new C).init(1,true)
	};
};



-- Definição de uma classe que utiliza herança e métodos
class Animal {
    name : String;

    set_name(n : String) : Animal {
        {
            name <- n;
            self;
        }
    };

    get_name() : String {
        name
    };
};

class Dog inherits Animal {
    bark() : String {
        "Woof!"
    };
};

-- Criação de instâncias e chamadas de métodos
class Program inherits IO {
    main() : Object {
        {
            let myDog : Dog <- new Dog in {
                myDog.set_name("Buddy");
                out_string(myDog.get_name());
                out_string(myDog.bark());
            };
        }
    };
};


(*
 * Exemplo 1: Corrigindo acesso ao `head` de uma lista vazia
 * Neste exemplo, é necessário adicionar uma verificação para evitar acessar o `head` de uma lista vazia.
 *)
 class TestHeadError {
	mylist: List;
 
	test_head() : Int {
	   {
		  mylist <- new List;
		  if mylist.isNil() then 
			 1 -- Retorna um valor padrão ou lança uma exceção adequada
		  else
			 mylist.head()
		  fi;
	   }
	};
 };
 
 (*
  * Exemplo 2: Corrigindo invocação de método com tipo incorreto
  * Neste exemplo, é necessário garantir que `mylist` seja do tipo `List` para acessar o método `head`.
  *)
 class TestTypeMismatch {
	mylist : List;
 
	test_type() : Int {
	   {
		  mylist <- new List.cons(1).cons(2).cons(3);
		  mylist.head();
	   }
	};
 };
 
 (*
  * Exemplo 3: Corrigindo tipo de retorno de método
  * Neste exemplo, é necessário garantir que o tipo de retorno do método `return_wrong_type` corresponda ao valor retornado.
  *)
 class TestReturnTypeError {
 
	return_wrong_type() : List {  -- Corrigido para o tipo List
	   new List.cons(1)
	};
 
	test_return() : List {
	   {
		  return_wrong_type(); 
	   }
	};
 };
 
 (*
  * Exemplo 4: Corrigindo atribuição incorreta de tipo em `init`
  * Neste exemplo, é necessário garantir que os parâmetros passados para `init` correspondam aos tipos esperados.
  *)
 class TestInitError {
	cons_obj : Cons;
 
	test_init() : List {
	   {
		  cons_obj <- new Cons;
		  cons_obj.init(1, new List);  -- Corrigido para passar um Int
	   }
	};
 };
 
 (*
  * Exemplo 5: Corrigindo condição de loop infinito
  * Neste exemplo, a condição do loop foi invertida para garantir que o loop seja executado enquanto a lista não estiver vazia.
  *)
 class TestLoopError {
	mylist : List;
 
	test_loop() : List {
	   {
		  mylist <- new List.cons(1).cons(2).cons(3);
		  while (not mylist.isNil()) loop  -- Corrigido para garantir a condição correta
			 {
				mylist <- mylist.tail();
			 }
		  pool;
		  mylist;
	   }
	};
 };
 
(*
	linked list Example from: https://nguyenthanhvuh.github.io/class-compilers/cool.html
*)
class List {
	-- Define operations on empty lists.
	
	isNil() : Bool { true };
	
	-- Since abort() has return type Object and head() has return type
	-- Int, we need to have an Int as the result of the method body,
	-- even though abort() never returns.
	
	head()  : Int { { abort(); 0; } };
	
	-- As for head(), the self is just to make sure the return type of
	-- tail() is correct.
	
	tail()  : List { { abort(); self; } };
	
	-- When we cons and element onto the empty list we get a non-empty
	-- list. The (new Cons) expression creates a new list cell of class
	-- Cons, which is initialized by a dispatch to init().
	-- The result of init() is an element of class Cons, but it
	-- conforms to the return type List, because Cons is a subclass of
	-- List.
	
	cons(i : Int) : List {
		(new Cons).init(i, self)
	};
	
};
	
	
(*
*  Cons inherits all operations from List. We can reuse only the cons
*  method though, because adding an element to the front of an emtpy
*  list is the same as adding it to the front of a non empty
*  list. All other methods have to be redefined, since the behaviour
*  for them is different from the empty list.
*
*  Cons needs two attributes to hold the integer of this list
*  cell and to hold the rest of the list.
*
*  The init() method is used by the cons() method to initialize the
*  cell.
*)

class Cons inherits List {
	
	car : Int;   -- The element in this list cell
	
	cdr : List;  -- The rest of the list
	
	isNil() : Bool { false };
	
	head()  : Int { car };
	
	tail()  : List { cdr };
	
	init(i : Int, rest : List) : List {
		{
		car <- i;
		cdr <- rest;
		self;
		}
	};
	
};
