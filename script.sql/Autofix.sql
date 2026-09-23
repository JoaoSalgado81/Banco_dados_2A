--Criação de Tabelas
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mecanicos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(50) NOT NULL,
    valor_hora NUMERIC(10, 2) NOT NULL CHECK (valor_hora > 0)
);

CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    placa VARCHAR(7) UNIQUE NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    ano INT NOT NULL CHECK (ano > 1900),
    
    CONSTRAINT fk_veiculo_cliente 
        FOREIGN KEY (cliente_id) 
        REFERENCES clientes(id) 
        ON DELETE CASCADE
);

CREATE TABLE ordens_servico (
    id SERIAL PRIMARY KEY,
    veiculo_id INT NOT NULL,
    mecanico_id INT NOT NULL,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_mao_obra NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (valor_mao_obra >= 0),
    status VARCHAR(20) DEFAULT 'Em Aberto' CHECK (status IN ('Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada')),
    
);

create table pecas_os(
id serial primary key,
os_id int not null,
nome_peca varchar(30) not null,
quantidade int not null  check (quantidade > 0),
valor_unitario numeric (10, 2) not null check (valor_unitario > 0)
);

--Povoamento

insert into clientes (nome, email, telefone, cpf) VALUES
('joao', 'joao@email.com', '(48) 91234-5678', '12345678910'),
('bia', 'bia@email.com', '(48) 92234-5679', '12345678911'),
('emanuel', 'emanuel@email.com', '(48) 91034-5672', '12345678913')

insert into mecanicos (nome, especialidade, valor_hora) VALUES
('miguel', 'Motor e Câmbio', '120.00'),
('Renato', 'Supensão e Freios', '500.00'),
('everton', 'Elétrica e Injeção', '300.00')

insert into veiculos (cliente_id, placa, modelo, marca, ano) VALUES
('1', 'ABC1D23', 'Civic coupé 2', 'Honda', '1992'),
('1', 'ABC1D20', 'Fusca Azul', 'Volkswagen', '1966'),
('2', 'ABC3f23', 'Smart Fortwo', 'Smart', '2020'),
('3', 'ABC9C93', 'Marea Turbo', 'Fiat', '2000')

Insert into ordens_servico (veiculo_id, mecanico_id, valor_mao_obra, status	) VALUES
('1', '1', '120.00', 'Concluida'),
('2', '2', '500.00', 'Concluida'),
('3', '1', '210.00', 'Em Andamento'),
('4', '3', '290.00', 'Concluida')

insert into pecas_os (os_id, nome_peca, quantidade, valor_unitario) VALUES
('1', 'Jogo de Velas Iridium', '1', '240.00'),
('1', 'Óleo Sintético 5W30 (litro)', '4', '30.00'),
('3', 'Pastilha de Freio Dianteira', '1', '100.00'),
('4', 'Bateria 60Ah', '1', '400.00')

--Q1
create view vw_veiculos as
select
v.marca, 	
v.modelo,
v.placa,
c.nome as proprietario,
c.telefone
from veiculos v
inner join clientes c on v.cliente_id = c.id
order by v.marca asc, v.modelo asc;

--Q2

--veiculos, ordens_servico, mecanicos
create view vw_joao as
SELECT
os.id as os_id,
v.placa,
v.modelo,
os.data_abertura,
m.nome as mecanico,
os.status

FROM ordens_servico os
inner join veiculos v on os.veiculo_id = v.id
inner join clientes c on v.cliente_id = c.id
inner join mecanicos m on os.mecanico_id = m.id
where c.nome = 'joao'
order by os.data_abertura desc;

--Q3
--ordens_servico, veiculos, pecas_os, mecanicos
create view vw_total_os as
SELECT
os.id as id_os,
v.placa,
m.nome as nome_mecanico,
os.valor_mao_obra,

os.valor_mao_obra + COALESCE(sum(p.quantidade * p.valor_unitario), 0) as valor_total_final
from ordens_servico os
join veiculos v on os.veiculo_id = v.id
join mecanicos m on os.mecanico_id = m.id
left join pecas_os p on os.id = p.os_id

group by
os.id,
v.placa,
m.nome,
os.valor_mao_obra
order by os.id;

--Q4
create view vw_mecanico_sup as
select
m.nome,
m.especialidade,
m.valor_hora

from mecanicos m 
where (valor_hora > 90)

--Q5
--ordens_servico, mecanicos, 

create view vw_total_concluida as
SELECT
m.especialidade,
sum(os.valor_mao_obra) as total_mao_obra

from ordens_servico os
join mecanicos m on os.mecanico_id = m.id


where os.status = 'Concluida'
group by 
m.especialidade;
