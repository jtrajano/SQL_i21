CREATE TABLE [dbo].[tblPATDividendsCustomer]
(
	[intDividendCustomerId] INT NOT NULL IDENTITY, 
    [intDividendId] INT NOT NULL, 
    [intCustomerId] INT NULL,
    [strStockStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmLastActivityDate] DATETIME NULL, 
    [dblLessFWT] NUMERIC(18, 6) NULL, 
    [dblCheckAmount] NUMERIC(18, 6) NULL, 
	[dblDividendAmount] NUMERIC(18, 6) NULL,
	[intBillId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATDividendsCustomer] PRIMARY KEY ([intDividendCustomerId]), 
    CONSTRAINT [FK_tblPATDividendsCustomer_tblPATDividends] FOREIGN KEY ([intDividendId]) REFERENCES [tblPATDividends]([intDividendId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblPATDividendsCustomer_tblAPBill] FOREIGN KEY (intBillId) REFERENCES [tblAPBill]([intBillId]) ON DELETE SET NULL
)