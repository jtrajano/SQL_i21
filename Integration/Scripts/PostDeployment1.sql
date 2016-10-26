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