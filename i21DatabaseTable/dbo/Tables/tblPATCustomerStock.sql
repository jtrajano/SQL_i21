CREATE TABLE [dbo].[tblPATCustomerStock]
(
	[intCustomerStockId]	INT NOT NULL IDENTITY, 
    [intCustomerPatronId]	INT NOT NULL, 
    [intStockId]			INT NOT NULL, 
    [strCertificateNo]		NVARCHAR(25) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strStockStatus]		NVARCHAR(25) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strActivityStatus]		NVARCHAR(25) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intTransferredIssueStockId] INT NULL,
    [intTransferredFrom]	INT NULL, 
    [dtmTransferredDate]	DATETIME NULL, 
	[dblSharesNo]			NUMERIC(18, 6) NOT NULL, 
	[dblParValue]			NUMERIC(18,6) NULL,
	[dblFaceValue]			NUMERIC(18,6) NULL,
	--[ysnPosted]				BIT NULL,
	--[ysnRetiredPosted]		BIT NULL,
	--[intBillId]				BIT NULL,
	--[intInvoiceId]			INT NULL,
	--[dtmIssueDate]			DATETIME NOT NULL,
    [intConcurrencyId]		INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblPATCustomerStock] PRIMARY KEY ([intCustomerStockId]), 
    CONSTRAINT [FK_tblPATCustomerStock_tblPATStockClassification] FOREIGN KEY ([intStockId]) REFERENCES [tblPATStockClassification]([intStockId]),
	CONSTRAINT [AK_tblPATCustomerStock_strCertificateNo] UNIQUE ([strCertificateNo])
)