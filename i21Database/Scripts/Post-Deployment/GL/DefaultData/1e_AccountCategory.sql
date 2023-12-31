﻿GO
	PRINT 'Start generating default account categories'
GO
	
SET  IDENTITY_INSERT tblGLAccountCategory ON
	MERGE 
	INTO	dbo.tblGLAccountCategory
	WITH	(HOLDLOCK) 
	AS		CategoryTable
	USING	(
			SELECT id = 1,name = 'AP Account'UNION ALL 
			SELECT id = 2,name = 'AR Account'UNION ALL 
			--SELECT id = 3,name = 'Begin Inventory'UNION ALL 
			--SELECT id = 4,name = 'Broker Expense'UNION ALL 
			SELECT id = 5,name = 'Cash Account'UNION ALL 
			--SELECT id = 6,name = 'Cash Over/Short'UNION ALL 
			--SELECT id = 7,name = 'Contract Equity'UNION ALL 
			--SELECT id = 8,name = 'Contract Purchase Gain/Loss'UNION ALL 
			--SELECT id = 9,name = 'Contract Sales Gain/Loss'UNION ALL 
			SELECT id = 10,name = 'Cost of Goods'UNION ALL 
			--SELECT id = 11,name = 'Credit Card Fee'UNION ALL 
			--SELECT id = 12,name = 'Currency Equity'UNION ALL 
			--SELECT id = 13,name = 'Currency Purchase Gain/Loss'UNION ALL 
			--SELECT id = 14,name = 'Currency Sales Gain/Loss'UNION ALL 
			--SELECT id = 15,name = 'Deposit Account'UNION ALL 
			SELECT id = 16,name = 'Discount Receivable'UNION ALL 
			SELECT id = 17,name = 'DP Income'UNION ALL 
			SELECT id = 18,name = 'DP Liability'UNION ALL 
			--SELECT id = 19,name = 'End Inventory'UNION ALL 
			--SELECT id = 20,name = 'Fee Expense'UNION ALL 
			--SELECT id = 21,name = 'Fee Income'UNION ALL 
			--SELECT id = 22,name = 'Freight AP Account'UNION ALL 
			--SELECT id = 23,name = 'Freight Expenses'UNION ALL 
			--SELECT id = 24,name = 'Freight Income'UNION ALL 
			--SELECT id = 25,name = 'Interest Expense'UNION ALL 
			SELECT id = 26,name = 'Interest Income'UNION ALL 
			SELECT id = 27,name = 'Inventory' UNION ALL 
			--SELECT id = 28,name = 'Options Expense'UNION ALL 
			--SELECT id = 29,name = 'Options Income'UNION ALL 
			--SELECT id = 30,name = 'Purchase Account'UNION ALL 
			SELECT id = 31,name = 'Purchase Adv Account'UNION ALL 
			SELECT id = 32,name = 'Rail Freight'UNION ALL 
			SELECT id = 33,name = 'Sales Account'UNION ALL 
			SELECT id = 34,name = 'Sales Adv Account'UNION ALL 
			SELECT id = 35,name = 'Sales Discount'UNION ALL 
			SELECT id = 36,name = 'Service Charges'UNION ALL 
			--SELECT id = 37,name = 'Storage Expense'UNION ALL 
			--SELECT id = 38,name = 'Storage Income'UNION ALL 
			--SELECT id = 39,name = 'Storage Receivable'UNION ALL 
			--SELECT id = 40,name = 'Variance Account'UNION ALL 
			SELECT id = 41,name = 'Write Off'UNION ALL 
			--SELECT id = 42,name = 'Write-Off Sold'UNION ALL 
			--SELECT id = 43,name = 'Revalue Sold'UNION ALL 
			SELECT id = 44,name = 'Auto-Variance'UNION ALL 
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
			SELECT id = 56,name = 'Other Charge Income' UNION ALL 
			SELECT id = 57,name = 'Maintenance Sales' UNION ALL
			SELECT id = 58,name = 'Deferred Revenue' UNION ALL
			--SELECT id = 59,name = 'Deferred Payable'UNION ALL
			SELECT id = 60,name = 'Unrealized Gain or Loss Accounts Receivable' UNION ALL --GL-3286
			SELECT id = 61,name = 'Unrealized Gain or Loss Accounts Payable' UNION ALL --GL-3286
			SELECT id = 62,name = 'Unrealized Gain or Loss Cash Management' UNION ALL --GL-3286
			SELECT id = 63,name = 'Unrealized Gain or Loss Inventory' UNION ALL --GL-3286
			SELECT id = 64,name = 'Unrealized Gain or Loss Contract Purchase' UNION ALL --GL-3286
			SELECT id = 65,name = 'Unrealized Gain or Loss Contract Sales'  UNION ALL --GL-3286
			SELECT id = 66,name = 'Unrealized Gain or Loss Offset AR' UNION ALL --GL-3286
			SELECT id = 67,name = 'Unrealized Gain or Loss Offset AP' UNION ALL --GL-3286
			SELECT id = 68,name = 'Unrealized Gain or Loss Offset CM' UNION ALL --GL-3286
			SELECT id = 69,name = 'Unrealized Gain or Loss Offset Inventory' UNION ALL --GL-3286
			SELECT id = 70,name = 'Unrealized Gain or Loss Offset Contract Purchase' UNION ALL --GL-3286
			SELECT id = 71,name = 'Unrealized Gain or Loss Offset Contract Sales' UNION ALL--GL-3286
			SELECT id = 72,name = 'Realized Gain or Loss Payables' UNION ALL--GL-3286
			SELECT id = 73,name = 'Realized Gain or Loss Receivables' --GL-3286

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

	-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Storage Expense')
	-- BEGIN
	-- 	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	-- 	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Storage Expense'
	-- END
	
	-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Revalue Sold')
	-- BEGIN
	-- 	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	-- 	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Revalue Sold'
	-- END
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

	-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory =  'Write-Off Sold')
	-- BEGIN
	-- 	INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
	-- 	SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Write-Off Sold'
	-- END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Auto-Variance')
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Auto-Variance'
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

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG Left JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = 'Maintenance Sales')
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = 'Maintenance Sales'
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
	

