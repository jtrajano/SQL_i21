CREATE TABLE [dbo].[tblPATCustomerStock]
(
	[intCustomerStockId] INT NOT NULL IDENTITY, 
    [intCustomerPatronId] INT NOT NULL, 
    [intStockId] INT NOT NULL, 
    [strCertificateNo] CHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strStockStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dblSharesNo] NUMERIC(18, 6) NOT NULL, 
    [dtmIssueDate] DATETIME NOT NULL, 
    [strActivityStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dtmRetireDate] DATETIME NULL,
    [intTransferredFrom] INT NULL, 
    [dtmTransferredDate] DATETIME NULL, 
	[dblParValue] NUMERIC(18,6) NULL,
	[dblFaceValue] NUMERIC(18,6) NULL,
	[ysnPosted] BIT NULL DEFAULT 0,
	[intBillId] INT NULL,
	[intInvoiceId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATCustomerStock] PRIMARY KEY ([intCustomerStockId]), 
    CONSTRAINT [FK_tblPATCustomerStock_StockClassification] FOREIGN KEY ([intStockId]) REFERENCES [tblPATStockClassification]([intStockId]),
	CONSTRAINT [UQ_tblPATCustomerStock_strCertificateNo] UNIQUE ([strCertificateNo])
)