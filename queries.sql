-- SELF JOIN
--Retorna o relacionamento de cada funcionário com o seu chefe(quem é o chefe de cada funcionário)
SELECT F1.NOME AS FUNCIONARIO, 
       F2.NOME AS CHEFE
FROM FUNCIONARIO F1
LEFT JOIN FUNCIONARIO F2 ON F1.CPF_CHEFE = F2.CPF;

-- CONSTRUÇÃO CASE
--Dividir clientes entre novos, regulares e antigos baseando-se na data de cadastro
SELECT NOME, 
       DT_CAD,
       CASE 
           WHEN DT_CAD >= '2023-01-01' THEN 'Novo Cliente'
           WHEN DT_CAD BETWEEN '2020-01-01' AND '2022-12-31' THEN 'Cliente Regular'
           ELSE 'Antigo Cliente'
       END AS CATEGORIA
FROM CLIENTE;


-- Junção externa
--Retorna o nome de todos os clientes da tabela cliente com os seus codigos de serviços, caso n tenha retorna null na coluna cod_serv
select nome,cod_serv 
    from cliente c left join contrata c2 on c.cpf = c2.cpf;

-- Group by com Having
--Seleciona o cpf dos funcionarios e quantas vezes eles venderam 2 ou mais automoveis 
select cpf_func,count(*) as VND_REALIZADAS
from venda 
group by CPF_FUNC 
having count(*)>=2;


-- INNER JOIN
--Exibe o nome dos clientes que contrataram serviços e número  de serviços contratados por nome
SELECT C.NOME,COUNT(*) as QTD_SRV_CONT
FROM CONTRATA C2 JOIN CLIENTE C ON C.CPF = C2.CPF 
GROUP BY C.NOME;

-- Subconsulta Escalar
-- Exibe o chassi e o valor dos carros que forem maior que a media geral dos valores.
select chassi , valor
    from auto_placa where valor > (select round(avg(valor),2) from auto_placa);

-- Semi-join
--Exibe o nome dos clientes que contataram os serviços sem repetição dos nomes
select nome 
	from cliente C where EXISTS(select * from contrata C2 where C.cpf = C2.cpf)

-- Anti-join
--Exibe os nome dos clientes que não contataram serviços
select nome 
	from cliente C where NOT EXISTS(select * from contrata C2 where C.cpf = C2.cpf)

-- Subconsulta do tipo tabela
--Exibe clientes que realizaram serviços na mesma data de compra do carro
select nome
	from cliente C 
		where(C.cpf,C.DT_CAD) IN 
    	 (select cpf,DT_ENT from contrata C2)

-- Subconsulta do tipo linha
--Exibe o nome do ultimo cliente que comprou o carro na mesma data que fez o cadastro
select nome
	from cliente C 
		where(C.cpf,C.DT_CAD) IN 
    	 (select CPF_CLIENTE, DATA_COMPRA from VENDA order by DATA_COMPRA desc fetch first 1 rows only)

-- Operação de conjunto
--Exibe a União dos nomes de clientes e funcionários
SELECT NOME
FROM 
	(SELECT NOME
    FROM CLIENTE) 
UNION 
	(SELECT NOME
    FROM FUNCIONARIO);
