CREATE TABLE [dbo].[tblPATRetireStock]
(
	[intRetireStockId] INT NOT NULL IDENTITY, 
	[intCustomerStockId] INT NULL, 
    [intCustomerPatronId] INT NOT NULL, 
    [strRetireNo] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[dtmRetireDate] DATETIME NULL,
    [dblSharesNo] NUMERIC(18, 6) NOT NULL, 
	[dblParValue] NUMERIC(18,6) NULL,
	[dblFaceValue] NUMERIC(18,6) NULL,
	[ysnPosted] BIT NULL DEFAULT 0,
	[intBillId] INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblPATRetireStock] PRIMARY KEY ([intRetireStockId]), 
	CONSTRAINT [FK_tblPATRetireStock_tblPATCustomerStock] FOREIGN KEY ([intCustomerStockId]) REFERENCES [tblPATCustomerStock]([intCustomerStockId]),
	CONSTRAINT [FK_tblPATRetireStock_tblAPBill] FOREIGN KEY (intBillId) REFERENCES [tblAPBill]([intBillId]) ON DELETE SET NULL,
)