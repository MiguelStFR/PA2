(* Dvidimos nossos testes em etapas, são elas: *)

(* Teste 1: Código reaproveitado do professor - Há um erro proposital em  'Int <- num_cells[] in' o correto seria 'Int <- num_cells() in'*)
class CellularAutomaton inherits IO {
    population_map : String;
   
    init(map : String) : SELF_TYPE {
        {
            population_map <- map;
            self;
        }
    };
   
    print() : SELF_TYPE {
        {
            out_string(population_map.concat("\n"));
            self;
        }
    };
   
    num_cells() : Int {
        population_map.length()
    };
   
    cell(position : Int) : String {
        population_map.substr(position, 1)
    };
   
    cell_left_neighbor(position : Int) : String {
        if position = 0 then
            cell(num_cells() - 1)
        else
            cell(position - 1)
        fi
    };
   
    cell_right_neighbor(position : Int) : String {
        if position = num_cells() - 1 then
            cell(0)
        else
            cell(position + 1)
        fi
    };
   
    cell_at_next_evolution(position : Int) : String {
        if (if cell(position) = "X" then 1 else 0 fi
            + if cell_left_neighbor(position) = "X" then 1 else 0 fi
            + if cell_right_neighbor(position) = "X" then 1 else 0 fi
            = 1)
        then
            "X"
        else
            "."
        fi
    };
   
    evolve() : SELF_TYPE {
        (let position : Int in
        (let num : Int <- num_cells[] in
        (let temp : String in
            {
                while position < num loop
                    {
                        temp <- temp.concat(cell_at_next_evolution(position));
                        position <- position + 1;
                    }
                pool;
                population_map <- temp;
                self;
            }
        ) ) )
    };
};

class Main {
    cells : CellularAutomaton;
   
    main() : SELF_TYPE {
        {
            cells <- (new CellularAutomaton).init("         X         ");
            cells.print();
            (let countdown : Int <- 20 in
                while countdown > 0 loop
                    {
                        cells.evolve();
                        cells.print();
                        countdown <- countdown - 1;
                    }
                pool
            );  
            self;
        }
    };
};

(* Teste 2: Teste de identificadores *)
class Teste {
    metodo() : Int { 42 + 8 * (10 - 3) };
};

(* Teste 3: Comentários (Devem ser ignorados) *)
-- Testando um comentário de linha
(* Testando um comentário 
   de múltiplas linhas *)

(* Teste 4: Testando strings e quebras de linha *)
class StringTeste {
    x : String <- "Texto com\nquebra de linha";
    y : String <- "String com \"aspas duplas\" dentro";
    z : String <- "Normal";
};

(* Teste 5: Testando contas matemáticas *)
class Operadores {
    soma : Int <- 10 + 20;
    subtracao : Int <- 50 - 25;
    multiplicacao : Int <- 3 * 4;
    divisao : Int <- 100 / 5;
    comparacao : Bool <- 10 < 20;
    igualdade : Bool <- (5 = 5);
};

(* Teste 6: Erros propositais para verificar se vao ser capturados *)

-- String sem fechamento (deve gerar erro)
"String sem aspas no final

-- Comentário sem fechamento (deve gerar erro)
(* Comentário aberto sem fechamento

(* Token inválido (deve gerar erro) *)
$variavel_invalida <- 10;