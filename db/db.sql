
-- -- name: create-stock-table
-- -- Create the table to hold each known stock issue.
-- CREATE TABLE IF NOT EXISTS stock (
--     id SERIAL PRIMARY KEY,
--     symbol TEXT NOT NULL UNIQUE,
--     description TEXT NOT NULL UNIQUE,
--     currency TEXT NOT NULL,
--     type TEXT NOT NULL UNIQUE
-- );


-- -- name: create-tick-data-table
-- -- Create the table to hold the tick data for a given issue.
-- CREATE TABLE IF NOT EXISTS tick_data
-- (
--   id SERIAL PRIMARY KEY,
--   dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
--   stock_id INTEGER NOT NULL,
--   open NUMERIC NOT NULL,
--   high NUMERIC NOT NULL,
--   low NUMERIC NOT NULL,
--   close NUMERIC NOT NULL,
--   volume NUMERIC NOT NULL,
--   CONSTRAINT fk_stock FOREIGN KEY(stock_id) REFERENCES stock(id)
-- );

CREATE TABLE IF NOT EXISTS stock (
    id SERIAL PRIMARY KEY,
    symbol TEXT NOT NULL,
    name TEXT NOT NULL,
    exchange TEXT NOT NULL,
    is_etf BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS mention (
       stock_id INTEGER,
       dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
       message TEXT NOT NULL,
       source TEXT NOT NULL, -- wallstreetbets, twitter, other &etc
       url TEXT NOT NULL,
       PRIMARY KEY (stock_id, dt),
       CONSTRAINT fk_mention_stock FOREIGN KEY (stock_id) REFERENCES stock (id)
);

CREATE INDEX ON mention (stock_id, dt DESC);

SELECT create_hypertable('mention', 'dt');

CREATE TABLE IF NOT EXISTS etf_holding (
    etf_id INTEGER NOT NULL, 
    holding_id INTEGER NOT NULL,
    dt DATE NOT NULL, 
    shares NUMERIC,
    weight NUMERIC, 
    PRIMARY KEY (etf_id, holding_id, dt),
    CONSTRAINT fk_etf FOREIGN KEY (etf_id) REFERENCES stock (id),
    CONSTRAINT fk_holding FOREIGN KEY (holding_id) REFERENCES stock (id)
);

CREATE TABLE IF NOT EXISTS stock_price (
    stock_id INTEGER NOT NULL,
    dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    open NUMERIC NOT NULL, 
    high NUMERIC NOT NULL,
    low NUMERIC NOT NULL,
    close NUMERIC NOT NULL, 
    volume NUMERIC NOT NULL,
    PRIMARY KEY (stock_id, dt),
    CONSTRAINT fk_stock FOREIGN KEY (stock_id) REFERENCES stock (id)
);

CREATE INDEX ON stock_price (stock_id, dt DESC);

SELECT create_hypertable('stock_price', 'dt');
