CREATE TABLE [dbo].[tblPATIssueStock]
(
	[intIssueStockId] INT NOT NULL IDENTITY, 
    [intCustomerPatronId] INT NOT NULL, 
    [intStockId] INT NOT NULL, 
    [strCertificateNo] CHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strStockType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dblSharesNo] NUMERIC(18, 6) NOT NULL, 
    [dtmIssueDate] DATETIME NOT NULL, 
    [strStockStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCheckNumber] CHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [dtmCheckDate] DATETIME NULL, 
    [dblCheckAmount] NUMERIC(18, 6) NULL, 
    [intTransferredFrom] INT NULL, 
    [dtmTransferredDate] DATETIME NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATIssueStock] PRIMARY KEY ([intIssueStockId]), 
    CONSTRAINT [FK_tblPATIssueStock_StockClassification] FOREIGN KEY ([intStockId]) REFERENCES [tblPATStockClassification]([intStockId])
)
