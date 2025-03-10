--junção externa
select nome,cod_serv 
    from cliente c left join contrata c2 on c.cpf = c2.cpf;

-- Group by com Having
select cpf_func,count(*) as VND_REALIZADAS
from venda 
group by CPF_FUNC 
having count(*)>=2;

-- INNER JOIN
SELECT C.NOME,COUNT(*) as QTD_SRV_CONT
FROM CONTRATA C2 JOIN CLIENTE C ON C.CPF = C2.CPF 
GROUP BY C.NOME;

-- Subconsulta Escalar
select chassi , valor
    from auto_placa where valor > (select round(avg(valor),2) from auto_placa);

--semi-join
select nome 
	from cliente C where EXISTS(select * from contrata C2 where C.cpf = C2.cpf)

--anti-join
select nome 
	from cliente C where NOT EXISTS(select * from contrata C2 where C.cpf = C2.cpf)

--subconsulta do tipo tabela
select nome
	from cliente C 
		where(C.cpf,C.DT_CAD) IN 
    	 (select cpf,DT_ENT from contrata C2)

--subconsulta do tipo linha
select nome
	from cliente C 
		where(C.cpf,C.DT_CAD) IN 
    	 (select CPF_CLIENTE, DATA_COMPRA from VENDA order by DATA_COMPRA desc fetch first 1 rows only)

--Operação de conjunto
SELECT NOME
FROM 
	(SELECT NOME
    FROM CLIENTE) 
UNION 
	(SELECT NOME
    FROM FUNCIONARIO);
