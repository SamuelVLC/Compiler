-- sdfs
class
-- TYPEID
Main 
(*
 -- teste
*)
-- Special characters
{
-- OBJECTID AND TYPEID
main() : Object 
-- ERROR "Unterminated string constant"
"string\
"
" --\
-- STRING\
: \n\
"123
class x : Int <- 5 in let y : String <- "hello" in { x <- x + 1; out_string(y); } };} ""


-- Teste 14: Comment EOF deve retornar um `ERROR:` "EOF in comment"
-- Input:
(*
