/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

:r .\LoadModules.sql

-- CASH MANAGEMENT
:r ..\dbo\Views\apcbkmst.sql
:r ..\dbo\Views\apchkmst.sql
:r ..\dbo\Views\vwapivcmst.sql
:r ..\dbo\Views\vwclsmst.sql
:r ..\dbo\Views\vwCMBankAccount.sql
:r ..\dbo\Views\vwcmtmst.sql

:r ..\dbo\Views\vwcntmst.sql
:r ..\dbo\Views\vwcoctlmst.sql

-- CUSTOMER PORTAL
:r ..\dbo\Views\vwCPAgcusMst.sql
:r ..\dbo\Views\vwCPBABusinessSummary.sql
:r ..\dbo\Views\vwCPPaymentsDetails.sql

:r ..\dbo\Views\vwCPBillingAccountPayments.sql
:r ..\dbo\Views\vwCPContracts.sql
:r ..\dbo\Views\vwCPCurrentCashBids.sql
:r ..\dbo\Views\vwCPDatabaseDate.sql
:r ..\dbo\Views\vwCPGABusinessSummary.sql
:r ..\dbo\Views\vwCPGAContractDetail.sql
:r ..\dbo\Views\vwCPGAContracts.sql
:r ..\dbo\Views\vwCPInvoicesCredits.sql
:r ..\dbo\Views\vwCPInvoicesCreditsReports.sql
:r ..\dbo\Views\vwCPOptions.sql
:r ..\dbo\Views\vwCPOrders.sql
:r ..\dbo\Views\vwCPPayments.sql

:r ..\dbo\Views\vwCPPendingInvoices.sql
:r ..\dbo\Views\vwCPPendingPayments.sql
:r ..\dbo\Views\vwCPPrepaidCredits.sql
:r ..\dbo\Views\vwCPProductionHistory.sql
:r ..\dbo\Views\vwCPPurchaseDetail.sql
:r ..\dbo\Views\vwCPPurchaseMain.sql
:r ..\dbo\Views\vwCPPurchases.sql
:r ..\dbo\Views\vwCPPurchasesDetail.sql
:r ..\dbo\Views\vwCPSettlements.sql
:r ..\dbo\Views\vwCPStorage.sql

-- TANK MANAGEMENT
:r ..\dbo\Views\vwctlmst.sql
:r ..\dbo\Views\vwcusmst.sql
:r ..\dbo\Views\vwitmmst.sql
:r ..\dbo\Views\vwivcmst.sql
:r ..\dbo\Views\vwlclmst.sql
:r ..\dbo\Views\vwlocmst.sql
:r ..\dbo\Views\vwprcmst.sql
:r ..\dbo\Views\vwpyemst.sql
:r ..\dbo\Views\vwslsmst.sql
:r ..\dbo\Views\vwtaxmst.sql
:r ..\dbo\Views\vwticmst.sql
:r ..\dbo\Views\vwtrmmst.sql
:r ..\dbo\Views\vwDispatch.sql


-- TAX FORMS
:r ..\dbo\Views\vyuTFTaxCycle.sql
