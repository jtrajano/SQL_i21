﻿
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory ='AP Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES ( N'AP Account', 'Payables', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'AR Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'AR Account', 'Receivables', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Begin Inventory')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Begin Inventory', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Broker Expense')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Broker Expense',  1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Cash Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Cash Account','CashAccounts', 2)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Cash Over/Short')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Cash Over/Short','Expense&Revenue', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Contract Equity')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Contract Equity', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Contract Purchase Gain/Loss')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Contract Purchase Gain/Loss',  1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Contract Sales Gain/Loss')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Contract Sales Gain/Loss',  1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Cost of Goods')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Cost of Goods','CostOfGoodsSold', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Credit Card Fee')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Credit Card Fee', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Currency Equity')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Currency Equity', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Currency Purchase Gain/Loss')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Currency Purchase Gain/Loss', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Currency Sales Gain/Loss')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Currency Sales Gain/Loss', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Deposit Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Deposit Account','CashAccounts', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Discount Receivable')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Discount Receivable', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'DP Income')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'DP Income', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'DP Liability')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'DP Liability', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'End Inventory')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'End Inventory', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Fee Expense')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Fee Expense', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Fee Income')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Fee Income', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Freight AP Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Freight AP Account',  1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Freight Expenses')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Freight Expenses',1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Freight Income')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Freight Income', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Interest Expense')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Interest Expense',1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Interest Income')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Interest Income', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Inventory')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Inventory','Inventories', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Options Expense')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Options Expense', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Options Income')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Options Income', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Purchase Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Purchase Account', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Purchase Adv Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Purchase Adv Account', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Rail Freight')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Rail Freight', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Sales Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Sales Account', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Sales Adv Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Sales Adv Account', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Sales Discount')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Sales Discount', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Service Charges')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Service Charges', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Storage Expense')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Storage Expense', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Storage Income')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Storage Income', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Storage Receivable')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Storage Receivable', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Variance Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Variance Account', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Write Off')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Write Off', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Write-Off Sold')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Write-Off Sold', 'Expense', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Revalue Sold')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Revalue Sold',  'Expense',1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Auto-Negative')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Auto-Negative','Expense', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'AP Clearing')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],strAccountGroupFilter, [intConcurrencyId]) VALUES (N'AP Clearing', 'Payables',1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Inventory In-Transit')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Inventory In-Transit', 'Inventories', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'General')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],  [intConcurrencyId]) VALUES (N'General', 1)

IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Sales Tax Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],  strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Sales Tax Account', 'SalesTax',1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Purchase Tax Account')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],  strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Purchase Tax Account', 'PurchaseTax',1)

--DEFAULTS ALL ACCOUNTS WITH NO CATEGORY TO GENERAL
UPDATE tblGLAccount SET intAccountCategoryId=(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'General')
WHERE intAccountCategoryId IS NULL
 
;WITH cte(intAccountCategoryId)
AS
(
	SELECT intAccountCategoryId from tblGLAccountCategory where strAccountCategory in
	('Begin Inventory','Broker Expense','Contract Equity','Contract Purchase Gain/Loss','Contract Sales Gain/Loss','Cost of Goods','Currency Equity',
	'Currency Purchase Gain/Loss','Currency Sales Gain/Loss','Discount Receivable','DP Income','DP Liability','End Inventory','Fee Expense','Fee Income',
	'Freight Expenses','Interest Expense','Interest Income','Inventory','Options Expense','Options Income','Purchase Account','Rail Freight','Sales Account',
	'Storage Expense','Storage Income','Storage Receivable','Variance Account','Write-Off Sold','Auto-Negative') 	

)
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT a.intAccountCategoryId,'Inventories','INV' from cte a
			LEFT JOIN tblGLAccountCategoryGroup b on a.intAccountCategoryId = b.intAccountCategoryId
			WHERE b.intAccountCategoryId IS NULL


