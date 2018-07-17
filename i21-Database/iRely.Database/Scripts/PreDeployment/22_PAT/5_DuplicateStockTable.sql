PRINT N'*** BEGIN - DUPLICATE tblPATCustomerStock ***'
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATCustomerStock')
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATCustomerStock]) AND ((SELECT CASE WHEN MAX(strVersionNo) like '17%' THEN 1 ELSE 0 END FROM tblSMBuildNumber) = 1)
	BEGIN
		EXEC('
			IF EXISTS(SELECT 1 FROM sys.tables WHERE name = ''tmptblPATCustomerStock'') DROP TABLE tmptblPATCustomerStock

			CREATE TABLE [dbo].[tmptblPATCustomerStock](
				[inttmpCustomerStockId] [int] IDENTITY(1,1) NOT NULL,
				[intCustomerStockId] [int] NULL,
				[intCustomerPatronId] [int] NULL,
				[intStockId] [int] NULL,
				[strCertificateNo] [nvarchar](25) NULL,
				[strStockStatus] [nvarchar](25) NULL,
				[dblSharesNo] [numeric](18, 6) NULL,
				[dtmIssueDate] [datetime] NULL,
				[strActivityStatus] [nvarchar](25) NULL,
				[dtmRetireDate] [datetime] NULL,
				[intTransferredFrom] [int] NULL,
				[dtmTransferredDate] [datetime] NULL,
				[dblParValue] [numeric](18, 6) NULL,
				[dblFaceValue] [numeric](18, 6) NULL,
				[ysnPosted] [bit] NULL DEFAULT ((0)),
				[ysnRetiredPosted] [bit] NULL DEFAULT ((0)),
				[intBillId] [int] NULL,
				[intInvoiceId] [int] NULL,
				[intConcurrencyId] [int] NULL DEFAULT ((1))
				)
		
		
			INSERT INTO tmptblPATCustomerStock([intCustomerStockId],
				[intCustomerPatronId],
				[intStockId],
				[strCertificateNo],
				[strStockStatus],
				[dblSharesNo],
				[dtmIssueDate],
				[strActivityStatus],
				[dtmRetireDate],
				[intTransferredFrom],
				[dtmTransferredDate],
				[dblParValue],
				[dblFaceValue],
				[ysnPosted],
				[ysnRetiredPosted],
				[intBillId],
				[intInvoiceId],
				[intConcurrencyId])
			SELECT [intCustomerStockId],
				[intCustomerPatronId],
				[intStockId],
				[strCertificateNo],
				[strStockStatus],
				[dblSharesNo],
				[dtmIssueDate],
				[strActivityStatus],
				[dtmRetireDate],
				[intTransferredFrom],
				[dtmTransferredDate],
				[dblParValue],
				[dblFaceValue],
				[ysnPosted],
				[ysnRetiredPosted],
				[intBillId],
				[intInvoiceId],
				[intConcurrencyId]
			FROM [dbo].[tblPATCustomerStock]
		')
	END

END
PRINT N'*** END - DUPLICATE tblPATCustomerStock ***'
GO