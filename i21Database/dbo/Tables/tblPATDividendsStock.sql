﻿CREATE TABLE [dbo].[tblPATDividendsStock]
(
	[intDividendStockId] INT NOT NULL IDENTITY, 
    [intDividendCustomerId] INT NOT NULL, 
    [intCustomerId] INT NULL, 
    [intStockId] INT NULL, 
    [dblParValue] NUMERIC(18, 6) NULL, 
    [dblNoOfShare] NUMERIC(18, 6) NULL, 
    [dblDividendPerShare] NUMERIC(18, 6) NULL, 
    [dblDividendAmount] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATDividendsStock] PRIMARY KEY ([intDividendStockId]), 
    CONSTRAINT [FK_tblPATDividendsStock_tblPATDividendsCustomer] FOREIGN KEY ([intDividendCustomerId]) REFERENCES [tblPATDividendsCustomer]([intDividendCustomerId]) 
)
