GO
	PRINT N'Fixing Categories for Inventory Module'
GO
	--GL-2016
	DELETE FROM tblGLAccountCategoryGroup
	WHERE intAccountCategoryId IN(SELECT intAccountCategoryId
							  FROM tblGLAccountCategory
							  WHERE strAccountCategory IN('Broker Expense', 'Contract Equity', 'Contract Purchase Gain/Loss', 'Contract Sales Gain/Loss', 'Currency Equity', 'Currency Purchase Gain/Loss', 'Currency Sales Gain/Loss', 'DP Liability','DP Income', 'DP Income', 'Fee Expense', 'Fee Income', 'Freight Expenses', 'Interest Expense', 'Interest Income', 'Options Expense', 'Options Income', 'Purchase Account', 'Rail Freight', 'Storage Expense', 'Storage Income', 'Storage Receivable','Other Charge (Asset)')) AND 
	  strAccountCategoryGroupCode = 'INV'

	--GL-2076
	DECLARE @GeneralCatId INT
	DECLARE @OtherChargeAssetCatId INT

	SELECT TOP 1 @GeneralCatId = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'General'
	SELECT TOP 1 @OtherChargeAssetCatId = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Other Charge (Asset)'

	UPDATE	dbo.tblGLAccount
	SET		intAccountCategoryId = @GeneralCatId
	WHERE	intAccountCategoryId = @OtherChargeAssetCatId

	UPDATE tblGLAccountSegment
	SET intAccountCategoryId  = @GeneralCatId
	WHERE  intAccountCategoryId = @OtherChargeAssetCatId 


	-- Remove the Other charge (asset) from the category group
	DELETE	
	FROM	dbo.tblGLAccountCategoryGroup
	WHERE intAccountCategoryId = @OtherChargeAssetCatId

	-- Remove the Other charge (asset) from the category table. 
	DELETE	
	FROM	dbo.tblGLAccountCategory 
	WHERE	intAccountCategoryId = @OtherChargeAssetCatId
GO
	PRINT N'Fixing Categories for Inventory Module'
GO
