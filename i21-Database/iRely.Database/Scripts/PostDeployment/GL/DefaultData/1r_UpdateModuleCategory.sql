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

PRINT ('Begin updating module in tblGLRequiredPrimaryCategory table');
GO
DECLARE @tblCategoryModule TABLE ( 
strAccountCategory nvarchar(100)  COLLATE Latin1_General_CI_AS,
strModule nvarchar(100)  COLLATE Latin1_General_CI_AS,
strScreen nvarchar(100)  COLLATE Latin1_General_CI_AS NULL,
strView nvarchar(100)  COLLATE Latin1_General_CI_AS NULL,
strTab nvarchar(100)  COLLATE Latin1_General_CI_AS NULL

)

INSERT INTO @tblCategoryModule 
SELECT 'Cash Account' strAccountCategory,'Cash Management' strModule, 'Bank Accounts' strScreen, 'CashManagement.view.BankAccounts' strView, NULL strTab UNION
SELECT 'Undeposited Funds' strAccountCategory,'Cash Management' strModule, 'Company Location' strScreen, 'i21.view.CompanyLocation' strView, 'GL Accounts' strTab UNION
SELECT 'Unrealized Gain or Loss Cash Management' strAccountCategory,'Cash Management' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Unrealized Gain or Loss Offset CM' strAccountCategory,'Cash Management' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Unrealized Gain or Loss Contract Purchase' strAccountCategory,'Contract Management' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Unrealized Gain or Loss Contract Sales' strAccountCategory,'Contract Management' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Unrealized Gain or Loss Offset Contract Purchase' strAccountCategory,'Contract Management' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Unrealized Gain or Loss Offset Contract Sales' strAccountCategory,'Contract Management' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Inventory' strAccountCategory,'Inventory' strModule, 'Item' strScreen, 'Inventory.view.Item' strView, 'Setup' strTab UNION
SELECT 'Inventory Adjustment' strAccountCategory,'Inventory' strModule, 'Item' strScreen, 'Inventory.view.Item' strView, 'Setup' strTab UNION
SELECT 'Inventory In-Transit' strAccountCategory,'Inventory' strModule, 'Item' strScreen, 'Inventory.view.Item' strView, 'Setup' strTab UNION
SELECT 'Unrealized Gain or Loss Inventory' strAccountCategory,'Inventory' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Unrealized Gain or Loss Offset Inventory' strAccountCategory,'Inventory' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Work In Progress' strAccountCategory,'Inventory' strModule, 'Bag Off' strScreen, 'Manufacturing.view.BagOff' strView, NULL strTab UNION
SELECT 'Work In Progress' strAccountCategory,'Manufacturing' strModule, 'Bag Off' strScreen, 'Manufacturing.view.BagOff' strView, NULL strTab UNION
SELECT 'AP Account' strAccountCategory,'Purchasing' strModule, 'Company Location' strScreen, 'i21.view.CompanyLocation' strView, 'GL Accounts' strTab UNION
SELECT 'AP Clearing' strAccountCategory,'Inventory' strModule,'Item' strScreen, 'Inventory.view.Item' strView, 'Setup' strTab UNION
SELECT 'Other Charge Expense' strAccountCategory,'Purchasing' strModule, 'Voucher' strScreen, 'AccountsPayable.view.Voucher' strView, NULL strTab UNION
SELECT 'Other Charge Income' strAccountCategory,'Purchasing' strModule, 'Voucher' strScreen, 'AccountsPayable.view.Voucher' strView, NULL strTab UNION
SELECT 'Purchase Tax Account' strAccountCategory,'Purchasing' strModule, 'Tax Code' strScreen, 'i21.view.TaxCode' strView, 'Details' strTab UNION
SELECT 'Realized Gain or Loss Payables' strAccountCategory,'Purchasing' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Unrealized Gain or Loss Accounts Payable' strAccountCategory,'Purchasing' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Unrealized Gain or Loss Offset AP' strAccountCategory,'Purchasing' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Vendor Prepayments' strAccountCategory,'Purchasing' strModule, 'Company Location' strScreen, 'i21.view.CompanyLocation' strView, 'GL Accounts' strTab UNION
SELECT 'Futures Gain or Loss Realized' strAccountCategory,'Risk Management' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Futures Trade Equity' strAccountCategory,'Risk Management' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'AR Account' strAccountCategory,'Sales' strModule, 'Company Location' strScreen, 'i21.view.CompanyLocation' strView, 'GL Accounts' strTab UNION
SELECT 'Cost of Goods' strAccountCategory,'Inventory' strModule, 'Item' strScreen, 'Inventory.view.Item' strView, 'Setup' strTab UNION
SELECT 'Customer Prepayments' strAccountCategory,'Sales' strModule, 'Company Location' strScreen, 'i21.view.CompanyLocation' strView, 'GL Accounts' strTab UNION
SELECT 'Deferred Revenue' strAccountCategory,'Sales' strModule, 'Company Location' strScreen, 'i21.view.CompanyLocation' strView, 'GL Accounts' strTab UNION
SELECT 'Maintenance Sales' strAccountCategory,'Inventory' strModule, 'Item' strScreen, 'Inventory.view.Item' strView, 'Setup' strTab UNION
SELECT 'Realized Gain or Loss Receivables' strAccountCategory,'Sales' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Sales Account' strAccountCategory,'Sales' strModule, 'Invoice' strScreen, 'AccountsReceivable.view.Invoice' strView, NULL strTab UNION
SELECT 'Sales Discount' strAccountCategory,'Sales' strModule, 'Company Location' strScreen, 'i21.view.CompanyLocation' strView, 'GL Accounts' strTab UNION
SELECT 'Sales Tax Account' strAccountCategory,'Sales' strModule, 'Tax Code' strScreen, 'i21.view.TaxCode' strView, 'Details' strTab UNION
SELECT 'Service Charges' strAccountCategory,'Sales' strModule,  'Company Location' strScreen, 'i21.view.CompanyLocation' strView, 'GL Accounts' strTab UNION
SELECT 'Unrealized Gain or Loss Accounts Receivable' strAccountCategory,'Sales' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab UNION
SELECT 'Unrealized Gain or Loss Offset AR' strAccountCategory,'Sales' strModule, 'Company Configuration' strScreen, 'i21.view.CompanyPreference' strView, 'System Manager' strTab 


UPDATE cat 
SET intModuleId = sm.intModuleId
FROM dbo.tblGLAccountCategory cat
JOIN @tblCategoryModule catmod ON catmod.strAccountCategory = cat.strAccountCategory
JOIN tblSMModule sm ON sm.strModule = catmod.strModule


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

UPDATE rpc SET strView = catmod.strView, strTab = catmod.strTab, strScreen = catmod.strScreen
FROM dbo.tblGLRequiredPrimaryCategory rpc
JOIN tblGLAccountCategory cat ON  rpc.intAccountCategoryId = cat.intAccountCategoryId
JOIN @tblCategoryModule catmod ON catmod.strAccountCategory = cat.strAccountCategory


GO
PRINT ('Finished updating to tblGLRequiredPrimaryCategory table');
GO



