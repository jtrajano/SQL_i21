BEGIN -- ACCOUNT CATEGORY DEFAULTS
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
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Undeposited Funds')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],  strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Undeposited Funds', 'Undeposited Funds',1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Inventory Adjustment')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory],  strAccountGroupFilter, [intConcurrencyId]) VALUES (N'Inventory Adjustment', 'Expense',1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Work In Progress')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Work In Progress', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Vendor Prepayments', 1)
IF NOT EXISTS(SELECT TOP 1 1  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Customer Prepayments')
	INSERT [dbo].[tblGLAccountCategory] ([strAccountCategory], [intConcurrencyId]) VALUES (N'Customer Prepayments', 1)
END
IF EXISTS (SELECT TOP 1 1 FROM tblGLAccountCategory WHERE strAccountCategory IN ('AR Adjustments','Finance Charges','Customer Discounts','Bad Debts','NSF Checks','Cash in Bank','Petty Cash','Pending AP'))
BEGIN -- Reverting GL-1499 
	DECLARE @GenealCategoryId  INT,@CashCategoryId INT, @APClearing INT
	SELECT  TOP 1 @GenealCategoryId =  intAccountCategoryId  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'General'
	SELECT  TOP 1 @CashCategoryId =  intAccountCategoryId  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Cash Account'
	SELECT  TOP 1 @APClearing =  intAccountCategoryId  FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'AP Clearing'

	UPDATE tblGLAccount SET intAccountCategoryId = @GenealCategoryId
		WHERE intAccountCategoryId IN (SELECT intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory IN ('AR Adjustments','Finance Charges','Customer Discounts','Bad Debts','NSF Checks','Petty Cash'))
	UPDATE tblGLAccountGroup SET intAccountCategoryId = @GenealCategoryId
		WHERE intAccountCategoryId IN (SELECT intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory IN ('AR Adjustments','Finance Charges','Customer Discounts','Bad Debts','NSF Checks','Petty Cash'))
	UPDATE tblGLCOATemplateDetail SET intAccountCategoryId = @GenealCategoryId
		WHERE intAccountCategoryId IN (SELECT intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory IN ('AR Adjustments','Finance Charges','Customer Discounts','Bad Debts','NSF Checks','Petty Cash'))

	UPDATE tblGLAccountGroup SET intAccountCategoryId = @CashCategoryId
		WHERE intAccountCategoryId IN (SELECT intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory = 'Cash in Bank')
	UPDATE tblGLCOATemplateDetail SET intAccountCategoryId = @CashCategoryId
		WHERE intAccountCategoryId IN (SELECT intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory = 'Cash in Bank')
	UPDATE tblGLAccount SET intAccountCategoryId = @CashCategoryId
		WHERE intAccountCategoryId IN (SELECT intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory = 'Cash in Bank')

	UPDATE tblGLAccountGroup SET intAccountCategoryId = @APClearing
		WHERE intAccountCategoryId IN (SELECT intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory = 'Pending AP')
	UPDATE tblGLCOATemplateDetail SET intAccountCategoryId = @APClearing
		WHERE intAccountCategoryId IN (SELECT intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory = 'Pending AP')
	UPDATE tblGLAccount SET intAccountCategoryId = @APClearing
		WHERE intAccountCategoryId IN (SELECT intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory = 'Pending AP')

	DELETE FROM tblGLAccountCategory WHERE strAccountCategory IN ('AR Adjustments','Finance Charges','Customer Discounts','Bad Debts','NSF Checks','Cash in Bank','Petty Cash','Pending AP')
END

BEGIN -- INVENTORY ACCOUNT CATEGORY GROUPING
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Begin Inventory')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Begin Inventory'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Broker Expense')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Broker Expense'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Contract Equity')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Contract Equity'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Contract Purchase Gain/Loss')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Contract Purchase Gain/Loss'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Contract Sales Gain/Loss')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Contract Sales Gain/Loss'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Cost of Goods')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Cost of Goods'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Currency Equity')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Currency Equity'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Currency Purchase Gain/Loss')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Currency Purchase Gain/Loss'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Currency Sales Gain/Loss')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Currency Sales Gain/Loss'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Discount Receivable')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Discount Receivable'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'DP Income')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'DP Income'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'DP Liability')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'DP Liability'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'End Inventory')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'End Inventory'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Fee Expense')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Fee Expense'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Fee Income')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Fee Income'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Freight Expenses')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Freight Expenses'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Interest Expense')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Interest Expense'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Interest Income')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Interest Income'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Inventory')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Inventory'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Options Expense')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Options Expense'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Options Income')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Options Income'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Purchase Account')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Purchase Account'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Rail Freight')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Rail Freight'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Sales Account')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Sales Account'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Storage Expense')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Storage Expense'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Storage Income')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Storage Income'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Storage Receivable')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Storage Receivable'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Variance Account')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Variance Account'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Revalue Sold')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Revalue Sold'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'AP Clearing')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Clearing'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Inventory In-Transit')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Inventory In-Transit'
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory =  'Write-Off Sold')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Write-Off Sold'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Auto-Negative')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Auto-Negative'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Inventory Adjustment')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Inventory Adjustment'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Work In Progress')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Work In Progress'
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'General')
BEGIN
	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'General'
END



END
BEGIN -- GROUP CATEGORY MAPPING
	;WITH CTE(strAccountGroup, strAccountCategory)AS
	(	SELECT 'Cash Accounts', 'Cash Account' UNION
		SELECT 'Payables','AP Account'UNION
		SELECT 'Receivables','AR Account' UNION
		SELECT 'Undeposited Funds','Undeposited Funds'
	)
	UPDATE A 
	SET A.intAccountCategoryId = C.intAccountCategoryId
	FROM tblGLAccountGroup A
	JOIN CTE B ON A.strAccountGroup = B.strAccountGroup
	JOIN tblGLAccountCategory C ON C.strAccountCategory = B.strAccountCategory

	UPDATE tblGLAccountCategory SET ysnRestricted = 1
		WHERE strAccountCategory IN('Cash Account','AP Account','AR Account','Undeposited Funds')

	UPDATE tblGLAccountCategory SET ysnRestricted = 0 WHERE ysnRestricted IS NULL
END

EXEC dbo.[uspGLConvertAccountGroupToCategory]

