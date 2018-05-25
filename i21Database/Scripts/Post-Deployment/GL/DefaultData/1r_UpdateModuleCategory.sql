/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

PRINT ('Begin updating module in tblGLAccountCategory table');
GO
UPDATE dbo.tblGLAccountCategory
SET intModuleId =
    (
        SELECT TOP 1 intModuleId FROM dbo.tblSMModule WHERE strModule = 'Purchasing'
    )
WHERE strAccountCategory IN ( 'AP Account', 'Unrealized Gain or Loss Accounts Payable', 'AP Clearing',
                              'Purchase Tax Account', 'Vendor Prepayments','Other Charge Expense', 
							  'Other Charge Income', 'Unrealized Gain or Loss Offset AP',
                              'Realized Gain or Loss Payables', 'Realized Gain or Loss Receivables'
                            );

UPDATE dbo.tblGLAccountCategory
SET intModuleId =
    (
        SELECT TOP 1 intModuleId FROM dbo.tblSMModule WHERE strModule = 'Sales'
    )
WHERE strAccountCategory IN ( 'AR Account', 'Unrealized Gain or Loss Accounts Payable', 'Sales Tax Account',
                              'Cost of Goods', 'Sales Account', 'Sales Discount', 'Unrealized Gain or Loss Offset AR',
                              'Unrealized Gain or Loss Accounts Receivable', 'Maintenance Sales','Deferred Revenue',
							  'Sales Discount','Customer Prepayments'
                            );

UPDATE dbo.tblGLAccountCategory
SET intModuleId =
    (
        SELECT TOP 1 intModuleId FROM dbo.tblSMModule WHERE strModule = 'Cash Management'
    )
WHERE strAccountCategory IN ( 'Cash Account', 'Unrealized Gain or Loss Cash Management', 'Undeposited Funds',
                              'Unrealized Gain or Loss Offset CM'
                            );

UPDATE dbo.tblGLAccountCategory
SET intModuleId =
    (
        SELECT TOP 1 intModuleId FROM dbo.tblSMModule WHERE strModule = 'Inventory'
    )
WHERE strAccountCategory IN ( 'Inventory', 'Unrealized Gain or Loss Offset Inventory', 'Work In Progress',
                              'Inventory In-Transit', 'Inventory Adjustment',
                              'Unrealized Gain or Loss Offset Inventory', 'Unrealized Gain or Loss Inventory'
                            );

UPDATE dbo.tblGLAccountCategory
SET intModuleId =
    (
        SELECT TOP 1 intModuleId FROM dbo.tblSMModule WHERE strModule = 'Manufacturing'
    )
WHERE strAccountCategory IN ( 'Work In Progress' );

UPDATE dbo.tblGLAccountCategory
SET intModuleId =
    (
        SELECT TOP 1 intModuleId FROM dbo.tblSMModule WHERE strModule = 'Contract Management'
    )
WHERE strAccountCategory IN ( 'Unrealized Gain or Loss Contract Purchase', 'Unrealized Gain or Loss Contract Sales',
                              'Unrealized Gain or Loss Offset Contract Purchase',
                              'Unrealized Gain or Loss Offset Contract Sales'
                            );

UPDATE dbo.tblGLAccountCategory
SET intModuleId =
    (
        SELECT TOP 1 intModuleId FROM dbo.tblSMModule WHERE strModule = 'Risk Management'
    )
WHERE strAccountCategory IN ( 'Futures Trade Equity', 'Futures Gain or Loss Realized' );

GO
PRINT ('Finished updating module in tblGLAccountCategory table');

GO


PRINT ('Begin inserting to tblGLRequiredPrimaryCategory');
GO
	MERGE 
		dbo.tblGLRequiredPrimaryCategory AS Target
	USING	(
			   SELECT C.intAccountCategoryId,
				M.intModuleId
				FROM dbo.tblGLAccountCategory C
				CROSS APPLY
				(
					SELECT TOP 1 intModuleId
					FROM dbo.tblSMModule 
					WHERE intModuleId = C.intModuleId
				) M
	) AS Source
		ON  (Target.intAccountCategoryId = Source.intAccountCategoryId)
	WHEN MATCHED THEN 
		UPDATE 
		SET 	Target.intModuleId = Source.intModuleId
	WHEN NOT MATCHED by Target THEN
		INSERT (intAccountCategoryId,intModuleId)
		VALUES (Source.intAccountCategoryId,Source.intModuleId)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
GO


UPDATE  dbo.tblGLRequiredPrimaryCategory
SET strView = 'i21.view.CompanyLocation', strTab = 'GL Accounts', strScreen = 'Company Location'
WHERE intAccountCategoryId IN (
	SELECT intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory IN(
	'AR Account', 'AP Account', 'Vendor Prepayments',
	 'Customer Prepayments','Service Charges','Sales Discount'
	,'Write Off','Undeposited Funds','Deferred Revenue'))


UPDATE  dbo.tblGLRequiredPrimaryCategory
SET strView = 'i21.view.CompanyPreference', strTab = 'System Manager', strScreen = 'Company Configuration'
WHERE intAccountCategoryId between 60 and 77 -- gain / loss category

UPDATE  dbo.tblGLRequiredPrimaryCategory
SET strView = 'i21.view.TaxCode', strTab = 'Details', strScreen = 'Tax Code'
WHERE intAccountCategoryId IN (48,49) --sales / purchase tax account category


PRINT ('Finished inserting to tblGLRequiredPrimaryCategory');



