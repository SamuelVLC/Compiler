
 class Main inherits IO {

    main() : Object {
       let teste: Int <- 2 in
        {
            out_string("implemented\n");
            let teste2: Int <- 2 in 3;
            2;
        }
    };
    test1(): Object {
        let
            x: Int <- 5
        in
            x * 2
    };  
    test2(): Object {
        let
            x: Int <- 10,
            y: String <- "Hello"
        in
            x + y.length()

    };
    test3(z: Int): String {
        let
            x: Int <- z
        in
            if x < 10 then
                "Menor que 10"
            else
                "Maior ou igual a 10"
            fi
    };
 
 };
 