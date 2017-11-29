PRINT N'*** BEGIN - MIGRATE tblPATCustomerStock RECORDS TO tblPATIssueStock & tblPATRetireStock ***'
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATIssueStock')
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATIssueStock] IssueStk 
			LEFT JOIN [dbo].[tblPATCustomerStock] CustomerStk ON CustomerStk.intCustomerStockId = IssueStk.intCustomerStockId
			WHERE CustomerStk.strActivityStatus = 'Open' AND IssueStk.intIssueStockId IS NOT NULL)
			BEGIN
				EXEC('
				SELECT * 
				INTO #tmpIssueStock
				FROM [dbo].[tblPATCustomerStock]
				WHERE [strActivityStatus] = ''Open''

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

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATRetireStock')
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATRetireStock] RetireStk 
			LEFT JOIN [dbo].[tblPATCustomerStock] CustomerStk ON CustomerStk.intCustomerStockId = RetireStk.intCustomerStockId
			WHERE CustomerStk.strActivityStatus = 'Retire' AND RetireStk.intRetireStockId IS NOT NULL)
			BEGIN
				EXEC('
				SELECT * 
				INTO #tmpRetireStock
				FROM [dbo].[tblPATRetireStock]
				WHERE [strActivityStatus] = ''Retire''

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