CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    especialidade_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    crm VARCHAR(20) UNIQUE NOT NULL,
    valor_consulta NUMERIC(10, 2) NOT NULL CHECK (valor_consulta > 0), )

CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL,
    paciente_id INT NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Realizada', 'Cancelada')),
)

CREATE TABLE exames_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL,
    nome_exame VARCHAR(100) NOT NULL,
    valor_exame NUMERIC(10, 2) NOT NULL CHECK (valor_exame >= 0),
)

--Povoando Tabelas

INSERT INTO especialidades (nome) VALUES 
('Cardiologia'),
('Pediatria'),
('Dermatologia');

INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES 
('joao', 'jv@gmail.com', '12345678910', '2010-04-08'),
('bia', 'bia@gmail.com', '12345678911', '2008-04-08'),
('miguel', 'miguel@gmail.com', '12345678912', '2000-04-11');

insert into medicos (especialidade_id, nome, crm, valor_consulta) values
('1', 'Dr. joao', 'CRM/SC 123456', '200'),
('2', 'Dra. bia', 'CRM/SC 123457', '500'),
('3', 'Dr. miguel', 'CRM/SC 123446', '130')

insert into consultas (medico_id, paciente_id, data_hora, status) values
(1, 1, '2026-03-10 09:00:00', 'realizada'),
(1, 2, '2026-03-10 09:30:00', 'realizada'),
(2, 2, '2026-03-10 10:00:00', 'realizada'),
(3, 1, '2026-03-10 11:00:00', 'agendada');

insert into exames_consulta (consulta_id, nome_exame, valor_exame) values
(1, 'Eletrocardiograma', 120.00),
(1, 'Ecocardiograma', 250.00),
(2, 'Hemograma Completo', 45.00),
(3, 'Exame de Urina', 30.00);

-- Questões

--Q1
CREATE VIEW vw_valor_medico AS
SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
INNER JOIN especialidades e ON m.especialidade_id = e.id
ORDER BY m.valor_consulta DESC;

--Q2
create view vw_consulta_joao as
SELECT 
    c.id AS consulta_id,
    c.data_hora,
    m.nome AS medico,
    e.nome AS especialidade,
    c.status
FROM consultas c
INNER JOIN pacientes p ON c.paciente_id = p.id
INNER JOIN medicos m ON c.medico_id = m.id
INNER JOIN especialidades e ON m.especialidade_id = e.id
WHERE p.nome = 'joao'
ORDER BY c.data_hora ASC;

--Q3
create view vw_total as
SELECT 
    c.id AS consulta_id,
    p.nome AS paciente,
    m.nome AS medico,
    m.valor_consulta,
    COALESCE(SUM(ex.valor_exame), 0.00) AS total_exames,
    (m.valor_consulta + COALESCE(SUM(ex.valor_exame), 0.00)) AS valor_total_atendimento
FROM consultas c
INNER JOIN pacientes p ON c.paciente_id = p.id
INNER JOIN medicos m ON c.medico_id = m.id
LEFT JOIN exames_consulta ex ON c.id = ex.consulta_id
GROUP BY c.id, p.nome, m.nome, m.valor_consulta
ORDER BY c.id;

--Q4
create view vw_superior as
SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
INNER JOIN especialidades e ON m.especialidade_id = e.id
WHERE m.valor_consulta > 300.00;

--Q5
create view vw_total_realizada as
SELECT 
    e.nome AS especialidade,
    COUNT(c.id) AS quantidade_consultas,
    COALESCE(SUM(m.valor_consulta), 0.00) AS faturamento_consultas
FROM especialidades e
INNER JOIN medicos m ON e.id = m.especialidade_id
LEFT JOIN consultas c ON m.id = c.medico_id AND c.status = 'Realizada'
GROUP BY e.id, e.nome
ORDER BY faturamento_consultas DESC;