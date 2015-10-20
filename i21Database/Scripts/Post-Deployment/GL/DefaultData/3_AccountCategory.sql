﻿GO
	PRINT 'Start generating default account categories'
GO

BEGIN TRY --ACCOUNT CATEGORY DEFAULTS
	BEGIN TRANSACTION
	DECLARE @tblSegment TABLE(intAccountSegmentId INT, strAccountCategory VARCHAR(100))
	DECLARE @tblCategoryGroup TABLE(intAccountCategoryGroupId INT, strAccountCategory VARCHAR(100))
	DECLARE @tblCTCostType TABLE(intCostTypeId INT, strAccountCategory VARCHAR(100))
	DECLARE @tblAccountGroup TABLE(intAccountGroupId INT, strAccountCategory VARCHAR(100))
	DECLARE @tblCOATemplateDetail TABLE (intAccontTemplateDetailId INT, strAccountCategory VARCHAR(100))
	DECLARE @tblICCategory TABLE (intCategoryAccountId INT, strAccountCategory VARCHAR(100))
	DECLARE @tblICItemAccount TABLE (intItemAccountId INT, strAccountCategory VARCHAR(100))
	INSERT INTO @tblSegment(intAccountSegmentId,strAccountCategory)SELECT B.intAccountSegmentId, strAccountCategory FROM tblGLAccountCategory A, tblGLAccountSegment B
	WHERE A.intAccountCategoryId = B.intAccountCategoryId
	INSERT INTO @tblCategoryGroup(intAccountCategoryGroupId,strAccountCategory)SELECT B.intAccountCategoryGroupId, strAccountCategory FROM tblGLAccountCategory A, tblGLAccountCategoryGroup B
	WHERE A.intAccountCategoryId = B.intAccountCategoryId
	INSERT INTO @tblCTCostType(intCostTypeId,strAccountCategory)SELECT B.intCostTypeId, strAccountCategory FROM tblGLAccountCategory A, tblCTCostType B
	WHERE A.intAccountCategoryId = B.intAccountCategoryId
	INSERT INTO @tblAccountGroup(intAccountGroupId,strAccountCategory)SELECT B.intAccountGroupId, strAccountCategory FROM tblGLAccountCategory A, tblGLAccountGroup B
	WHERE A.intAccountCategoryId = B.intAccountCategoryId
	INSERT INTO @tblCOATemplateDetail(intAccontTemplateDetailId,strAccountCategory)SELECT B.intAccountTemplateDetailId, strAccountCategory FROM tblGLAccountCategory A, tblGLCOATemplateDetail B
	WHERE A.intAccountCategoryId = B.intAccountCategoryId
	INSERT INTO @tblICCategory(intCategoryAccountId,strAccountCategory)SELECT B.intCategoryAccountId, strAccountCategory FROM tblGLAccountCategory A, tblICCategoryAccount B
	WHERE A.intAccountCategoryId = B.intAccountCategoryId
	INSERT INTO @tblICItemAccount(intItemAccountId,strAccountCategory)SELECT B.intItemAccountId, strAccountCategory FROM tblGLAccountCategory A, tblICItemAccount B
	WHERE A.intAccountCategoryId = B.intAccountCategoryId

	SET  IDENTITY_INSERT tblGLAccountCategory ON
	MERGE 
	INTO	dbo.tblGLAccountCategory
	WITH	(HOLDLOCK) 
	AS		CategoryTable
	USING	(
			SELECT id = 1,name = 'AP Account'UNION ALL 
			SELECT id = 2,name = 'AR Account'UNION ALL 
			SELECT id = 3,name = 'Begin Inventory'UNION ALL 
			SELECT id = 4,name = 'Broker Expense'UNION ALL 
			SELECT id = 5,name = 'Cash Account'UNION ALL 
			SELECT id = 6,name = 'Cash Over/Short'UNION ALL 
			SELECT id = 7,name = 'Contract Equity'UNION ALL 
			SELECT id = 8,name = 'Contract Purchase Gain/Loss'UNION ALL 
			SELECT id = 9,name = 'Contract Sales Gain/Loss'UNION ALL 
			SELECT id = 10,name = 'Cost of Goods'UNION ALL 
			SELECT id = 11,name = 'Credit Card Fee'UNION ALL 
			SELECT id = 12,name = 'Currency Equity'UNION ALL 
			SELECT id = 13,name = 'Currency Purchase Gain/Loss'UNION ALL 
			SELECT id = 14,name = 'Currency Sales Gain/Loss'UNION ALL 
			SELECT id = 15,name = 'Deposit Account'UNION ALL 
			SELECT id = 16,name = 'Discount Receivable'UNION ALL 
			SELECT id = 17,name = 'DP Income'UNION ALL 
			SELECT id = 18,name = 'DP Liability'UNION ALL 
			SELECT id = 19,name = 'End Inventory'UNION ALL 
			SELECT id = 20,name = 'Fee Expense'UNION ALL 
			SELECT id = 21,name = 'Fee Income'UNION ALL 
			SELECT id = 22,name = 'Freight AP Account'UNION ALL 
			SELECT id = 23,name = 'Freight Expenses'UNION ALL 
			SELECT id = 24,name = 'Freight Income'UNION ALL 
			SELECT id = 25,name = 'Interest Expense'UNION ALL 
			SELECT id = 26,name = 'Interest Income'UNION ALL 
			SELECT id = 27,name = 'Inventory' UNION ALL 
			SELECT id = 28,name ='Options Expense'UNION ALL 
			SELECT id = 29,name = 'Options Income'UNION ALL 
			SELECT id = 30,name = 'Purchase Account'UNION ALL 
			SELECT id = 31,name = 'Purchase Adv Account'UNION ALL 
			SELECT id = 32,name = 'Rail Freight'UNION ALL 
			SELECT id = 33,name = 'Sales Account'UNION ALL 
			SELECT id = 34,name = 'Sales Adv Account'UNION ALL 
			SELECT id = 35,name = 'Sales Discount'UNION ALL 
			SELECT id = 36,name = 'Service Charges'UNION ALL 
			SELECT id = 37,name = 'Storage Expense'UNION ALL 
			SELECT id = 38,name = 'Storage Income'UNION ALL 
			SELECT id = 39,name = 'Storage Receivable'UNION ALL 
			SELECT id = 40,name = 'Variance Account'UNION ALL 
			SELECT id = 41,name = 'Write Off'UNION ALL 
			SELECT id = 42,name = 'Write-Off Sold'UNION ALL 
			SELECT id = 43,name = 'Revalue Sold'UNION ALL 
			SELECT id = 44,name = 'Auto-Negative'UNION ALL 
			SELECT id = 45,name = 'AP Clearing'UNION ALL 
			SELECT id = 46,name = 'Inventory In-Transit'UNION ALL 
			SELECT id = 47,name = 'General'UNION ALL 
			SELECT id = 48,name = 'Sales Tax Account'UNION ALL 
			SELECT id = 49,name = 'Purchase Tax Account'UNION ALL 
			SELECT id = 50,name = 'Undeposited Funds'UNION ALL 
			SELECT id = 51,name = 'Inventory Adjustment'UNION ALL 
			SELECT id = 52,name = 'Work In Progress'UNION ALL 
			SELECT id = 53,name = 'Vendor Prepayments'UNION ALL 
			SELECT id = 54,name = 'Customer Prepayments'UNION ALL 
			SELECT id = 55,name = 'Other Charge Expense'UNION ALL 
			SELECT id = 56,name = 'Other Charge Income'
	) AS CategoryHardCodedValues
		ON  CategoryTable.intAccountCategoryId = CategoryHardCodedValues.id

	-- When id is matched, make sure the name and form are up-to-date.
	WHEN MATCHED THEN 
		UPDATE 
		SET 	CategoryTable.strAccountCategory = CategoryHardCodedValues.name
	-- When id is missing, then do an insert. 
	WHEN NOT MATCHED THEN
		INSERT (
			intAccountCategoryId
			,strAccountCategory
			,intConcurrencyId
		)
		VALUES (
			CategoryHardCodedValues.id
			,CategoryHardCodedValues.name
			,1
		);
	SET  IDENTITY_INSERT tblGLAccountCategory OFF

	--UPDATE RELATED TABLES
	UPDATE A SET intAccountCategoryId=C.intAccountCategoryId
	FROM tblGLAccountSegment A 
	JOIN @tblSegment t ON  A.intAccountSegmentId = t.intAccountSegmentId 
	JOIN tblGLAccountCategory C ON C.strAccountCategory COLLATE Latin1_General_CI_AS = t.strAccountCategory COLLATE Latin1_General_CI_AS

	UPDATE A SET intAccountCategoryId=C.intAccountCategoryId
	FROM tblGLAccountCategoryGroup A 
	JOIN @tblCategoryGroup t ON  A.intAccountCategoryGroupId = t.intAccountCategoryGroupId 
	JOIN tblGLAccountCategory C ON C.strAccountCategory COLLATE Latin1_General_CI_AS = t.strAccountCategory COLLATE Latin1_General_CI_AS

	UPDATE A SET intAccountCategoryId=C.intAccountCategoryId
	FROM tblGLAccountGroup A 
	JOIN @tblAccountGroup t ON  A.intAccountGroupId = t.intAccountGroupId 
	JOIN tblGLAccountCategory C ON C.strAccountCategory COLLATE Latin1_General_CI_AS = t.strAccountCategory COLLATE Latin1_General_CI_AS
	
	UPDATE A SET intAccountCategoryId=C.intAccountCategoryId
	FROM tblGLCOATemplateDetail A 
	JOIN @tblCOATemplateDetail t ON  A.intAccountTemplateDetailId = t.intAccontTemplateDetailId
	JOIN tblGLAccountCategory C ON C.strAccountCategory COLLATE Latin1_General_CI_AS = t.strAccountCategory COLLATE Latin1_General_CI_AS

	UPDATE A SET intAccountCategoryId=C.intAccountCategoryId
	FROM tblCTCostType A 
	JOIN @tblCTCostType t ON  A.intCostTypeId = t.intCostTypeId 
	JOIN tblGLAccountCategory C ON C.strAccountCategory COLLATE Latin1_General_CI_AS = t.strAccountCategory COLLATE Latin1_General_CI_AS

	UPDATE A SET intAccountCategoryId=C.intAccountCategoryId
	FROM tblICCategoryAccount A 
	JOIN @tblICCategory t ON  A.intCategoryAccountId = t.intCategoryAccountId 
	JOIN tblGLAccountCategory C ON C.strAccountCategory COLLATE Latin1_General_CI_AS = t.strAccountCategory COLLATE Latin1_General_CI_AS

	UPDATE A SET intAccountCategoryId=C.intAccountCategoryId
	FROM tblICItemAccount A 
	JOIN @tblICItemAccount t ON  A.intItemAccountId = t.intItemAccountId 
	JOIN tblGLAccountCategory C ON C.strAccountCategory COLLATE Latin1_General_CI_AS = t.strAccountCategory COLLATE Latin1_General_CI_AS

	--REMOVE EXCESS
	DELETE FROM tblGLAccountCategory WHERE intAccountCategoryId > 56
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT 'Error in Generating Account Categories: ' +  CAST(@@ERROR AS VARCHAR(20))
	ROLLBACK TRANSACTION
END CATCH

GO

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
GO

BEGIN -- INVENTORY ACCOUNT CATEGORY GROUPING
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Cost of Goods')
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Cost of Goods'
	END
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Inventory')
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Inventory'
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

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Other Charge Expense')
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Other Charge Expense'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Other Charge Income')
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Other Charge Income'
	END
	
END
GO
	PRINT 'Finished generating default account categories'
GO
	PRINT 'Start updating account group category ids'
GO
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
GO
	PRINT 'Finished updating account group category ids'
GO
	PRINT 'Start converting account group to category'
GO
	EXEC dbo.[uspGLConvertAccountGroupToCategory]
GO
	PRINT 'Finished converting account group to category'
GO

