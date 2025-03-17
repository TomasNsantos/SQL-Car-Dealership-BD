-- 1. SELF JOIN
--Retorna o relacionamento de cada funcionário com o seu chefe(quem é o chefe de cada funcionário)
SELECT F1.NOME AS FUNCIONARIO, 
       F2.NOME AS CHEFE
FROM FUNCIONARIO F1
LEFT JOIN FUNCIONARIO F2 ON F1.CPF_CHEFE = F2.CPF;

-- 2. CONSTRUÇÃO CASE
--Dividir clientes entre novos, regulares e antigos baseando-se na data de cadastro
SELECT NOME, 
       DT_CAD,
       CASE 
           WHEN DT_CAD >= '2023-01-01' THEN 'Novo Cliente'
           WHEN DT_CAD BETWEEN '2020-01-01' AND '2022-12-31' THEN 'Cliente Regular'
           ELSE 'Antigo Cliente'
       END AS CATEGORIA
FROM CLIENTE;


-- 3. Junção Externa (LEFT JOIN)
--Retorna o nome de todos os clientes da tabela cliente com os seus codigos de serviços, caso n tenha retorna null na coluna cod_serv
select nome,cod_serv 
    from cliente c left join contrata c2 on c.cpf = c2.cpf;

-- 4. Group by com HAVING
--Seleciona o cpf dos funcionarios e quantas vezes eles venderam 2 ou mais automoveis 
select cpf_func,count(*) as VND_REALIZADAS
from venda 
group by CPF_FUNC 
having count(*)>=2;

-- 5. GROUP BY COM ORDER BY
-- Mostra quantos funcionários estão sob cada chefe
SELECT CPF_CHEFE, COUNT(*) AS NUM_FUNCIONARIOS
FROM FUNCIONARIO
WHERE CPF_CHEFE IS NOT NULL
GROUP BY CPF_CHEFE
ORDER BY NUM_FUNCIONARIOS DESC;

-- 6. INNER JOIN
--Exibe o nome dos clientes que contrataram serviços e número  de serviços contratados por nome
SELECT C.NOME,COUNT(*) as QTD_SRV_CONT
FROM CONTRATA C2 JOIN CLIENTE C ON C.CPF = C2.CPF 
GROUP BY C.NOME;

-- 7. Subconsulta Escalar
-- Exibe o chassi e o valor dos carros que forem maior que a media geral dos valores.
select chassi , valor
    from auto_placa where valor > (select round(avg(valor),2) from auto_placa);

-- 8. Semi-join
--Exibe o nome dos clientes que contataram os serviços sem repetição dos nomes
select nome 
	from cliente C where EXISTS(select * from contrata C2 where C.cpf = C2.cpf)

-- 9. Anti-join
--Exibe os nome dos clientes que NÃO contataram serviços
select nome 
	from cliente C where NOT EXISTS(select * from contrata C2 where C.cpf = C2.cpf)

-- 10. Subconsulta do tipo Tabela
--Exibe clientes que realizaram serviços na mesma data de compra do carro
select nome
	from cliente C 
		where(C.cpf,C.DT_CAD) IN 
    	 (select cpf,DT_ENT from contrata C2)

-- 11. Subconsulta do tipo Linha
--Exibe o nome do ultimo cliente que comprou o carro na mesma data que fez o cadastro
select nome
	from cliente C 
		where(C.cpf,C.DT_CAD) IN 
    	 (select CPF_CLIENTE, DATA_COMPRA from VENDA order by DATA_COMPRA desc fetch first 1 rows only)

-- 12. Operação de Conjunto (UNION)
--Exibe a União dos nomes de clientes e funcionários
SELECT NOME
FROM 
	(SELECT NOME
    FROM CLIENTE) 
UNION 
	(SELECT NOME
    FROM FUNCIONARIO);

-- 13. Operação de Conjunto (INTERSECT)
-- Clientes que compraram carros e contrataram serviços
SELECT CPF_CLIENTE 
FROM VENDA
	INTERSECT
SELECT CPF 
FROM CONTRATA;

-- 14. Operação de Conjunto (EXCEPT)
-- Clientes que compraram carros, mas **não** contrataram serviços
SELECT CPF_CLIENTE 
FROM VENDA
	EXCEPT
SELECT CPF 
FROM CONTRATA;

-- 15. DELETE com Subquery
-- Remove todos os clientes que **nunca** compraram um carro
DELETE FROM CLIENTE
WHERE CPF NOT IN (SELECT CPF_CLIENTE FROM VENDA);

-- 16. Atualização Condicional (UPDATE com WHERE)
-- Aumenta o valor de todos os carros do tipo 'TAXI' em 15%
UPDATE AUTO_PLACA
SET VALOR = VALOR * 1.15
WHERE TIPO = 'TAXI';

-- 17. View para Clientes Premium
-- Clientes que compraram carros com valor acima da média
CREATE VIEW ClientesPremium AS
SELECT C.NOME, A.VALOR
FROM CLIENTE C
JOIN VENDA V ON C.CPF = V.CPF_CLIENTE
JOIN AUTO_PLACA A ON V.CHASSI = A.CHASSI
WHERE A.VALOR > (SELECT AVG(VALOR) FROM AUTO_PLACA);

-- verificando a view criada
SELECT * FROM ClientesPremium;

-- 18. Trigger para impedir vendas abaixo de 5000
CREATE OR REPLACE FUNCTION verifica_valor_venda()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT VALOR FROM AUTO_PLACA WHERE CHASSI = NEW.CHASSI) < 5000 THEN
        RAISE EXCEPTION 'Venda não permitida para carros com valor abaixo de 5000';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verifica_venda
BEFORE INSERT ON VENDA
FOR EACH ROW
EXECUTE FUNCTION verifica_valor_venda();

-- Teste da Trigger
INSERT INTO VENDA (CPF_CLIENTE, CPF_FUNC, CHASSI, DATA_COMPRA)
VALUES ('11122233345', '44455566677', 'ABC123', CURRENT_DATE);

-- 19. Função de Janela
-- Classifica os funcionários pelo número de vendas
SELECT CPF_FUNC, COUNT(*) AS TOTAL_VENDAS,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS RANKING
FROM VENDA
GROUP BY CPF_FUNC;

-- 20. Atualização em Lote
-- Altera o CEP de todos os clientes que moram na rua 'B'
UPDATE CLIENTE
SET CEP = '50000099'
WHERE RUA = 'B';

--Teste da atualização
SELECT * FROM CLIENTE		

--------------------------INSERÇÕES E TESTES------------------------

--INSERE O DONO DA CONCESSIONÁRIA 
INSERT INTO FUNCIONARIO (CPF, RUA, NUM, CEP, NOME, MAT, CPF_CHEFE)
VALUES ('00000000001', 'Rua da Empresa', '01', '00000000', 'FLAVIO', '00000000', '00000000001');

--FAZ O DONO SER O CHEFE DO CHEFE ATUAL QUE TEM MAIS SUBORDINADOS(OU SEJA, O GERENTE)
UPDATE FUNCIONARIO
SET CPF_CHEFE = '00000000001'
WHERE CPF = (
    SELECT CPF_CHEFE
    FROM FUNCIONARIO
    GROUP BY CPF_CHEFE
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

--Visualizando a Hierarquia após a mudança:

--MODO 1:
WITH RECURSIVE Hierarquia AS (
    -- Começa por FLAVIO
    SELECT CPF, NOME, CPF_CHEFE, 1 AS NIVEL
    FROM FUNCIONARIO
    WHERE CPF = '00000000001'
    
    UNION ALL
    
    -- Evita o loop infinito com a condição 'F.CPF != H.CPF'
    SELECT F.CPF, F.NOME, F.CPF_CHEFE, H.NIVEL + 1
    FROM FUNCIONARIO F
    JOIN Hierarquia H ON F.CPF_CHEFE = H.CPF
    WHERE F.CPF != H.CPF
)
SELECT * FROM Hierarquia ORDER BY NIVEL;

--MODO 2:
SELECT F1.NOME AS FUNCIONARIO, 
       F2.NOME AS CHEFE
FROM FUNCIONARIO F1
LEFT JOIN FUNCIONARIO F2 ON F1.CPF_CHEFE = F2.CPF;

