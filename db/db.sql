
-- name: create-stock-table
-- Create the table to hold each known stock issue.
CREATE TABLE IF NOT EXISTS stock (
    id SERIAL PRIMARY KEY,
    symbol TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL UNIQUE,
    currency TEXT NOT NULL,
    type TEXT NOT NULL UNIQUE
);


-- name: create-tick-data-table
-- Create the table to hold the tick data for a given issue.
CREATE TABLE IF NOT EXISTS tick_data
(
  id SERIAL PRIMARY KEY,
  dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  stock_id INTEGER NOT NULL,
  open NUMERIC NOT NULL,
  high NUMERIC NOT NULL,
  low NUMERIC NOT NULL,
  close NUMERIC NOT NULL,
  volume NUMERIC NOT NULL,
  CONSTRAINT fk_stock FOREIGN KEY(stock_id) REFERENCES stock(id)
);
