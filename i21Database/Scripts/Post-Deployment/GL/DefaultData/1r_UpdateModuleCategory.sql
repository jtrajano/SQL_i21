﻿/*
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
                              'Purchase Tax Account', 'Vendor Prepayments', 'Customer Prepayments',
                              'Other Charge Expense', 'Other Charge Income', 'Unrealized Gain or Loss Offset AP',
                              'Realized Gain or Loss Payables', 'Realized Gain or Loss Receivables'
                            );

UPDATE dbo.tblGLAccountCategory
SET intModuleId =
    (
        SELECT TOP 1 intModuleId FROM dbo.tblSMModule WHERE strModule = 'Sales'
    )
WHERE strAccountCategory IN ( 'AR Account', 'Unrealized Gain or Loss Accounts Payable', 'Sales Tax Account',
                              'Cost of Goods', 'Sales Account', 'Sales Discount', 'Unrealized Gain or Loss Offset AR',
                              'Unrealized Gain or Loss Accounts Receivable', 'Maintenance Sales'
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
IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblGLRequiredPrimaryCategory)
    INSERT INTO dbo.tblGLRequiredPrimaryCategory
    (
        intAccountCategoryId,
        intModuleId
     )
     SELECT C.intAccountCategoryId,
           C.intModuleId
     FROM dbo.tblGLAccountCategory C
		CROSS APPLY
		(
			SELECT TOP 1 strModuleName
			FROM dbo.tblARCustomerLicenseModule
			WHERE intModuleId = C.intModuleId
		) M




    


PRINT ('Finished inserting to tblGLRequiredPrimaryCategory');



