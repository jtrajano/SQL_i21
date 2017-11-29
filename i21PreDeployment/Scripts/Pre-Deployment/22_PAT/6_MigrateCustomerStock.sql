PRINT N'*** BEGIN - MIGRATE tblPATCustomerStock RECORDS TO tblPATIssueStock & tblPATRetireStock ***'
GO
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATIssueStock')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM [dbo].[tblPATIssueStock] IssueStk 
			INNER JOIN [dbo].[tblPATCustomerStock] CustomerStk ON CustomerStk.intCustomerStockId = IssueStk.intCustomerStockId
			WHERE CustomerStk.strActivityStatus = 'Open' AND IssueStk.intIssueStockId IS NOT NULL)
			BEGIN
				EXEC('
				SELECT	CustomerStk.*
				INTO #tmpIssueStock
				FROM [dbo].[tblPATCustomerStock] CustomerStk 
				LEFT OUTER JOIN [dbo].[tblPATIssueStock] IssueStk ON CustomerStk.intCustomerStockId = IssueStk.intCustomerStockId
				WHERE IssueStk.intCustomerStockId IS NULL

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
				SELECT 	[intCustomerStockId], 
						[intCustomerPatronId], 
						[dtmIssueDate], 
						[strCertificateNo], 
						[intStockId], 
						[strStockStatus], 
						[dblSharesNo], 
						[dblParValue], 
						[dblFaceValue], 
						[ysnPosted], 
						[intInvoiceId]
				FROM #tmpIssueStock

				DELETE FROM [dbo].[tblPATCustomerStock]
				WHERE [strActivityStatus] = ''Open'' AND [ysnPosted] = 0

				IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID(''tempdb..#tmpIssueStock'')) DROP TABLE #tmpIssueStock
				')
			END
END

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATRetireStock')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM [dbo].[tblPATRetireStock] RetireStk 
			INNER JOIN [dbo].[tblPATCustomerStock] CustomerStk ON CustomerStk.intCustomerStockId = RetireStk.intCustomerStockId
			WHERE CustomerStk.strActivityStatus = 'Retired' AND RetireStk.intRetireStockId IS NOT NULL)
			BEGIN
				EXEC('
				SELECT	CustomerStk.*
				INTO #tmpRetireStock
				FROM [dbo].[tblPATCustomerStock] CustomerStk 
				LEFT JOIN [dbo].[tblPATRetireStock] RetireStk ON CustomerStk.intCustomerStockId = RetireStk.intCustomerStockId
				WHERE CustomerStk.strActivityStatus = ''Retired'' AND RetireStk.intRetireStockId IS NULL

				INSERT INTO [dbo].[tblPATRetireStock](
					[intCustomerStockId], 
					[intCustomerPatronId], 
					[dtmRetireDate], 
					[dblSharesNo], 
					[dblParValue], 
					[dblFaceValue], 
					[ysnPosted], 
					[intBillId])
				SELECT 	[intCustomerStockId], 
						[intCustomerPatronId], 
						[dtmRetireDate], 
						[dblSharesNo], 
						[dblParValue], 
						[dblFaceValue], 
						[ysnPosted], 
						[intBillId]
				FROM #tmpRetireStock

				DELETE FROM [dbo].[tblPATCustomerStock]
				WHERE [strActivityStatus] = ''Retire'' AND [ysnPosted] = 0
				
				IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID(''tempdb..#tmpRetireStock'')) DROP TABLE #tmpRetireStock
				')
			END
END
PRINT N'*** END - MIGRATE tblPATCustomerStock RECORDS TO tblPATIssueStock & tblPATRetireStock ***'
GO