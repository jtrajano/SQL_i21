PRINT N'*** BEGIN - CREATE tblPATIssueStock & tblPATRetireStock ***'
GO
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATIssueStock')
BEGIN
	EXEC('CREATE TABLE [dbo].[tblPATIssueStock]
	(
		[intIssueStockId] INT NOT NULL IDENTITY, 
		[intCustomerStockId] INT NULL, 
		[intCustomerPatronId] INT NOT NULL, 
		[strIssueNo] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
		[dtmIssueDate] DATETIME NULL,
		[strCertificateNo] NVARCHAR(25) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intStockId] INT NOT NULL,
		[strStockStatus] NVARCHAR(25) COLLATE Latin1_General_CI_AS NOT NULL, 
		[dblSharesNo] NUMERIC(18,6) NOT NULL, 
		[dblParValue] NUMERIC(18,6) NULL,
		[dblFaceValue] NUMERIC(18,6) NULL,
		[ysnPosted] BIT NULL DEFAULT 0,
		[intInvoiceId] INT NULL,
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblPATIssueStock] PRIMARY KEY ([intIssueStockId]), 
		CONSTRAINT [AK_tblPATIssueStock_strCertificateNo] UNIQUE ([strCertificateNo]),
		CONSTRAINT [FK_tblPATIssueStock_tblPATStockClassification] FOREIGN KEY ([intStockId]) REFERENCES [tblPATStockClassification]([intStockId]),
		CONSTRAINT [FK_tblPATIssueStock_tblPATCustomerStock] FOREIGN KEY ([intCustomerStockId]) REFERENCES [tblPATCustomerStock]([intCustomerStockId]) ON DELETE SET NULL,
		CONSTRAINT [FK_tblPATIssueStock_tblARInvoice] FOREIGN KEY (intInvoiceId) REFERENCES [tblARInvoice]([intInvoiceId]) ON DELETE SET NULL,
	)')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATRetireStock')
BEGIN
	EXEC('CREATE TABLE [dbo].[tblPATRetireStock]
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
	)')
END
PRINT N'*** END - CREATE tblPATIssueStock & tblPATRetireStock ***'
GO