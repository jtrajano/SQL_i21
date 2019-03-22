PRINT N'*** BEGIN - MIGRATE tblPATCustomerStock RECORDS TO tblPATIssueStock & tblPATRetireStock ***'
GO
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATIssueStock') 
	AND EXISTS(SELECT 1 FROM sys.tables WHERE name = 'tmptblPATCustomerStock')
BEGIN
			EXEC('
			IF NOT EXISTS(SELECT 1 FROM [dbo].[tblPATIssueStock] IssueStk 
			INNER JOIN tmptblPATCustomerStock CustomerStk ON CustomerStk.intCustomerStockId = IssueStk.intCustomerStockId
			WHERE (CustomerStk.strActivityStatus = ''Open'' OR CustomerStk.strActivityStatus = ''Xferred'')  AND IssueStk.intIssueStockId IS NOT NULL)
			BEGIN

				INSERT INTO [dbo].[tblPATIssueStock](
					[intCustomerStockId], 
					[intCustomerPatronId], 
					[dtmIssueDate], 
					[strCertificateNo], 
					[intStockId], 
					[strStockStatus], 
					[dblSharesNo], 
					[dblParValue], 
					[dblFaceValue], 
					[ysnPosted], 
					[intInvoiceId])
				SELECT 	[CustomerStk].[intCustomerStockId], 
						[CustomerStk].[intCustomerPatronId], 
						[CustomerStk].[dtmIssueDate], 
						[CustomerStk].[strCertificateNo], 
						[CustomerStk].[intStockId], 
						[CustomerStk].[strStockStatus], 
						[CustomerStk].[dblSharesNo], 
						[CustomerStk].[dblParValue], 
						[CustomerStk].[dblFaceValue], 
						[CustomerStk].[ysnPosted], 
						[CustomerStk].[intInvoiceId]
				FROM tmptblPATCustomerStock CustomerStk
				LEFT OUTER JOIN [dbo].[tblPATIssueStock] IssueStk ON CustomerStk.intCustomerStockId = IssueStk.intCustomerStockId
				WHERE IssueStk.intCustomerStockId IS NULL

				DELETE FROM tmptblPATCustomerStock
				WHERE [strActivityStatus] = ''Open'' AND [ysnPosted] = 0

				
			END
			')
END

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATRetireStock')
	AND EXISTS(SELECT 1 FROM sys.tables WHERE name = 'tmptblPATCustomerStock')
BEGIN
		EXEC('
			IF NOT EXISTS(SELECT 1 FROM [dbo].[tblPATRetireStock] RetireStk 
			INNER JOIN tmptblPATCustomerStock CustomerStk ON CustomerStk.intCustomerStockId = RetireStk.intCustomerStockId
			WHERE CustomerStk.strActivityStatus = ''Retired'' AND RetireStk.intRetireStockId IS NOT NULL)
			BEGIN

				INSERT INTO [dbo].[tblPATRetireStock](
					[intCustomerStockId], 
					[intCustomerPatronId], 
					[dtmRetireDate], 
					[dblSharesNo], 
					[dblParValue], 
					[dblFaceValue], 
					[ysnPosted], 
					[intBillId])
				SELECT 	[CustomerStk].[intCustomerStockId], 
						[CustomerStk].[intCustomerPatronId], 
						[CustomerStk].[dtmRetireDate], 
						[CustomerStk].[dblSharesNo], 
						[CustomerStk].[dblParValue], 
						[CustomerStk].[dblFaceValue], 
						[ysnPosted] = CASE WHEN [CustomerStk].[intBillId] IS NOT NULL THEN 1 ELSE 0 END, 
						[CustomerStk].[intBillId]
				FROM tmptblPATCustomerStock CustomerStk
				LEFT JOIN [dbo].[tblPATRetireStock] RetireStk ON CustomerStk.intCustomerStockId = RetireStk.intCustomerStockId
				WHERE CustomerStk.strActivityStatus = ''Retired'' AND RetireStk.intRetireStockId IS NULL


				DELETE FROM tmptblPATCustomerStock
				WHERE [strActivityStatus] = ''Retire'' AND [intBillId] IS NULL
				
				
			END
			')
END

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'tmptblPATCustomerStock')
BEGIN
	EXEC('
		DELETE FROM [dbo].[tblPATCustomerStock]
		WHERE intCustomerStockId NOT IN (SELECT intCustomerStockId FROM tmptblPATCustomerStock)

		DROP TABLE tmptblPATCustomerStock
	')
END


PRINT N'*** END - MIGRATE tblPATCustomerStock RECORDS TO tblPATIssueStock & tblPATRetireStock ***'
GO