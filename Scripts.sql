-- 1) CRIAÇÃO DO BANCO
CREATE DATABASE rede_games;

-- Conectar ao banco (se estiver usando psql ou script interativo)
-- No psql: \c rede_games
-- Em pgAdmin, abra conexão ao banco rede_games antes de rodar o restante do script.

-- ==============================================
-- 2) TABELAS (DDL)
-- ==============================================
-- Tabela de fabricantes de consoles e acessórios
CREATE TABLE fabricante (
  id_fabricante SERIAL PRIMARY KEY,
  nome_fabricante VARCHAR(100) NOT NULL,
  pais VARCHAR(50)
);

-- Tabela de produtos vendidos na rede de lojas
CREATE TABLE produto (
  id_produto SERIAL PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  preco NUMERIC(10,2) NOT NULL CHECK (preco > 0),
  id_fabricante INT,
  CONSTRAINT fk_produto_fabricante FOREIGN KEY (id_fabricante)
    REFERENCES fabricante(id_fabricante)
);

-- Tabela de lojas da rede
CREATE TABLE loja (
  id_loja SERIAL PRIMARY KEY,
  nome_loja VARCHAR(120) NOT NULL,
  cidade VARCHAR(80) NOT NULL
);

-- Tabela de vendas
CREATE TABLE venda (
  id_venda SERIAL PRIMARY KEY,
  id_produto INT NOT NULL,
  id_loja INT NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  data_venda DATE NOT NULL,
  CONSTRAINT fk_venda_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
  CONSTRAINT fk_venda_loja FOREIGN KEY (id_loja) REFERENCES loja(id_loja)
);

-- ==============================================
-- 3) INSERTS: FABRICANTES
-- ==============================================
INSERT INTO fabricante (nome_fabricante, pais) VALUES
('Nintendo', 'Japão'),
('Sony', 'Japão'),
('Microsoft', 'Estados Unidos'),
('Razer', 'Estados Unidos'),
('HyperX', 'Estados Unidos'),
('Logitech', 'Suíça'),
('Capcom', 'Japão');

-- ==============================================
-- 4) INSERTS: PRODUTOS
-- ==============================================
INSERT INTO produto (nome, preco, id_fabricante) VALUES
('Nintendo Switch OLED', 2499.90, 1),
('Joy-Con Pair', 499.90, 1),
('PlayStation 5', 4399.00, 2),
('DualSense Controller', 399.90, 2),
('Xbox Series X', 4599.90, 3),
('Xbox Wireless Controller', 349.90, 3),
('Razer Kraken Headset', 499.90, 4),
('HyperX Cloud II Headset', 649.90, 5),
('Logitech G Pro Mouse', 399.90, 6),
('Resident Evil 4 Remake', 299.90, 7),
('Street Fighter 6', 349.90, 7);

-- ==============================================
-- 5) INSERTS: LOJAS
-- ==============================================
INSERT INTO loja (nome_loja, cidade) VALUES
('Rede Games SP - Paulista', 'São Paulo'),
('Rede Games RJ - Barra', 'Rio de Janeiro'),
('Rede Games MG - BH Shopping', 'Belo Horizonte'),
('Rede Games PR - Curitiba', 'Curitiba');

-- ==============================================
-- 6) INSERTS: VENDAS
-- (já contêm 11 registros - atende ao requisito mínimo de 6)
-- ==============================================
INSERT INTO venda (id_produto, id_loja, quantidade, data_venda) VALUES
(1, 1, 20, '2025-09-20'),
(2, 1, 35, '2025-09-21'),
(3, 2, 15, '2025-09-22'),
(4, 2, 40, '2025-10-01'),
(5, 3, 10, '2025-10-02'),
(6, 3, 5,  '2025-10-02'),
(7, 4, 12, '2025-10-05'),
(8, 4, 18, '2025-10-05'),
(9, 1, 20, '2025-10-06'),
(10,2, 25, '2025-10-06'),
(11,3, 30, '2025-10-07');

-- ==============================================
-- 7) JOIN — Relatório de produtos vendidos (produto, nome da loja, quantidade)
-- Requisito: JOIN correto entre produto, venda e loja
-- ==============================================
-- Consulta:
SELECT p.nome AS produto,
       l.nome_loja AS loja,
       v.quantidade
FROM venda v
JOIN produto p ON v.id_produto = p.id_produto
JOIN loja l ON v.id_loja = l.id_loja
ORDER BY v.data_venda, v.id_venda;

-- ==============================================
-- 8) GROUP BY — Total de produtos vendidos por loja
-- Exibir: nome da loja, total vendido (soma das quantidades)
-- ==============================================
-- Consulta:
SELECT l.nome_loja AS loja,
       SUM(v.quantidade) AS total_vendido
FROM venda v
JOIN loja l ON v.id_loja = l.id_loja
GROUP BY l.nome_loja
ORDER BY total_vendido DESC;

-- ==============================================
-- 9) HAVING — Lojas de alto desempenho (somaram > 30 unidades)
-- Filtro deve estar no HAVING (não no WHERE)
-- ==============================================
-- Consulta:
SELECT l.nome_loja AS loja,
       SUM(v.quantidade) AS total_vendido
FROM venda v
JOIN loja l ON v.id_loja = l.id_loja
GROUP BY l.nome_loja
HAVING SUM(v.quantidade) > 30
ORDER BY total_vendido DESC;

-- ==============================================
-- 10) SUBCONSULTA — Fabricantes com produtos vendidos ao menos uma vez
-- Mostrar apenas nome_fabricante. Usar IN ou EXISTS.
-- ==============================================
-- Variante A: usando IN
SELECT nome_fabricante
FROM fabricante f
WHERE f.id_fabricante IN (
  SELECT p.id_fabricante
  FROM produto p
  JOIN venda v ON p.id_produto = v.id_produto
);

-- Variante B: usando EXISTS
SELECT f.nome_fabricante
FROM fabricante f
WHERE EXISTS (
  SELECT 1
  FROM produto p
  JOIN venda v ON p.id_produto = v.id_produto
  WHERE p.id_fabricante = f.id_fabricante
);
