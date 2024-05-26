-- bad.cl: Casos de teste de erros semânticas na linguagem 

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

Class Main {
	main():C {
	 {
	  (new C).init(1,1);
	  (new C).init(1,true,3);
	  (new C).iinit(1,true);
	  (new C);
	 }
	};
};


(*
 * Exemplo 1: Acessar `head` de uma lista vazia
 * Este código tenta acessar o `head` de uma lista vazia, o que resulta em uma chamada para `abort()`, causando a terminação do programa.
 *)
 class TestHeadError {
	mylist : List;
 
	test_head() : Bolean {
	   {
		  mylist <- new List;
		  mylist.head();  -- Erro: retornando um inteiro para uma função boleana
	   }
	};
 };
 
 
 (*
  * Exemplo 2: Invocação de método de forma incorreta
  * Este código tenta acessar um método `head` em um objeto que é esperado ser do tipo `List`, mas é de um tipo incompatível.
  *)
 class TestTypeMismatch {
	mylist : Int;  -- mylist é declarado como Int, mas deve ser List
 
	test_type() : Int {
	   {
		  mylist <- new List.cons(1).cons(2).cons(3);
		  mylist.head();  -- Erro: mylist é do tipo Int, não List
	   }
	};
 };
 
 
 (*
  * Exemplo 3: Tipo incompatível de retorno em método
  * Este código define um método que declara um tipo de retorno que não corresponde ao valor real retornado.
  *)
 class TestReturnTypeError {
 
	return_wrong_type() : Int {
	   new List.cons(1)  -- Erro: retorna List, mas o tipo de retorno declarado é Int
	};
 
	test_return() : Int {
	   return_wrong_type()  -- Erro: tentando atribuir List a uma variável do tipo Int
	};
 };
 
 
 (*
  * Exemplo 4: Atribuição incorreta de tipo em init
  * Este código tenta inicializar um objeto `Cons` de forma incorreta, causando inconsistência nos tipos.
  *)
 class TestInitError {
	cons_obj : Cons;
 
	test_init() : List {
	   {
		  cons_obj <- new Cons;
		  cons_obj.init("not an integer", new List);  -- Erro: tipo incorreto, espera-se um Int
	   }
	};
 };
 
 
 (*
  * Exemplo 5: Loop infinito por erro de terminação
  * Este código contém um loop que nunca termina porque a condição de término é incorreta.
  *)
 class TestLoopError {
	mylist : List;
 
	test_loop() : List {
	   {
		  mylist <- new List.cons(1).cons(2).cons(3);
		  while (mylist.isNil()) loop  -- Erro: a condição deve ser "not mylist.isNil()"
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
