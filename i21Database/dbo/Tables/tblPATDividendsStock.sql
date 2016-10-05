CREATE TABLE [dbo].[tblPATDividendsStock]
(
	[intDividendStockId] INT NOT NULL IDENTITY, 
    [intDividendCustomerId] INT NOT NULL, 
    [intCustomerId] INT NULL, 
    [intStockId] INT NULL,
	[intCustomerStockId] INT NOT NULL, 
    [dblParValue] NUMERIC(18, 6) NULL, 
    [dblSharesNo] NUMERIC(18, 6) NULL, 
    [intDividendsPerShare] INT NULL, 
    [dblDividendAmount] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATDividendsStock] PRIMARY KEY ([intDividendStockId]), 
    CONSTRAINT [FK_tblPATDividendsStock_tblPATDividendsCustomer] FOREIGN KEY ([intDividendCustomerId]) REFERENCES [tblPATDividendsCustomer]([intDividendCustomerId]),
	CONSTRAINT [FK_tblPATDividendsStock_tblPATStockClassification] FOREIGN KEY ([intStockId]) REFERENCES [tblPATStockClassification]([intStockId]),
	CONSTRAINT [FK_tblPATDividendsStock_tblPATCustomerStock] FOREIGN KEY ([intCustomerStockId]) REFERENCES [tblPATCustomerStock]([intCustomerStockId])
)
