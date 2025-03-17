-- Criando tabelas no PostgreSQL
-- Criando tabelas no PostgreSQL
CREATE TABLE FUNCIONARIO ( 
    CPF VARCHAR(11) NOT NULL PRIMARY KEY, 
    RUA VARCHAR(25), 
    NUM VARCHAR(6), 
    CEP VARCHAR(8), 
    NOME VARCHAR(50), 
    MAT VARCHAR(8), 
    CPF_CHEFE VARCHAR(11), 
    FOREIGN KEY (CPF_CHEFE) REFERENCES FUNCIONARIO(CPF) 
);

CREATE TABLE CLIENTE ( 
    CPF VARCHAR(11) NOT NULL PRIMARY KEY, 
    RUA VARCHAR(25), 
    NUM VARCHAR(6), 
    CEP VARCHAR(8), 
    NOME VARCHAR(50), 
    DT_CAD DATE 
);

CREATE TABLE AUTO_PLACA ( 
    CHASSI VARCHAR(17) NOT NULL PRIMARY KEY, 
    COD VARCHAR(7), 
    TIPO VARCHAR(25), 
    VALOR DECIMAL(10,2) 
);

CREATE TABLE SERVICOS ( 
    COD VARCHAR(8) NOT NULL PRIMARY KEY, 
    NOME VARCHAR(25) 
);

CREATE TABLE CONTATO_FUNCIONARIO ( 
    CPF VARCHAR(11) NOT NULL, 
    CONT VARCHAR(25) NOT NULL, 
    PRIMARY KEY (CPF, CONT), 
    FOREIGN KEY (CPF) REFERENCES FUNCIONARIO(CPF) 
);

CREATE TABLE CONTATO_CLIENTE ( 
    CPF VARCHAR(11) NOT NULL, 
    CONT VARCHAR(25) NOT NULL, 
    PRIMARY KEY (CPF, CONT), 
    FOREIGN KEY (CPF) REFERENCES CLIENTE(CPF) 
);

CREATE TABLE CONTRATA ( 
    CPF VARCHAR(11) NOT NULL, 
    COD VARCHAR(8) NOT NULL, 
    COD_SERV VARCHAR(6), 
    CHASSI VARCHAR(17), 
    DT_ENT DATE, 
    DT_SAI DATE, 
    PRIMARY KEY (CPF, COD), 
    FOREIGN KEY (CPF) REFERENCES CLIENTE(CPF), 
    FOREIGN KEY (COD) REFERENCES SERVICOS(COD) 
);

CREATE TABLE VENDA ( 
    CPF_FUNC VARCHAR(11) NOT NULL, 
    DATA_COMPRA DATE NOT NULL, 
    CHASSI VARCHAR(17) NOT NULL, 
    CPF_CLIENTE VARCHAR(11) NOT NULL, 
    STATUS VARCHAR(15), 
    PRIMARY KEY (CPF_CLIENTE, CPF_FUNC, CHASSI, DATA_COMPRA), 
    FOREIGN KEY (CPF_CLIENTE) REFERENCES CLIENTE(CPF), 
    FOREIGN KEY (CPF_FUNC) REFERENCES FUNCIONARIO(CPF), 
    FOREIGN KEY (CHASSI) REFERENCES AUTO_PLACA(CHASSI) 
);

CREATE TABLE ENTRADA ( 
    CPF_FUNC VARCHAR(11) NOT NULL, 
    DATA_COMPRA DATE NOT NULL, 
    CHASSI VARCHAR(17) NOT NULL, 
    CPF_CLIENTE VARCHAR(11) NOT NULL, 
    TIPO VARCHAR(15), 
    VALOR DECIMAL(10,2), 
    PRIMARY KEY (CPF_CLIENTE, CPF_FUNC, CHASSI, DATA_COMPRA, TIPO), 
    FOREIGN KEY (CPF_CLIENTE, CPF_FUNC, CHASSI, DATA_COMPRA) REFERENCES VENDA(CPF_CLIENTE, CPF_FUNC, CHASSI, DATA_COMPRA) 
);

-- Criando a trigger para impedir venda duplicada de carro finalizado
CREATE OR REPLACE FUNCTION verifica_venda_carro()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM VENDA 
        WHERE CHASSI = NEW.CHASSI AND STATUS = 'FINALIZADA'
    ) THEN
        RAISE EXCEPTION 'Erro: Este carro já foi vendido e a venda está finalizada!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_venda_carro
BEFORE INSERT ON VENDA
FOR EACH ROW
EXECUTE FUNCTION verifica_venda_carro();

-- Inserindo dados no PostgreSQL
INSERT INTO FUNCIONARIO (CPF, RUA, NUM, CEP, NOME, MAT) VALUES 
('99988877723', 'Z', '130', '50000200', 'ROBSON', '99999999'),
('11122233344', 'A', '10', '50000000', 'IGOR', '11111111'),
('11122233349', 'F', '15', '50000050', 'MARI', '22222222'),
('11122233346', 'C', '5', '50000020', 'THOMAS', '33333333'),
('11122233352', 'I', '30', '50000080', 'FERNANDA', '44444444'),
('11122233348', 'E', '10', '50000040', 'ARTHUR', '55555555');

UPDATE FUNCIONARIO SET CPF_CHEFE = '99988877723';

INSERT INTO CLIENTE VALUES 
('11122233345', 'B', '15', '50000010', 'LUAN', '2024-03-12'),
('11122233350', 'G', '25', '50000060', 'JOANA', '2020-09-30'),
('11122233351', 'H', '150', '50000070', 'JULIA', '2021-01-22'),
('11122233347', 'D', '9', '50000030', 'GABRIEL', '2022-06-15'),
('11122233353', 'J', '49', '50000100', 'PAULA', '2022-03-12'),
('11122233369', 'R', '38','50000080','JOELINTON','2023-07-12');

INSERT INTO AUTO_PLACA VALUES 
('9BD111060T5002156', 'ABC1C36', 'NORMAL', 100000),
('9BD111060T5002157', 'ABC1C35', 'TAXI', 80000),
('9BD111060T5002158', NULL, NULL, 200000),
('9BD111060T5002159', 'ABC1C34', 'NORMAL', 2000),
('9BD111060T5002160', NULL, NULL, 90000),
('9BD111060T5002161', NULL, NULL, 300000),
('9BD111060T5002162', NULL, NULL, 150000.00),
('9BD111060T5002169', NULL, NULL, 500000),
--cars to be sold as an example
('9BD111060T5002170', 'DEF1234', 'NORMAL', 2500),
('9BD111060T5002171', 'DEF5678', 'NORMAL', 400000);

INSERT INTO SERVICOS VALUES 
('11111111', 'REVISÃO'),
('22222222', 'ALINHAMENTO'),
('33333333', 'PINTURA'),
('44444444', 'TROCA DE OLEO');

INSERT INTO CONTATO_FUNCIONARIO VALUES 
('11122233344', '81999998888'),
('11122233349', '81999998877'),
('11122233346', '81999998866'),
('11122233352', 'fernanda@email.com'),
('11122233352', '81999998844'),
('11122233348', '81999998855');

INSERT INTO CONTATO_CLIENTE VALUES 
('11122233345', '81999997788'),
('11122233350', '81999996688'),
('11122233351', '81999995588'),
('11122233347', '81999994488'),
('11122233353', '81999993388');

INSERT INTO CONTRATA VALUES 
( '11122233345', '11111111', '123412','9BD111060T5002162',TO_DATE('12/03/2024','DD/MM/YYYY'),TO_DATE('14/03/2024','DD/MM/YYYY')),
( '11122233347', '22222222', '567812','9BD111060T5002160',TO_DATE('15/01/2024','DD/MM/YYYY'),TO_DATE('18/01/2024','DD/MM/YYYY')),
( '11122233345', '33333333', '123412','9BD111060T5002162',TO_DATE('14/03/2024','DD/MM/YYYY'),TO_DATE('17/03/2024','DD/MM/YYYY')),
( '11122233369', '11111111', '123419','9BD111060T5002169',TO_DATE('12/07/2023','DD/MM/YYYY'),TO_DATE('14/03/2024','DD/MM/YYYY'));

INSERT INTO VENDA VALUES 
('11122233344', '2023-08-24', '9BD111060T5002162', '11122233345', 'FINALIZADA'),
('11122233344', '2020-10-01', '9BD111060T5002157', '11122233350', 'FINALIZADA'),
('11122233349', '2021-01-22', '9BD111060T5002161', '11122233351', 'FINALIZADA'),
('11122233346', '2022-06-15', '9BD111060T5002156', '11122233347', 'FINALIZADA'),
('11122233348', '2024-03-12', '9BD111060T5002159', '11122233345', 'FINALIZADA'),
('11122233348', '2022-06-15', '9BD111060T5002160', '11122233347', 'FINALIZADA'),
('11122233352', '2022-03-12', '9BD111060T5002158', '11122233353', 'FINALIZADA'),
('11122233344', '2023-07-05', '9BD111060T5002169', '11122233369', 'FINALIZADA');

INSERT INTO ENTRADA VALUES 
('11122233344', '2023-08-24', '9BD111060T5002162', '11122233345', 'DINHEIRO', 15000),
('11122233344', '2020-10-01', '9BD111060T5002157', '11122233350', 'CARRO-USADO', 20000);
