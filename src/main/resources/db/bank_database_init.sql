-- ============================================================
-- Bank Database Initialization Script (MySQL)
-- Creates schema, tables, and populates sample data
-- ============================================================

CREATE DATABASE IF NOT EXISTS bank_db;
USE bank_db;

-- ============================================================
-- DDL: Table Definitions
-- ============================================================

-- 1. Account table
CREATE TABLE IF NOT EXISTS account (
    acct_id       BIGINT        NOT NULL AUTO_INCREMENT,
    acct_type     VARCHAR(2)    NOT NULL COMMENT 'CA=Cash Account, CC=Credit Card Account, DA=Demat Account',
    acct_ccy      VARCHAR(3)    NOT NULL COMMENT 'Account currency (e.g., USD, GBP, EUR, INR)',
    open_date     DATE          NOT NULL,
    close_date    DATE          DEFAULT NULL,
    is_active     TINYINT(1)    NOT NULL DEFAULT 1,
    PRIMARY KEY (acct_id),
    CONSTRAINT chk_acct_type CHECK (acct_type IN ('CA', 'CC', 'DA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Security reference table
CREATE TABLE IF NOT EXISTS sec_ref (
    sec_id        VARCHAR(12)   NOT NULL COMMENT 'ISIN identifier (e.g., US0378331005)',
    sec_name      VARCHAR(100)  NOT NULL,
    unit_price    DECIMAL(18,4) NOT NULL,
    sec_ccy       VARCHAR(3)    NOT NULL COMMENT 'Security currency (e.g., USD, GBP, EUR, INR)',
    is_active     TINYINT(1)    NOT NULL DEFAULT 1,
    PRIMARY KEY (sec_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Order table
CREATE TABLE IF NOT EXISTS `order` (
    order_id                    VARCHAR(14)    NOT NULL COMMENT 'Order ID with ODR prefix (e.g., ODR52136552354)',
    sec_id                      VARCHAR(12)    NOT NULL,
    acct_id                     BIGINT         NOT NULL,
    order_type                  VARCHAR(4)     NOT NULL COMMENT 'Buy or Sell',
    order_date                  DATE           NOT NULL,
    expiry_date                 DATE           NOT NULL,
    order_nature                VARCHAR(6)     NOT NULL COMMENT 'Limit or Market',
    qty                         INT            NOT NULL,
    avg_unit_price_in_sec_ccy   DECIMAL(18,4)  NOT NULL,
    avg_unit_price_in_acct_ccy  DECIMAL(18,4)  NOT NULL,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_order_sec  FOREIGN KEY (sec_id)  REFERENCES sec_ref(sec_id),
    CONSTRAINT fk_order_acct FOREIGN KEY (acct_id) REFERENCES account(acct_id),
    CONSTRAINT chk_order_type   CHECK (order_type   IN ('Buy', 'Sell')),
    CONSTRAINT chk_order_nature CHECK (order_nature IN ('Limit', 'Market'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Transaction table
CREATE TABLE IF NOT EXISTS `transaction` (
    tran_id                     BIGINT         NOT NULL COMMENT '14-digit transaction identifier',
    sec_id                      VARCHAR(12)    NOT NULL,
    acct_id                     BIGINT         NOT NULL,
    order_id                    VARCHAR(14)    NOT NULL,
    book_date                   DATETIME       NOT NULL,
    tran_date                   DATETIME       NOT NULL,
    tran_type                   VARCHAR(4)     NOT NULL COMMENT 'Buy or Sell',
    qty                         INT            NOT NULL,
    avg_unit_price_in_sec_ccy   DECIMAL(18,4)  NOT NULL,
    avg_unit_price_in_acct_ccy  DECIMAL(18,4)  NOT NULL,
    PRIMARY KEY (tran_id),
    CONSTRAINT fk_tran_sec   FOREIGN KEY (sec_id)   REFERENCES sec_ref(sec_id),
    CONSTRAINT fk_tran_acct  FOREIGN KEY (acct_id)  REFERENCES account(acct_id),
    CONSTRAINT fk_tran_order FOREIGN KEY (order_id)  REFERENCES `order`(order_id),
    CONSTRAINT chk_tran_type CHECK (tran_type IN ('Buy', 'Sell'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Position table
CREATE TABLE IF NOT EXISTS `position` (
    posn_id                     BIGINT         NOT NULL COMMENT '12-digit position identifier',
    sec_id                      VARCHAR(12)    NOT NULL,
    acct_id                     BIGINT         NOT NULL,
    qty                         INT            NOT NULL,
    avg_unit_price_in_sec_ccy   DECIMAL(18,4)  NOT NULL,
    avg_unit_price_in_acct_ccy  DECIMAL(18,4)  NOT NULL,
    PRIMARY KEY (posn_id),
    CONSTRAINT fk_posn_sec  FOREIGN KEY (sec_id)  REFERENCES sec_ref(sec_id),
    CONSTRAINT fk_posn_acct FOREIGN KEY (acct_id) REFERENCES account(acct_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- DML: Sample Data
-- ============================================================

-- Accounts (10-digit acct_id)
INSERT INTO account (acct_id, acct_type, acct_ccy, open_date, close_date, is_active) VALUES
(5230236685, 'CA', 'USD', '2022-01-15', NULL,         1),
(5230236686, 'CC', 'USD', '2022-03-20', NULL,         1),
(5230236687, 'DA', 'USD', '2022-06-01', NULL,         1),
(5230236688, 'CA', 'GBP', '2021-11-10', NULL,         1),
(5230236689, 'DA', 'EUR', '2023-02-28', NULL,         1),
(5230236690, 'CC', 'INR', '2020-07-05', NULL,         1),
(5230236691, 'CA', 'INR', '2019-04-12', NULL,         1),
(5230236692, 'DA', 'GBP', '2023-08-15', NULL,         1),
(5230236693, 'CC', 'EUR', '2021-09-30', '2024-09-30', 0),
(5230236694, 'CA', 'USD', '2024-01-01', NULL,         1);

-- Securities (ISIN as sec_id)
INSERT INTO sec_ref (sec_id, sec_name, unit_price, sec_ccy, is_active) VALUES
('US0378331005', 'Apple Inc.',              189.8400, 'USD', 1),
('US5949181045', 'Microsoft Corp.',        378.9100, 'USD', 1),
('INE002A01018', 'Reliance Industries',   2485.5000, 'INR', 1),
('GB0005405286', 'HSBC Holdings',          652.3000, 'GBP', 1),
('DE0007236101', 'Siemens AG',             163.4200, 'EUR', 1),
('US02079K3059', 'Alphabet Inc.',          141.8000, 'USD', 1),
('INE467B01029', 'Tata Consultancy',      3780.0000, 'INR', 1),
('GB0009895292', 'AstraZeneca PLC',      10840.0000, 'GBP', 1),
('DE0007164600', 'SAP SE',                 178.5600, 'EUR', 1),
('INE009A01021', 'Infosys Ltd.',          1450.2500, 'INR', 0);

-- Orders (ODR-prefixed 14-char order_id, order_date as DATE)
INSERT INTO `order` (order_id, sec_id, acct_id, order_type, order_date, expiry_date, order_nature, qty, avg_unit_price_in_sec_ccy, avg_unit_price_in_acct_ccy) VALUES
('ODR52136552354', 'US0378331005', 5230236685, 'Buy',  '2024-06-01', '2024-06-15', 'Market', 50,   187.5000,  187.5000),
('ODR52136552355', 'US5949181045', 5230236685, 'Buy',  '2024-06-02', '2024-06-16', 'Limit',  20,   375.0000,  375.0000),
('ODR52136552356', 'INE002A01018', 5230236691, 'Buy',  '2024-06-03', '2024-06-17', 'Market', 100,  2450.0000, 2450.0000),
('ODR52136552357', 'GB0005405286', 5230236688, 'Buy',  '2024-06-05', '2024-06-19', 'Limit',  30,   648.0000,  648.0000),
('ODR52136552358', 'DE0007236101', 5230236689, 'Buy',  '2024-06-07', '2024-06-21', 'Market', 40,   160.0000,  160.0000),
('ODR52136552359', 'US0378331005', 5230236685, 'Sell', '2024-07-10', '2024-07-24', 'Market', 20,   192.0000,  192.0000),
('ODR52136552360', 'US02079K3059', 5230236687, 'Buy',  '2024-07-15', '2024-07-29', 'Limit',  60,   139.5000,  139.5000),
('ODR52136552361', 'INE467B01029', 5230236690, 'Buy',  '2024-08-01', '2024-08-15', 'Market', 25,   3750.0000, 3750.0000),
('ODR52136552362', 'GB0009895292', 5230236692, 'Buy',  '2024-08-10', '2024-08-24', 'Limit',  10,  10750.0000, 10750.0000),
('ODR52136552363', 'DE0007164600', 5230236689, 'Buy',  '2024-08-20', '2024-09-03', 'Market', 35,   176.0000,  176.0000),
('ODR52136552364', 'INE002A01018', 5230236691, 'Sell', '2024-09-01', '2024-09-15', 'Limit',  50,   2500.0000, 2500.0000),
('ODR52136552365', 'US5949181045', 5230236694, 'Buy',  '2024-09-10', '2024-09-24', 'Market', 15,   380.0000,  380.0000);

-- Transactions (14-digit tran_id)
INSERT INTO `transaction` (tran_id, sec_id, acct_id, order_id, book_date, tran_date, tran_type, qty, avg_unit_price_in_sec_ccy, avg_unit_price_in_acct_ccy) VALUES
(32015544126523, 'US0378331005', 5230236685, 'ODR52136552354', '2024-06-01 09:35:00', '2024-06-03 00:00:00', 'Buy',  50,   187.5000,  187.5000),
(32015544126524, 'US5949181045', 5230236685, 'ODR52136552355', '2024-06-02 10:05:00', '2024-06-04 00:00:00', 'Buy',  20,   375.0000,  375.0000),
(32015544126525, 'INE002A01018', 5230236691, 'ODR52136552356', '2024-06-03 11:20:00', '2024-06-05 00:00:00', 'Buy',  100,  2450.0000, 2450.0000),
(32015544126526, 'GB0005405286', 5230236688, 'ODR52136552357', '2024-06-05 14:05:00', '2024-06-07 00:00:00', 'Buy',  30,   648.0000,  648.0000),
(32015544126527, 'DE0007236101', 5230236689, 'ODR52136552358', '2024-06-07 09:50:00', '2024-06-11 00:00:00', 'Buy',  40,   160.0000,  160.0000),
(32015544126528, 'US0378331005', 5230236685, 'ODR52136552359', '2024-07-10 10:35:00', '2024-07-12 00:00:00', 'Sell', 20,   192.0000,  192.0000),
(32015544126529, 'US02079K3059', 5230236687, 'ODR52136552360', '2024-07-15 11:05:00', '2024-07-17 00:00:00', 'Buy',  60,   139.5000,  139.5000),
(32015544126530, 'INE467B01029', 5230236690, 'ODR52136552361', '2024-08-01 09:05:00', '2024-08-05 00:00:00', 'Buy',  25,   3750.0000, 3750.0000),
(32015544126531, 'GB0009895292', 5230236692, 'ODR52136552362', '2024-08-10 13:35:00', '2024-08-12 00:00:00', 'Buy',  10,  10750.0000, 10750.0000),
(32015544126532, 'DE0007164600', 5230236689, 'ODR52136552363', '2024-08-20 15:05:00', '2024-08-22 00:00:00', 'Buy',  35,   176.0000,  176.0000),
(32015544126533, 'INE002A01018', 5230236691, 'ODR52136552364', '2024-09-01 10:05:00', '2024-09-03 00:00:00', 'Sell', 50,   2500.0000, 2500.0000),
(32015544126534, 'US5949181045', 5230236694, 'ODR52136552365', '2024-09-10 09:35:00', '2024-09-12 00:00:00', 'Buy',  15,   380.0000,  380.0000);

-- Positions (12-digit posn_id)
INSERT INTO `position` (posn_id, sec_id, acct_id, qty, avg_unit_price_in_sec_ccy, avg_unit_price_in_acct_ccy) VALUES
(120365112574, 'US0378331005', 5230236685, 30,  187.5000,   187.5000),
(120365112575, 'US5949181045', 5230236685, 20,  375.0000,   375.0000),
(120365112576, 'INE002A01018', 5230236691, 50,  2450.0000,  2450.0000),
(120365112577, 'GB0005405286', 5230236688, 30,  648.0000,   648.0000),
(120365112578, 'DE0007236101', 5230236689, 40,  160.0000,   160.0000),
(120365112579, 'US02079K3059', 5230236687, 60,  139.5000,   139.5000),
(120365112580, 'INE467B01029', 5230236690, 25,  3750.0000,  3750.0000),
(120365112581, 'GB0009895292', 5230236692, 10,  10750.0000, 10750.0000),
(120365112582, 'DE0007164600', 5230236689, 35,  176.0000,   176.0000),
(120365112583, 'US5949181045', 5230236694, 15,  380.0000,   380.0000);
