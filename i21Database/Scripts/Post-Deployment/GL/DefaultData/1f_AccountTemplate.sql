GO
	PRINT N'BEGIN INSERT ACCOUNT TEMPLATE: Accounts Payable'
GO
	DECLARE @intAccountTemplateId int
	DECLARE @tblTemp TABLE ( intId INT )
	INSERT INTO @tblTemp (intId ) SELECT intAccountTemplateId FROM  tblGLCOATemplate WHERE  strType = N'Primary'

	WHILE EXISTS ( SELECT 1 FROM @tblTemp )
	BEGIN
		SELECT TOP 1 @intAccountTemplateId = intId FROM @tblTemp
		IF @intAccountTemplateId IS NOT NULL
			IF NOT EXISTS(SELECT 1 FROM tblGLCOATemplateDetail WHERE @intAccountTemplateId = intAccountTemplateId)
				DELETE FROM tblGLCOATemplate WHERE intAccountTemplateId =@intAccountTemplateId

		DELETE FROM @tblTemp WHERE intId = @intAccountTemplateId
	END
GO

	DELETE FROM tblGLCOATemplateDetail where strDescription in ('Beginning Inventory', 'Ending Inventory')

	DECLARE @GL_intAccountStructureId_Primary AS INT
	SET @GL_intAccountStructureId_Primary = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Primary')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Accounts Payable' AND strType = N'Primary')
	BEGIN
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'Accounts Payable', N'Primary', 1)
		
		DECLARE @GL_intAccountTemplateId_AccountsPayable AS INT		
		SET @GL_intAccountTemplateId_AccountsPayable = (SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Accounts Payable' AND strType = N'Primary')			
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'10000', N'Check book in Bank', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cash Accounts' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'18000', N'Supplies', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'20000', N'Accounts Payable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'44000', N'Credit Card Fee', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'55000', N'Purchases Discounts', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Purchases Discounts' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'60000', N'Miscellaneous Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'61500', N'Fee Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'35000', N'Owner''s Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Owners Equities' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'39000', N'Retained Earnings', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Retained Earnings' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'72500', N'Tax Expense ', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AccountsPayable , N'99000', N'Wash Account', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
	END

GO	
	PRINT N'END INSERT ACCOUNT TEMPLATE: Accounts Payable'
	PRINT N'BEGIN INSERT ACCOUNT TEMPLATE: AG Accounting'
GO
	
	DECLARE @GL_intAccountStructureId_Primary AS INT
	SET @GL_intAccountStructureId_Primary = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Primary')
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'AG Accounting' AND strType = N'Primary')
	BEGIN
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'AG Accounting', N'Primary', 1)
		
		DECLARE @GL_intAccountTemplateId_AGAccounting AS INT		
		SET @GL_intAccountTemplateId_AGAccounting = (SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'AG Accounting' AND strType = N'Primary')			
		
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'11000', N'Cash Clearing', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Undeposited Funds' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'12000', N'Accounts Receivable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Receivables' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'13000', N'Prepaid Credits', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Prepaids' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'14000', N'Prepaid Inventory', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Prepaids' AND strAccountType = N'Asset'), @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'16000', N'Inventories', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'18000', N'Supplies', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'21000', N'Pending Accounts Payable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'22000', N'Inspection Fee', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'23000', N'Federal Excise Tax', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'24000', N'State Excise Tax', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'25000', N'State Sales Tax', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'26000', N'Prepaid Sales Tax', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'27000', N'Locale Tax', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'40000', N'Sales Default', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'45000', N'Discount Take', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Discounts' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'46000', N'Sales Ticket Variance', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'48000', N'Finance Charge', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'49000', N'Other Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'50000', N'Purchases Default', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Purchases' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'51000', N'Purchases Variance', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Purchases' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'55000', N'Purchases Discounts', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Purchases Discounts' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'61000', N'Write Off', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'63000', N'Cash Over/Short', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'64000', N'Freight Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'35000', N'Owner''s Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Owners Equities' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'39000', N'Retained Earnings', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Retained Earnings' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'72500', N'Tax Expense ', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_AGAccounting , N'99000', N'Wash Account', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
	END

GO	
	PRINT N'END INSERT ACCOUNT TEMPLATE: AG Accounting'
	PRINT N'BEGIN INSERT ACCOUNT TEMPLATE: C-Store'
GO
	
	DECLARE @GL_intAccountStructureId_Primary AS INT
	SET @GL_intAccountStructureId_Primary = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Primary')
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'C-Store' AND strType = N'Primary')
	BEGIN
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'C-Store', N'Primary', 1)
		
		DECLARE @GL_intAccountTemplateId_CStore AS INT		
		SET @GL_intAccountTemplateId_CStore = (SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'C-Store' AND strType = N'Primary')			
		
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'10000', N'Check book in Bank', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cash Accounts' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'11000', N'Cash Clearing', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Undeposited Funds' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'12000', N'Accounts Receivable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Receivables' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'12500', N'Credit Card Receivable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Receivables' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'16000', N'Inventories', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'40000', N'Sales Default', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'46000', N'Sales Ticket Variance', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'50000', N'Purchases Default', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Purchases' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'60000', N'Miscellaneous Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'61500', N'Fee Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'35000', N'Owner''s Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Owners Equities' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'39000', N'Retained Earnings', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Retained Earnings' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'72500', N'Tax Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_CStore , N'99000', N'Wash Account', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
	END

GO	
	PRINT N'END INSERT ACCOUNT TEMPLATE: C-Store'
	PRINT N'BEGIN INSERT ACCOUNT TEMPLATE: Fixed Asset'
GO
	
	DECLARE @GL_intAccountStructureId_Primary AS INT
	SET @GL_intAccountStructureId_Primary = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Primary')
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Fixed Asset' AND strType = N'Primary') 
	BEGIN
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'Fixed Asset', N'Primary', 1)
		
		DECLARE @GL_intAccountTemplateId_FixedAsset AS INT		
		SET @GL_intAccountTemplateId_FixedAsset = (SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Fixed Asset' AND strType = N'Primary')
				
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'19000', N'Land', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Fixed Assets' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'19300', N'Land Improvements', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Fixed Assets' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'19500', N'Buildings', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Fixed Assets' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'19700', N'Equipment', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Fixed Assets' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'19900', N'Accumulated Depreciation', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Fixed Assets' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'19950', N'Goodwill', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Assets' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'35000', N'Owner''s Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Owners Equities' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'39000', N'Retained Earnings', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Retained Earnings' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'62000', N'Depreciation Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'72500', N'Tax Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_FixedAsset , N'99000', N'Wash Account', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
	END

GO	
	PRINT N'END INSERT ACCOUNT TEMPLATE: Fixed Asset'
	PRINT N'BEGIN INSERT ACCOUNT TEMPLATE: Grain'
GO

	DECLARE @GL_intAccountStructureId_Primary AS INT
	SET @GL_intAccountStructureId_Primary = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Primary')
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Grain' AND strType = N'Primary') 
	BEGIN
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'Grain', N'Primary', 1)
		
		DECLARE @GL_intAccountTemplateId_Grain AS INT		
		SET @GL_intAccountTemplateId_Grain = (SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Grain' AND strType = N'Primary')
				
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'10000', N'Check book in Bank', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cash Accounts' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'11000', N'Cash Clearing', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Undeposited Funds' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'12000', N'Accounts Receivable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Receivables' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'12300', N'Discount Receivable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Receivables' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'12700', N'Storage Receivable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Receivables' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'16000', N'Inventories', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'20000', N'Accounts Payable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'23000', N'Federal Excise Tax ', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'24000', N'State Excise Tax', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'25000', N'State Sales Tax ', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'26000', N'Prepaid Sales Tax', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'27000', N'Locale Tax', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'29000', N'Freight Payable', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'29100', N'DP Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'35000', N'Owner''s Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Owners Equities' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'39000', N'Retained Earnings', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Retained Earnings' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)		
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'40000', N'Sales Default', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'40300', N'DP Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'40500', N'Storage Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'41000', N'Freight Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'41500', N'Fee Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'42000', N'Interest Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'43000', N'Options Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'47000', N'Sales Advance ', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'49000', N'Other Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1)		
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'50000', N'Purchases Default', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Purchases' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'57000', N'Purchase Advance', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Purchases' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'60000', N'Miscellaneous Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'61500', N'Fee Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'64000', N'Freight Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'70000', N'Storage Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'71000', N'Broker Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'71500', N'Rail Freight', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'72000', N'Interest Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'73000', N'Options Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'74000', N'Contract Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'75000', N'Contract Pur Gain/Loss', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'76000', N'Contract Sales Gain/Loss', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'77000', N'Currency Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'78000', N'Currency Pur Gain/Loss', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'79000', N'Currency Sales Gain/Loss', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'72500', N'Tax Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Grain , N'99000', N'Wash Account', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
	END	

GO	
	PRINT N'END INSERT ACCOUNT TEMPLATE: Grain'
	PRINT N'BEGIN INSERT ACCOUNT TEMPLATE: Payroll'
GO
	
	DECLARE @GL_intAccountStructureId_Primary AS INT
	SET @GL_intAccountStructureId_Primary = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Primary')
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Payroll' AND strType = N'Primary') 
	BEGIN
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'Payroll', N'Primary', 1)
		
		DECLARE @GL_intAccountTemplateId_Payroll AS INT		
		SET @GL_intAccountTemplateId_Payroll = (SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Payroll' AND strType = N'Primary')
				
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'10000', N'Check book in Bank', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cash Accounts' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'28000', N'Other Payroll Liability', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Liabilities' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'28100', N'Federal Withholding', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Liabilities' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'28200', N'State Withholding', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Liabilities' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'28300', N'Social Security ', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Liabilities' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'28400', N'Medicare', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Liabilities' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'35000', N'Owner''s Equity', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Owners Equities' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'39000', N'Retained Earnings', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Retained Earnings' AND strAccountType = N'Equity') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'52000', N'Wages Cogs', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Cogs' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'60100', N'Wages Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Earnings' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'60300', N'Payroll Taxes  Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Tax Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'60500', N'Payroll Other Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payroll Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'72500', N'Tax Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ( @GL_intAccountTemplateId_Payroll, N'99000', N'Wash Account', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1)
	END

GO	
	PRINT N'END INSERT ACCOUNT TEMPLATE: Payroll'
	PRINT N'BEGIN INSERT ACCOUNT TEMPLATE: Petro'
GO
		IF EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Petro' AND strType = N'Primary') 
			DELETE FROM tblGLCOATemplate WHERE strAccountTemplateName = 'Petro'
	
	
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'Petro', N'Primary', 1)

		DECLARE @intAccountTemplateId AS INT		
			SET @intAccountTemplateId = (SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Petro' AND strType = N'Primary')
	
		DECLARE @GL_intAccountStructureId_Primary AS INT
			SET @GL_intAccountStructureId_Primary = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Primary')

	
		;WITH RawData AS (
			SELECT '10100' strCode,'Cash On Hand' strDescription,'Cash Accounts' strAccountGroup,'Cash Account' strAccountCategory UNION
			SELECT '10110','Petty Cash','Cash Accounts','Cash Account' UNION
			SELECT '10599','Undeposited Funds','Undeposited Funds','Undeposited Funds' UNION
			SELECT '10910','Cash Receivable Charge Cards','Current Assets','Cash Account' UNION
			SELECT '11000','Accounts Receivable','Receivables','AR Account' UNION
			SELECT '11010','A/R Employees','Receivables','General' UNION
			SELECT '11100','Misc Accts Receivable','Receivables','General' UNION
			SELECT '11200','Advance To Dealers','Receivables','General' UNION
			SELECT '11300','Allw For Doubtful Accts Rec','Receivables','General' UNION
			SELECT '11500','Intercompany','Receivables','General' UNION
			SELECT '11600','Warranty Receivable','Receivables','General' UNION
			SELECT '11700','Credit Card Receivable','Receivables','General' UNION
			SELECT '11800','Fuel Taxes Receivable','Receivables','General' UNION
			SELECT '11900','Credit Card Account','Receivables','General' UNION
			SELECT '12000','Inventory Account','Inventories','Inventory' UNION
			SELECT '13000','Prepaid Expense','Prepaids','General' UNION
			SELECT '13100','Prepaid Insurance','Prepaids','General' UNION
			SELECT '13200','Prepaid State Taxes','Prepaids','General' UNION
			SELECT '13300','Prepaid Federal Taxes','Prepaids','General' UNION
			SELECT '13400','Prepaid Property Taxes','Prepaids','General' UNION
			SELECT '13500','Prepaid Lease','Prepaids','General' UNION
			SELECT '13600','Vendor Prepaid','Prepaids','Vendor Prepayments' UNION
			SELECT '13700','Customer Prepaid','Prepaids','Customer Prepayments' UNION
			SELECT '14200','Clearing Account','Other Assets','General' UNION
			SELECT '14400','Common Stock','Other Assets','General' UNION
			SELECT '14500','Treasury Stock','Other Assets','General' UNION
			SELECT '15100','Buildings','Fixed Assets','Fixed Assets' UNION
			SELECT '15200','Land','Fixed Assets','Fixed Assets' UNION
			SELECT '15300','Real Estate','Fixed Assets','Fixed Assets' UNION
			SELECT '15400','Furniture/Fixtures','Fixed Assets','Fixed Assets' UNION
			SELECT '15500','Improvements','Fixed Assets','Fixed Assets' UNION
			SELECT '15600','Equipment','Fixed Assets','Fixed Assets' UNION
			SELECT '15700','Vehicles','Fixed Assets','Fixed Assets' UNION
			SELECT '16000','Organizational Expense','Fixed Assets','Fixed Assets' UNION
			SELECT '16100','Goodwill','Fixed Assets','Fixed Assets' UNION
			SELECT '16200','Capitalized Lease','Fixed Assets','Fixed Assets' UNION
			SELECT '16300','Accumulated Depreciation','Fixed Assets','Accumulated Depreciation' UNION
			SELECT '16400','Accum Amort Goodwill','Fixed Assets','Fixed Assets' UNION
			SELECT '16500','Accum Amort Organ Exp','Fixed Assets','Fixed Assets' UNION
			SELECT '21000','Accounts Payable','Payables','AP Account' UNION
			SELECT '21010','Unbilled Liabilities','Liability','AP Clearing' UNION
			SELECT '21020','Miscellaneous Acct Pay','Payables','General' UNION
			SELECT '21030','Notes Payable','Current Liabilities','General' UNION
			SELECT '21050','Credit Cards Clearing','Current Liabilities','General' UNION
			SELECT '21200','Federal Income Tax Payable','Payroll Tax Liabilities','General' UNION
			SELECT '21300','State Income Tax Payable','Payroll Tax Liabilities','General' UNION
			SELECT '21600','Federal Income Tax Withheld','Payroll Tax Liabilities','General' UNION
			SELECT '21800','FICA Tax Withheld','Payroll Tax Liabilities','General' UNION
			SELECT '21810','FICA Deferred','Payroll Tax Liabilities','General' UNION
			SELECT '21910','Insurance Withheld','Other Payables','General' UNION
			SELECT '22210','Deferred Income Tax','Liability','General' UNION
			SELECT '22300','Deferred Payable','Liability','General' UNION
			SELECT '22310','Rent Payable','Other Payables','General' UNION
			SELECT '22410','Loan Payable','Current Liabilities','General' UNION
			SELECT '22510','Loan Payable (Interest)','Current Liabilities','General' UNION
			SELECT '23000','Sales Tax','Sales Tax Payables','Sales Tax Account' UNION
			SELECT '23100','Use Tax','Sales Tax Payables','General' UNION
			SELECT '27200','Gas Tax Payable','Sales Tax Payables','General' UNION
			SELECT '27210','Excise Tax Exempt','Sales Tax Payables','General' UNION
			SELECT '27300','Diesel Tax Payable','Sales Tax Payables','General' UNION
			SELECT '27400','Enviro Petroleum Fee','Sales Tax Payables','General' UNION
			SELECT '29200','Fed Excise-Gas Payable','Sales Tax Payables','General' UNION
			SELECT '29300','Fed Excise-DSL Payable','Sales Tax Payables','General' UNION
			SELECT '29400','Federal Lust','Sales Tax Payables','General' UNION
			SELECT '29500','Fed Environmental Fee Recovery','Sales Tax Payables','General' UNION
			SELECT '29600','National Oilheat Alliance','Sales Tax Payables','General' UNION
			SELECT '30000','Common Stock','Owners Equities','General' UNION
			SELECT '30100','Paid In Surplus','Owners Equities','General' UNION
			SELECT '30200','Retained Earnings','Retained Earnings','General' UNION
			SELECT '30300','Distrib To Shareholders','Owners Equities','General' UNION
			SELECT '40000','Supreme','Sales','General' UNION
			SELECT '40100','Plus','Sales','General' UNION
			SELECT '40200','Reg Unleaded','Sales','General' UNION
			SELECT '40300','Diesel Clear','Sales','General' UNION
			SELECT '40400','Propane','Sales','General' UNION
			SELECT '40500','Diesel Dyed','Sales','General' UNION
			SELECT '40600','Kerosene Clear','Sales','General' UNION
			SELECT '40800','Kerosene Dyed','Sales','General' UNION
			SELECT '42000','Supreme Non-Ethanol','Sales','General' UNION
			SELECT '42100','Plus Non-Ethanol','Sales','General' UNION
			SELECT '42200','Regular Non-Ethanol','Sales','General' UNION
			SELECT '42300','Recreational Non-Ethanol','Sales','General' UNION
			SELECT '44000','Automotive','Sales','General' UNION
			SELECT '44100','Diesel Exhaust Fluid','Sales','General' UNION
			SELECT '44200','Antifreeze','Sales','General' UNION
			SELECT '44700','General Merchandise','Sales','General' UNION
			SELECT '45000','Oil','Sales','General' UNION
			SELECT '45100','Grease','Sales','General' UNION
			SELECT '46000','Home Propane Appliances','Sales','General' UNION
			SELECT '46100','Propane Tank Rental','Sales','General' UNION
			SELECT '46200','Hvac Sales - Appliances','Sales','Sales Account' UNION
			SELECT '46300','Hvac Service - Appliances','Sales','General' UNION
			SELECT '46400','Deferred Revenue','Sales','General' UNION
			SELECT '46500','Repair Parts','Sales','General' UNION
			SELECT '46700','Labor Income','Sales','General' UNION
			SELECT '47000','Special Purchases','Sales','General' UNION
			SELECT '47600','Prompt Pay Discounts','Sales Discounts','General' UNION
			SELECT '47700','ROE','Other Income','General' UNION
			SELECT '48100','Rental Income','Sales','General' UNION
			SELECT '48200','Interest Income','Other Income','General' UNION
			SELECT '48210','Dividend Income','Other Income','General' UNION
			SELECT '48300','Miscellaneous Income','Other Income','General' UNION
			SELECT '48400','Gain-Sale Of Asset','Other Income','General' UNION
			SELECT '48500','Bad Debt Recovery','Other Income','General' UNION
			SELECT '48700','FICA Credit','Other Income','General' UNION
			SELECT '48900','Other Income','Other Income','General' UNION
			SELECT '49000','Sales Discounts','Sales Discounts','General' UNION
			SELECT '49700','Freight Income','Sales','General' UNION
			SELECT '49800','Core Charges','Sales','General' UNION
			SELECT '49850','Tote Charges','Sales','General' UNION
			SELECT '49900','Invoice Errors','Other Income','General' UNION
			SELECT '50000','Supreme','Cost of Goods Sold','General' UNION
			SELECT '50100','Plus','Cost of Goods Sold','General' UNION
			SELECT '50200','Reg Unleaded','Cost of Goods Sold','General' UNION
			SELECT '50300','Diesel Clear','Cost of Goods Sold','General' UNION
			SELECT '50400','Propane','Cost of Goods Sold','General' UNION
			SELECT '50500','Diesel Dyed','Cost of Goods Sold','General' UNION
			SELECT '50600','Kerosene Clear','Cost of Goods Sold','General' UNION
			SELECT '50800','Kerosene Dyed','Cost of Goods Sold','General' UNION
			SELECT '51200','Federal Environmental Fee','Cost of Goods Sold','General' UNION
			SELECT '52000','Supreme Non-Ethanol','Cost of Goods Sold','General' UNION
			SELECT '52100','Plus Non-Ethanol','Cost of Goods Sold','General' UNION
			SELECT '52200','Regular Non-Ethanol','Cost of Goods Sold','General' UNION
			SELECT '52300','Recreational Non-Ethanol','Cost of Goods Sold','General' UNION
			SELECT '54000','Automotive','Cost of Goods Sold','General' UNION
			SELECT '54100','Diesel Exhaust Fluid','Cost of Goods Sold','General' UNION
			SELECT '54200','Antifreeze','Cost of Goods Sold','General' UNION
			SELECT '54700','General Merchandise','Cost of Goods Sold','General' UNION
			SELECT '55000','Oil','Cost of Goods Sold','General' UNION
			SELECT '55100','Grease','Cost of Goods Sold','General' UNION
			SELECT '55200','Fuel','Cost of Goods Sold','General' UNION
			SELECT '56000','Home Propane Equip','Cost of Goods Sold','General' UNION
			SELECT '56100','Propane Tank Rental','Cost of Goods Sold','General' UNION
			SELECT '56200','HVAC Sales','Cost of Goods Sold','General' UNION
			SELECT '56300','HVAC Service','Cost of Goods Sold','General' UNION
			SELECT '56500','Repair Parts','Cost of Goods Sold','General' UNION
			SELECT '56700','Labor','Cost of Goods Sold','General' UNION
			SELECT '57000','Special Purchases','Cost of Goods Sold','General' UNION
			SELECT '57600','Prompt Pay Discount','Expense','General' UNION
			SELECT '57700','ROI','Expense','General' UNION
			SELECT '58300','Miscellaneous Expense','Expense','General' UNION
			SELECT '59000','Purchase Discount','Expense','General' UNION
			SELECT '59700','Freight Cost','Expense','General' UNION
			SELECT '59800','Core Charges','Cost of Goods Sold','General' UNION
			SELECT '59850','Tote Charges','Cost of Goods Sold','General' UNION
			SELECT '59900','Invoice Errors','Expense','General' UNION
			SELECT '50010','Officers Salary Expense','Payroll Earnings','General' UNION
			SELECT '50110','Other Salary Expense','Payroll Earnings','General' UNION
			SELECT '50210','Professional Services','Expense','General' UNION
			SELECT '50310','Auto & Truck','Expense','General' UNION
			SELECT '50410','Advertising','Expense','General' UNION
			SELECT '50510','Donations','Expense','General' UNION
			SELECT '50610','Dues & Subscriptions','Expense','General' UNION
			SELECT '50700','Dues & Subscriptions','Expense','General' UNION
			SELECT '50710','Write Off','Expense','Write Off' UNION
			SELECT '50810','Bank Charges','Expense','General' UNION
			SELECT '50900','Depreciation','Expense','Depreciation Expense' UNION
			SELECT '51000','Insurance','Expense','General' UNION
			SELECT '51100','Contract Labor','Expense','General' UNION
			SELECT '51210','License & Taxes','Expense','General' UNION
			SELECT '51300','Road Fuel Tax Expense','Expense','General' UNION
			SELECT '51400','Business Franchise Tax','Expense','General' UNION
			SELECT '51500','Meetings & Conventions','Expense','General' UNION
			SELECT '51600','Travel','Expense','General' UNION
			SELECT '51800','Office Expenses','Expense','General' UNION
			SELECT '51900','Payroll Tax Expense','Expense','General' UNION
			SELECT '52010','Property Rent','Expense','General' UNION
			SELECT '52110','Repairs & Maintenance','Expense','General' UNION
			SELECT '52150','Tank Repairs & Maintenance','Expense','General' UNION
			SELECT '52210','Uniforms','Expense','General' UNION
			SELECT '52310','Telephone','Expense','General' UNION
			SELECT '52400','Utilities','Expense','General' UNION
			SELECT '52500','Interest Expense','Expense','General' UNION
			SELECT '52510','Deferred Payable Interest','Expense','General' UNION
			SELECT '52600','Environmental Clean Up','Expense','General' UNION
			SELECT '52700','Fuel Environment &Compliance Fee','Expense','General' UNION
			SELECT '52800','Penalties & Fines','Expense','General' UNION
			SELECT '52900','Over & Short Expense','Expense','General' UNION
			SELECT '53000','Pension Plan Expense','Expense','General' UNION
			SELECT '53100','Employee Benefits','Expense','General' UNION
			SELECT '53200','Federal Income Tax','Expense','General' UNION
			SELECT '53300','State Income Tax','Expense','General' UNION
			SELECT '53400','B & O Tax','Expense','General' UNION
			SELECT '53500','Workers'' Comp','Expense','General' UNION
			SELECT '53600','Federal Unempl. Tax','Payroll Expenses','General' UNION
			SELECT '53700','State Unempl. Tax','Payroll Expenses','General' UNION
			SELECT '53800','Property Taxes','Expense','General' UNION
			SELECT '53900','Rent - Equipment','Expense','General' UNION
			SELECT '53910','Rent - Building','Expense','General' UNION
			SELECT '54010','Services Reimbursement','Expense','General' UNION
			SELECT '54110','Service Charges','Expense','Service Charges' UNION
			SELECT '54210','Home Propane Expenses','Expense','General' UNION
			SELECT '54400','Home Heat Parts & Service','Expense','General' UNION
			SELECT '54500','Meals & Entertainment','Expense','General' UNION
			SELECT '54800','Postage','Expense','General' UNION
			SELECT '54900','Equipment Rental','Expense','General' UNION
			SELECT '55010','Credit Card Fees','Expense','General' UNION
			SELECT '55110','Commissions','Expense','General' UNION
			SELECT '55210','Accident Expense','Expense','General' UNION
			SELECT '55500','Regulation Expense','Expense','General' UNION
			SELECT '55700','Inventory Variance','Expense','General' UNION
			SELECT '56110','Amortization Exp Organization','Expense','General' UNION
			SELECT '56510','Public & Comm Relations','Expense','General' UNION
			SELECT '58400','Loss On Disposal Of Assets','Expense','General' UNION
			SELECT '59710','Use Tax Expense','Expense','General' UNION
			SELECT '59810','Loss On Abandonment','Expense','General' UNION
			SELECT '59910','Overhead Distribution','Expense','General' UNION
			SELECT '21100','Due From Account','Current Liabilities','General' UNION
			SELECT '10920','Due to Account','Current Assets','General')	
				
			INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId],[intAccountCategoryId], [intAccountStructureId], [intConcurrencyId])
			SELECT @intAccountTemplateId, strCode, strDescription, G.intAccountGroupId, C.intAccountCategoryId, @GL_intAccountStructureId_Primary, 1  FROM RawData A 
			OUTER APPLY (SELECT TOP 1 intAccountCategoryId from tblGLAccountCategory where strAccountCategory = A.strAccountCategory)C
			OUTER APPLY (SELECT TOP 1 intAccountGroupId from tblGLAccountGroup where strAccountGroup = A.strAccountGroup)G
					
GO

	PRINT N'END INSERT ACCOUNT TEMPLATE: Petro'
	PRINT N'BEGIN INSERT ACCOUNT TEMPLATE: Inventory'
GO

DECLARE @GL_intAccountStructureId_Primary AS INT
	SET @GL_intAccountStructureId_Primary = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Primary')
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Inventory' AND strType = N'Primary') 
	BEGIN
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'Inventory', N'Primary', 1)
		
		DECLARE @GL_intAccountTemplateId_Petrolac AS INT		
		SET @GL_intAccountTemplateId_Petrolac = (SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Inventory' AND strType = N'Primary')
										
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'18000', N'Inventory Adjustment', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Inventory Adjustment'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'18100', N'Inventory', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Inventory'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'18200', N'Inventory In-Transit', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Inventory In-Transit'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'18300', N'Work in Progress', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Inventories' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Work in Progress'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'21000', N'AP Clearing', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'AP Clearing'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'40000', N'Sales', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Sales Account'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'40100', N'Other Charge Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Income' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Other Charge Income'))		
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'50100', N'Cost of Goods', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Cost of Goods'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'50200', N'Auto Variance', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Auto-Variance'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'50300', N'Write-off Sold ', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Write-off Sold'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'50400', N'Revalue Sold', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Cost of Goods Sold' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Revalue Sold'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'50500', N'Other Charge Expense', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Other Charge Expense'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'50600', N'Service', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'General'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'50700', N'Non Inventory', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'General'))		
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'50800', N'Software', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Other Expenses' AND strAccountType = N'Expense') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'General'))
	
	END

GO

	PRINT N'END INSERT ACCOUNT TEMPLATE: Inventory'
	PRINT N'BEGIN INSERT ACCOUNT TEMPLATE: Sales'
GO

DECLARE @GL_intAccountStructureId_Primary AS INT
	SET @GL_intAccountStructureId_Primary = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Primary')
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Sales' AND strType = N'Primary') 
	BEGIN
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'Sales', N'Primary', 1)
		
		DECLARE @GL_intAccountTemplateId_Petrolac AS INT		
		SET @GL_intAccountTemplateId_Petrolac = (SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Sales' AND strType = N'Primary')
										
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'12100', N'AR Account', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Receivables' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'AR Account'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'41100', N'Sales Discount', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Sales Discount'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'41200', N'Write-Off Sold', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Write-Off Sold'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'41300', N'Interest Income', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Interest Income'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'41400', N'Service Charges', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Service Charges'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'41700', N'Sales Account', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1,(SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Sales Account'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'21100', N'Sales Tax Account', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales Tax Payables' AND strAccountType = N'Liability') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Sales Tax Account'))		
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'15100', N'Undeposited Funds', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Undeposited Funds' AND strAccountType = N'Asset') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Undeposited Funds'))
		INSERT [dbo].[tblGLCOATemplateDetail] ( [intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId], [intAccountCategoryId]) VALUES ( @GL_intAccountTemplateId_Petrolac , N'41600', N'Maintenance Sales', (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = N'Sales' AND strAccountType = N'Revenue') , @GL_intAccountStructureId_Primary, 1, (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = N'Maintenance Sales'))
		
	
	END

GO

	PRINT N'END INSERT ACCOUNT TEMPLATE: Sales'




EXEC dbo.uspGLConvertAccountTemplateGroupToCategory
GO