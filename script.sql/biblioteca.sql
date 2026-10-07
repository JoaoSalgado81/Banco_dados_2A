--Criação de tabelas
create table leitores(
id serial primary key,
nome varchar(100) not null,
email varchar(100) unique not null,
cpf varchar(11) unique not null,
telefone varchar(30) not null,
data_cadastro timestamp default current_timestamp
)

create table categorias (
id serial primary key,
nome varchar(50) unique not null
)

create table livros (
id serial primary key,
categoria_id int references categorias(id),
titulo varchar(100) not null,
isbn varchar(100) unique not null,
taxa_diaria decimal(10,2) check (taxa_diaria > 0) not null,
disponivel boolean default true
)

create table emprestimos (
id serial primary key,
leitor_id int references leitores(id),
data_emprestimo timestamp default current_timestamp,
status varchar(50) default 'Ativo' check (status in ('Ativo', 'Devolvido', 'Atrasado'))
)

create table itens_emprestimo (
id serial primary key,
emprestimo_id int references emprestimos(id),
livro_id int references livros(id),
quantidade int not null check (quantidade > 0),
valor_diaria decimal(10, 2) check (valor_diaria >= 0) not null
)

--Povoando Tabelas

INSERT INTO categorias (nome) VALUES 
('Ficção'), ('História'), ('Tecnologia')

INSERT INTO livros (categoria_id, titulo, isbn, taxa_diaria, disponivel) VALUES 
(1, 'Harry Potter', '9780007525546', 7.50, TRUE),
(1, '1984', '9780451524935', 4.00, TRUE),
(3, 'Linux', '9788575225639', 6.00, TRUE)

INSERT INTO leitores (nome, email, cpf, telefone) VALUES 
('joao', 'joao@email.com', '11122233344', '11999990000'),
('larperson', 'larperson@email.com', '22233344455', '11988880000'),
('Beatriz', 'bia@email.com', '33344455566', '11977770000')

INSERT INTO emprestimos (leitor_id, status) VALUES 
(1, 'Devolvido'), (1, 'Ativo'), (2, 'Devolvido'), (3, 'Atrasado')

INSERT INTO itens_emprestimo (emprestimo_id, livro_id, quantidade, valor_diaria) VALUES 
(1, 1, 2, 7.50),
(2, 2, 1, 4.00),
(3, 3, 3, 6.00),
(4, 1, 1, 7.50)

--Questões

--Q1

--livros e categorias
create view vw_acervo_ordenado as

select
livros.titulo as livros,
livros.isbn,
c.nome as categoria,
livros.taxa_diaria
from livros
join categorias c on livros.categoria_id = c.id

order by livros.taxa_diaria desc;

-- Q2
create view vw_emprestimos_carlos AS
select emp.id AS emprestimo_id, emp.data_emprestimo, liv.titulo AS livro, ie.quantidade, emp.status
from emprestimos emp
join leitores lei ON emp.leitor_id = lei.id
join itens_emprestimo ie ON emp.id = ie.emprestimo_id
join livros liv ON ie.livro_id = liv.id
where lei.nome = 'Carlos Silva';

-- Q3

create view vw_total_emprestimos AS
select emp.id AS emprestimo_id, lei.nome AS leitor, SUM(ie.quantidade * ie.valor_diaria) AS valor_total
from emprestimos emp
join leitores lei ON emp.leitor_id = lei.id
join itens_emprestimo ie ON emp.id = ie.emprestimo_id
group by emp.id, lei.nome;

-- Q4 

select l.* 
from livros l
join categorias c ON l.categoria_id = c.id
where c.nome = 'Ficção' AND l.taxa_diaria > 5.00 AND l.disponivel = TRUE;

-- Q5

create view vw_faturamento_por_categoria AS
select c.nome AS categoria, SUM(ie.quantidade * ie.valor_diaria) AS faturamento_total
from itens_emprestimo ie
join emprestimos emp ON ie.emprestimo_id = emp.id
join livros l ON ie.livro_id = l.id
join categorias c ON l.categoria_id = c.id
where emp.status = 'Devolvido'
group by c.nome;