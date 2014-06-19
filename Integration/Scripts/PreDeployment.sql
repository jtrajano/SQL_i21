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
:r ..\dbo\Functions\fnIsDepositEntry.sql 
:r ..\dbo\Views\vyuCMBankAccount.sql
:r ..\dbo\Views\vyuCMOriginDepositEntry.sql
:r ..\dbo\Views\vyuCMOriginUndepositedFund.sql
:r "..\dbo\Stored Procedures\uspCMProcessUndepositedFunds.sql"

-- ACCOUNTS PAYABLE
:r ..\dbo\Views\vwapivcmst.sql
:r ..\dbo\Views\vwclsmst.sql
:r ..\dbo\Views\vwcmtmst.sql
:r ..\dbo\Views\vwcntmst.sql

-- CUSTOMER PORTAL
:r ..\dbo\Views\vyuCPAgcusMst.sql
:r ..\dbo\Views\vyuCPBABusinessSummary.sql
:r ..\dbo\Views\vyuCPPaymentsDetails.sql

:r ..\dbo\Views\vyuCPBillingAccountPayments.sql
:r ..\dbo\Views\vyuCPContracts.sql
:r ..\dbo\Views\vyuCPCurrentCashBids.sql
:r ..\dbo\Views\vyuCPDatabaseDate.sql
:r ..\dbo\Views\vyuCPGABusinessSummary.sql
:r ..\dbo\Views\vyuCPGAContractDetail.sql
:r ..\dbo\Views\vyuCPGAContracts.sql
:r ..\dbo\Views\vyuCPGASettlementsReports.sql
:r ..\dbo\Views\vyuCPInvoicesCredits.sql
:r ..\dbo\Views\vyuCPInvoicesCreditsReports.sql
:r ..\dbo\Views\vyuCPOptions.sql
:r ..\dbo\Views\vyuCPOrders.sql
:r ..\dbo\Views\vyuCPPayments.sql

:r ..\dbo\Views\vyuCPPendingInvoices.sql
:r ..\dbo\Views\vyuCPPendingPayments.sql
:r ..\dbo\Views\vyuCPPrepaidCredits.sql
:r ..\dbo\Views\vyuCPProductionHistory.sql
:r ..\dbo\Views\vyuCPPurchaseDetail.sql
:r ..\dbo\Views\vyuCPPurchaseMain.sql
:r ..\dbo\Views\vyuCPPurchases.sql
:r ..\dbo\Views\vyuCPPurchasesDetail.sql
:r ..\dbo\Views\vyuCPSettlements.sql
:r ..\dbo\Views\vyuCPStorage.sql
:r ..\dbo\Views\vyuCPCustomer.sql
:r ..\dbo\Views\vyuCPAgcrdMst.sql
:r ..\dbo\Views\vyuCPGAContractHistory.sql
:r ..\dbo\Views\vyuCPGAContractOption.sql

-- TANK MANAGEMENT
:r ..\dbo\Views\vyuTMOriginOption.sql
:r ..\dbo\Views\vwctlmst.sql
:r ..\dbo\Views\vwitmmst.sql
:r ..\dbo\Views\vwivcmst.sql
:r ..\dbo\Views\vwlclmst.sql
:r ..\dbo\Views\vwlocmst.sql
:r ..\dbo\Views\vwprcmst.sql
:r ..\dbo\Views\vwpyemst.sql
:r ..\dbo\Views\vwticmst.sql
:r ..\dbo\Views\vwcusmst.sql
:r ..\dbo\Views\vwslsmst.sql
:r ..\dbo\Views\vwtaxmst.sql
:r ..\dbo\Views\vwtrmmst.sql
:r ..\dbo\Views\vwDispatch.sql
:r "..\dbo\Stored Procedures\TwoPartDeliveryFillReport.sql"
:r "..\dbo\Stored Procedures\uspTMGetConsumptionWithGasCheck.sql"
:r "..\dbo\Stored Procedures\uspTMGetConsumptionWithLeakCheck.sql"
:r "..\dbo\Stored Procedures\uspTMGetConsumptionWithoutLeakCheck.sql"


:r "..\dbo\Stored Procedures\uspAPImportBillTransactions.sql"
:r "..\dbo\Stored Procedures\uspAPImportVendor.sql"
:r "..\dbo\Stored Procedures\uspAPImportTerms.sql"
:r "..\dbo\Stored Procedures\uspAPUpdateImportedBillTransactions.sql"


-- TAX FORMS
:r ..\dbo\Views\vyuTFTaxCycle.sql
