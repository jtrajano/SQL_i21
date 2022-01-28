GO
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
			SELECT id = 73,name = 'Realized Gain or Loss Receivables' UNION ALL --GL-3286
			SELECT id = 74,name = 'Unrealized Gain or Loss' UNION ALL --GL-3464
			SELECT id = 75,name = 'Unrealized Futures Gain or Loss' UNION ALL --GL-3464
			SELECT id = 76,name = 'Futures Trade Equity' UNION ALL --GL-3464
			SELECT id = 77,name = 'Futures Gain or Loss Realized' UNION ALL --GL-3464
			


			SELECT id = 100, name = 'Mark to Market P&L' UNION ALL
			SELECT id = 101, name = 'Mark to Market Offset' UNION ALL

			SELECT id = 120, name = 'Unrealized Gain on Basis' UNION ALL
			SELECT id = 121, name = 'Unrealized Gain on Futures' UNION ALL
			SELECT id = 122, name = 'Unrealized Gain on Cash' UNION ALL
			SELECT id = 123, name = 'Unrealized Gain on Ratio' UNION ALL
			SELECT id = 124, name = 'Unrealized Loss on Basis' UNION ALL
			SELECT id = 125, name = 'Unrealized Loss on Futures' UNION ALL
			SELECT id = 126, name = 'Unrealized Loss on Cash' UNION ALL
			SELECT id = 127, name = 'Unrealized Loss on Ratio' UNION ALL
			SELECT id = 128, name = 'Unrealized Gain on Basis (Inventory Offset)' UNION ALL
			SELECT id = 129, name = 'Unrealized Gain on Futures (Inventory Offset)' UNION ALL
			SELECT id = 130, name = 'Unrealized Gain on Cash (Inventory Offset)' UNION ALL
			SELECT id = 131, name = 'Unrealized Gain on Ratio (Inventory Offset)' UNION ALL
			SELECT id = 132, name = 'Unrealized Gain on Intransit (Inventory Offset)' UNION ALL
			SELECT id = 133, name = 'Unrealized Loss on Basis (Inventory Offset)' UNION ALL
			SELECT id = 134, name = 'Unrealized Loss on Futures (Inventory Offset)' UNION ALL
			SELECT id = 135, name = 'Unrealized Loss on Cash (Inventory Offset)' UNION ALL
			SELECT id = 136, name = 'Unrealized Loss on Ratio (Inventory Offset)' UNION ALL
			SELECT id = 137, name = 'Unrealized Loss on Intransit (Inventory Offset)' UNION ALL
			SELECT id = 138, name = 'Futures Gain or Loss Realized Offset' UNION ALL
			SELECT id = 139, name = 'Deferred Expense' UNION ALL 

			SELECT id = 140, name = 'Unrealized Gain on Inventory (Inventory Offset)' UNION ALL
			SELECT id = 141, name = 'Unrealized Loss on Inventory (Inventory Offset)' UNION ALL
			SELECT id = 142, name = 'Unrealized Gain on Purchasing (AP Clearing)' UNION ALL
			SELECT id = 143, name = 'Unrealized Loss on Purchasing (AP Clearing)' UNION ALL
			
			-- Fixed Asset Category
			SELECT id = 144, name = 'Fixed Assets' UNION ALL
			SELECT id = 145, name = 'Accumulated Depreciation' UNION ALL
			SELECT id = 146, name = 'Fixed Asset Gain or Loss' UNION ALL
			SELECT id = 147, name = 'Depreciation Expense' UNION ALL
			SELECT id = 148, name = 'Realized Gain or Loss Fixed Asset' UNION --GL-8416

			-- Bank Transfer Category
			SELECT id = 150, name = 'Forex AP/AR' UNION ALL --GL-8243
			SELECT id = 151, name = 'Forward Accrual Unrealized Gain or Loss' UNION ALL --GL-8410
			SELECT id = 152, name = 'Swap Accrual Unrealized Gain or Loss' UNION ALL --GL-8410
			SELECT id = 153, name = 'Forward Accrual Realized Gain or Loss' UNION ALL --GL-8410
			SELECT id = 154, name = 'Swap Accrual Realized Gain or Loss' UNION ALL --GL-8410
			SELECT id = 155, name = 'Bank Transfer In-Transit' UNION ALL --GL-8411 for intransit account 
			SELECT id = 156, name = 'Cash Management Realized Gain or Loss' UNION ALL --GL-8529 For bank transfer gain loss intransit / transfer only

			-- Fixed Asset Unrealized Gain or Loss
			SELECT id = 160, name = 'Unrealized Gain or Loss Fixed Asset' UNION ALL --GL-8450
			SELECT id = 161, name = 'Unrealized Gain or Loss Offset Fixed Asset' UNION ALL--GL-8450
			
			-- GL Revalue Accounts
			SELECT id = 162, name = 'General Ledger Unrealized Gain or Loss' UNION ALL--GL-8450
			SELECT id = 163, name = 'General Ledger Unrealized Gain or Loss Offset' --GL-8450

	) AS CategoryHardCodedValues
		ON  CategoryTable.intAccountCategoryId = CategoryHardCodedValues.id

	-- When id is matched, make sure the name and form are up-to-date.
	WHEN MATCHED THEN 
		UPDATE 
		SET 	CategoryTable.strAccountCategory = CategoryHardCodedValues.name
	-- When id is missing, then do an insert. 
	WHEN NOT MATCHED BY TARGET THEN
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
	--WHEN NOT MATCHED BY SOURCE THEN
	--DELETE;
	SET  IDENTITY_INSERT tblGLAccountCategory OFF
	
	GO
		PRINT 'Finished generating default account categories'
	GO
		PRINT 'Started removing unused account categories'
	IF EXISTS (SELECT TOP 1  1 FROM tblGLAccountCategory WHERE strAccountCategory IN ('DP Income', 'DP Liability', 'Rail Freight'))
	BEGIN --GL-4338
		UPDATE t  SET intAccountCategoryId = 47  -- Set to General Category
		FROM tblGLAccountSegment t JOIN tblGLAccountCategory g 
		ON g.intAccountCategoryId = t.intAccountCategoryId WHERE strAccountCategory IN ('DP Income', 'DP Liability', 'Rail Freight')
		DELETE FROM tblGLAccountCategory WHERE strAccountCategory IN ('DP Income', 'DP Liability', 'Rail Freight')

	END
	GO
		PRINT 'Finished removing unused account categories'
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

	DECLARE @strAccountCategory AS NVARCHAR(50)

	SET @strAccountCategory  = 'Unrealized Gain on Basis'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END		
	SET @strAccountCategory  = 'Unrealized Gain on Futures'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Gain on Cash'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Gain on Ratio'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Basis'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END
	SET @strAccountCategory  = 'Unrealized Loss on Futures'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Cash'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Ratio'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Gain on Basis (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Gain on Futures (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Gain on Cash (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Gain on Ratio (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Gain on Intransit (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Basis (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Futures (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Cash (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Ratio (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Intransit (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Futures Gain or Loss Realized'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Futures Gain or Loss Realized Offset'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Deferred Expense'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	

	SET @strAccountCategory  = 'Unrealized Gain on Inventory (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Inventory (Inventory Offset)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Gain on Purchasing (AP Clearing)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	
	SET @strAccountCategory  = 'Unrealized Loss on Purchasing (AP Clearing)'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountCategoryGroup ACG LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = ACG.intAccountCategoryId WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		INSERT INTO tblGLAccountCategoryGroup (intAccountCategoryId,strAccountCategoryGroupDesc,strAccountCategoryGroupCode)
		SELECT intAccountCategoryId ,'Inventories','INV' FROM tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
	END	

END
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

		UPDATE tblGLAccountCategory SET ysnRestricted = CASE 
			WHEN strAccountCategory IN('Cash Account','AP Account','AR Account','Undeposited Funds') THEN 1 ELSE 0 END
		
		--FOR GL ACCOUNT COMBO BOX FILTERING
		UPDATE tblGLAccountCategory SET ysnGLRestricted  = 
			case when strAccountCategory IN('Cash Account','AP Account','AR Account','Inventory') THEN 1 ELSE 0 END
		
		-- FOR AP ACCOUNT COMBO BOX FILTERING
		UPDATE tblGLAccountCategory SET ysnAPRestricted = CASE WHEN strAccountCategory IN('AP Account','AR Account', 'Cash Account', 'Inventory', 'AP Clearing', ' Inventory In-Transit', 'Inventory Adjustment', 'Vendor Prepayments')
		THEN 1 ELSE 0 END

		
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

-- This will limit on what account type can be set on an account category
BEGIN 
	SET  IDENTITY_INSERT tblGLAccountCategoryType ON
	MERGE 
	INTO	dbo.tblGLAccountCategoryType
	WITH	(HOLDLOCK) 
	AS		CategoryTypeTable
	USING	(
		SELECT id = 1, categoryId = 5, name = 'Asset' UNION ALL --Cash Account
		SELECT id = 2, categoryId = 5, name = 'Liability' UNION ALL --Cash Account
		SELECT id = 3, categoryId = 100, name = 'Expense' UNION ALL --Mark to Market
		SELECT id = 4, categoryId = 100, name = 'Revenue' UNION ALL --Mark to Market
		SELECT id = 5, categoryId = 101, name = 'Asset' UNION ALL --Mark to Market Offset
		SELECT id = 6, categoryId = 101, name = 'Liability' UNION ALL --Mark to Market Offset
		SELECT id = 7, categoryId = 144, name = 'Asset' UNION ALL --Fixed Assets 
		SELECT id = 8, categoryId = 144, name = 'Liability' UNION ALL --Fixed Assets 
		SELECT id = 9, categoryId = 145, name = 'Asset' UNION ALL --Accumulated depreciation
		SELECT id = 10, categoryId = 145, name = 'Liability' UNION ALL --Accumulated depreciation
		SELECT id = 11, categoryId = 146, name = 'Expense' UNION ALL--Fixed asset Gain or loss
		SELECT id = 12, categoryId = 146, name = 'Revenue' UNION ALL--Fixed asset Gain or loss
		SELECT id = 13, categoryId = 147, name = 'Revenue' UNION ALL --Depreciation Expense
		SELECT id = 14, categoryId = 147, name = 'Expense' --Depreciation Expense



		
	) AS CategoryTypeHardCodedValues
			ON  CategoryTypeTable.intAccountCategoryTypeId = CategoryTypeHardCodedValues.id

	-- When id is matched, make sure the name and form are up-to-date.
	WHEN MATCHED THEN 
		UPDATE 
		SET 	CategoryTypeTable.intAccountCategoryId = CategoryTypeHardCodedValues.categoryId,
		CategoryTypeTable.strAccountType = CategoryTypeHardCodedValues.name
	-- When id is missing, then do an insert. 
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intAccountCategoryTypeId
			,intAccountCategoryId
			,strAccountType
		)
		VALUES (
			CategoryTypeHardCodedValues.id,
			CategoryTypeHardCodedValues.categoryId,
			CategoryTypeHardCodedValues.name
		);
	--WHEN NOT MATCHED BY SOURCE THEN
	--DELETE;
	SET  IDENTITY_INSERT tblGLAccountCategoryType OFF
	
END
GO

