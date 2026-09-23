    --Criação de Tabelas
   CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(40) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE planos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(20) UNIQUE NOT NULL,
    valor_mensal_base NUMERIC(10, 2) NOT NULL CHECK (valor_mensal_base > 0)
);

CREATE TABLE modalidades (
    id SERIAL PRIMARY KEY,
    plano_id INT REFERENCES planos(id),
    nome VARCHAR(50) NOT NULL,
    sala VARCHAR(30) NOT NULL,
    capacidade_maxima INT NOT NULL CHECK (capacidade_maxima > 0),
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE matriculas (
    id SERIAL PRIMARY KEY,
    aluno_id INT REFERENCES alunos(id),
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ativa' CHECK (status IN ('ativa', 'cancelada', 'trancada'))
);


CREATE TABLE itens_matricula (
    id SERIAL PRIMARY KEY,
    matricula_id INT REFERENCES matriculas(id),
    modalidade_id INT REFERENCES modalidades(id),
    duracao_meses INT NOT NULL CHECK (duracao_meses > 0),
    valor_mensal_aplicado DECIMAL(10, 2) NOT NULL CHECK (valor_mensal_aplicado > 0),
    taxa_adesao DECIMAL(10, 2) CHECK (taxa_adesao >= 0) DEFAULT 0.00
);

--Povoamento

INSERT INTO planos (nome, valor_mensal_base) VALUES 
('Premium', 220.00), 
('Standard', 140.00), 
('Basic', 90.00);

INSERT INTO modalidades (plano_id, nome, sala, capacidade_maxima, disponivel) VALUES 
(1, 'Crossfit Pro', 'Arena 01', 15, TRUE),
(2, 'Pilates Avançado', 'Studio 02', 10, TRUE),
(3, 'Musculação Livre', 'Salão Principal', 50, TRUE);

INSERT INTO alunos (nome, email, cpf, telefone) VALUES 
('joao', 'joao@email.com', '12345678910', '48 9 9999-9990'),
('emanuel', 'emanuel@email.com', '12345678911', '48 9 9939-9990'),
('miguel', 'miguel@email.com', '12345678912', '48 9 9679-9990');

INSERT INTO matriculas (aluno_id, status) VALUES 
(1, 'ativa'), 
(1, 'ativa'), 
(2, 'ativa'), 
(3, 'cancelada');

INSERT INTO itens_matricula (matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao) VALUES
(1, 1, 6, 220.00, 50.00),
(2, 2, 3, 140.00, 30.00),
(3, 3, 12, 90.00, 0.00),
(4, 1, 1, 220.00, 50.00);

--Questões

--Q1
--modalidades e itens_matricula
create view vw_modalidades_custo_estimado as
select
