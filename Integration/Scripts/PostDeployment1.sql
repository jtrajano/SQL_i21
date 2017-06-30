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

--We have to move it here due to schema changes before executing this store procedure
:r "..\dbo\Stored Procedures\uspAPImportVendor.sql"


-- DROP temp table created from PreDeployment script
IF OBJECT_ID('tempdb..##tblOriginMod') IS NOT NULL DROP TABLE ##tblOriginMod
GO


:r "..\Scripts\AP\TransferImportedTermsData.sql"
:r "..\Scripts\AP\FixImportedVendorOriginFlag.sql"
:r "..\Scripts\AP\TransferImportedVendorData.sql"
--:r "..\Scripts\AP\BackupImportedUnpostedBillDetail.sql"
:r "..\Scripts\NR\uspNRGetPaymentType.sql"
:r "..\Scripts\NR\uspNRGetDetailsForInvoice.sql"
:r "..\Scripts\NR\uspNRCreateAREntry.sql"
:r "..\Scripts\NR\uspNRGenerateEFTSchedule.sql"

--Entity
:r "..\dbo\Stored Procedures\uspEMRecreateCheckIfOriginVendor.sql"
:r "..\dbo\Stored Procedures\uspEMImportEmployees.sql"
--System Manager
:r "..\Scripts\SM\FixCompanyLocationNumber.sql"
:r "..\Scripts\SM\SetDefaultValues.sql"
:r "..\Scripts\SM\InsertOriginTaxClassXRef.sql"

--Patronage
:r "..\Scripts\PAT\DropStoredProcedures.sql"

--General Ledger
:r "..\Scripts\GL\1a_OriginCrossReferenceMapping.sql"
:r "..\Scripts\GL\1b_FlagCOACrossReferenceAccountsFromOrigin.sql"

--Inventory Receipt
GO 
:r "..\Scripts\IC\uspICImportInventoryReceipts_CreateTrigger.sql"
GO
:r "..\Scripts\IC\uspICImportInventoryReceipts.sql"
GO 
:r "..\Scripts\IC\uspICImportInventoryReceiptsAG.sql"
GO
:r "..\Scripts\IC\uspICImportInventoryReceiptsAGItemTax.sql"
GO 
:r "..\Scripts\IC\uspICImportInventoryReceiptsPT.sql"
GO 
:r "..\Scripts\IC\uspICImportInventoryReceiptsPTItemTax.sql"
GO 

-- Inventory
:r "..\Scripts\IC\uspICDCBeginInventoryAg.sql"
GO
:r "..\Scripts\IC\uspICDCBeginInventoryPt.sql"
GO
:r "..\Scripts\IC\uspICDCCatExtraGLAccounts.sql"
GO
:r "..\Scripts\IC\uspICDCCatGLAcctsMigrationAg.sql"
GO
:r "..\Scripts\IC\uspICDCCatGLAcctsMigrationPt.sql"
GO
:r "..\Scripts\IC\uspICDCCatMigrationAg.sql"
GO
:r "..\Scripts\IC\uspICDCCatMigrationPt.sql"
GO
:r "..\Scripts\IC\uspICDCCommodityGLMigrationGr.sql"
GO
:r "..\Scripts\IC\uspICDCCommodityMigrationGr.sql"
GO
:r "..\Scripts\IC\uspICDCItmGLAcctsMigrationAg.sql"
GO
:r "..\Scripts\IC\uspICDCItmGLAcctsMigrationPt.sql"
GO
:r "..\Scripts\IC\uspICDCStorageMigrationAg.sql"
GO
:r "..\Scripts\IC\uspICDCStorageMigrationGr.sql"
GO
:r "..\Scripts\IC\uspICDCStorageMigrationPt.sql"
GO
:r "..\Scripts\IC\uspICDCSubLocationMigration.sql"
GO
:r "..\Scripts\IC\uspICDCUomMigrationAg.sql"
GO
:r "..\Scripts\IC\uspICDCUomMigrationGr.sql"
GO
:r "..\Scripts\IC\uspICDCUomMigrationPt.sql"
GO