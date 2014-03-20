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

print 'BEGIN POST DEPLOYMENT'


-- System Manager Default Data
:r .\SM\DefaultData\1_MasterMenu.sql
:r .\SM\DefaultData\2_UserRole.sql
--:r .\SM\DefaultData\3_Currency.sql -- this can be risky if customers has currencies already
:r .\SM\DefaultData\4_StartingNumbers.sql
:r .\SM\DefaultData\5_CompanySetup.sql
:r .\SM\DefaultData\6_Preferences.sql

-- Canned Report
:r .\Reports\1_ReportDisableConstraints.sql
:r .\Reports\2_ReportDeleteOldData.sql
:r .\Reports\3_ReportEnableConstraints.sql
:r .\Reports\4_ReportData.sql

-- Tank Management
-- :r .\TM\1_OriginIndexing.sql

-- Canned Panels
:r .\DB\1_CannedPanels_Panle.sql
:r .\DB\1_CannedPanels_Column.sql
:r .\DB\1_CannedPanels_Format.sql

-- Financials
:r .\FIN\DefaultData\AccountGroup.sql
:r .\FIN\DefaultData\BankTransactionTypes.sql
:r .\FIN\DefaultData\DataImportStatus.sql

-- Version Update
:r .\VersionUpdate.sql


print 'END POST DEPLOYMENT'