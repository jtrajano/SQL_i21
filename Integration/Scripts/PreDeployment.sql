﻿/*
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

-- SYSTEM MANAGER
:r "..\dbo\Stored Procedures\uspSMMigrateCurrency.sql"
:r "..\dbo\Stored Procedures\uspSMImportCompanyLocation.sql"
:r "..\dbo\Stored Procedures\uspSMImportPaymentMethod.sql"
:r "..\dbo\Stored Procedures\uspSMSyncCompanyLocation.sql"
:r "..\dbo\Stored Procedures\uspSMSyncPaymentMethod.sql"
:r "..\dbo\Stored Procedures\uspSMImportShipVia.sql"
:r "..\dbo\Stored Procedures\uspSMSyncShipVia.sql"

-- GENERAL LEDGER
:r "..\dbo\Stored Procedures\uspGLImportOriginCOA.sql"
:r "..\dbo\Stored Procedures\uspGLAccountOriginSync.sql"
:r "..\dbo\Stored Procedures\uspGLBuildAccount.sql"
:r "..\dbo\Stored Procedures\uspGLBuildAccountTemporary.sql"
:r "..\dbo\Stored Procedures\uspGLBuildOriginAccount.sql"
:r "..\dbo\Stored Procedures\uspGLGetImportOriginHistoricalJournalError.sql"
:r "..\dbo\Stored Procedures\uspGLImportSubLedger.sql"

-- CASH MANAGEMENT
:r ..\dbo\Views\apcbkmst.sql
:r ..\dbo\Views\apchkmst.sql
:r ..\dbo\Functions\fnIsDepositEntry.sql 
:r ..\dbo\Functions\fnGetCurrencyIdFromi21ToOrigin.sql 
:r ..\dbo\Views\vyuCMBankAccount.sql
:r ..\dbo\Views\vyuCMOriginDepositEntry.sql
:r ..\dbo\Views\vyuCMOriginUndepositedFund.sql
:r "..\dbo\Stored Procedures\uspCMProcessUndepositedFunds.sql"
:r "..\dbo\Stored Procedures\uspCMBankTransactionReversalOrigin.sql"
:r "..\dbo\Stored Procedures\uspCMImportBankAccountsFromOrigin.sql"
:r "..\dbo\Stored Procedures\uspCMImportBankReconciliationFromOrigin.sql"
:r "..\dbo\Stored Procedures\uspCMImportBankTransactionsFromOrigin.sql"
:r "..\dbo\Stored Procedures\uspCMImportValidations.sql"

-- ACCOUNTS PAYABLE
:r ..\dbo\Views\vwapivcmst.sql
:r ..\dbo\Views\vwclsmst.sql
:r ..\dbo\Views\vwcmtmst.sql
:r ..\dbo\Views\vwcntmst.sql
:r "..\dbo\Stored Procedures\uspAPCreatePaymentFromOriginBill.sql"
:r "..\dbo\Stored Procedures\uspAPImportVendor.sql"

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
:r ..\dbo\Views\vyuECCFCardTransaction.sql

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
:r ..\dbo\Views\vyuTMtrprcmst.sql
:r ..\dbo\Views\vyuTMOriginAccountStatus.sql
:r "..\dbo\Stored Procedures\TwoPartDeliveryFillReport.sql"
:r "..\dbo\Stored Procedures\uspTMGetConsumptionWithGasCheck.sql"
:r "..\dbo\Stored Procedures\uspTMGetConsumptionWithLeakCheck.sql"
:r "..\dbo\Stored Procedures\uspTMGetConsumptionWithoutLeakCheck.sql"
:r "..\dbo\Stored Procedures\uspTMGetConsumptionWithoutGasCheck.sql"
:r "..\dbo\Views\vyuTMOriginDegreeOption.sql"
:r "..\Scripts\TM\Customer.sql"
:r "..\dbo\Views\vyuTMConsumptionSiteSearch.sql"
:r "..\dbo\Views\vyuTMSiteOrder.sql"
:r "..\dbo\Functions\fnTMGetSalesTax.sql"
:r "..\dbo\Functions\fnTMGetContractForCustomer.sql"
:r "..\dbo\Functions\fnTMGetSpecialPricing.sql"
:r "..\dbo\Stored Procedures\uspTMImportTankMonitorReading.sql"


--:r "..\dbo\Functions\fnGetVendorLastName.sql"
:r "..\dbo\Stored Procedures\uspAPImportBillTransactions.sql"
:r "..\dbo\Stored Procedures\uspAPImportTerms.sql"
--:r "..\dbo\Stored Procedures\uspAPImportVendor.sql"
:r "..\dbo\Stored Procedures\uspAPPostOriginPayment.sql"
:r "..\Scripts\AP\FixPaymentCMRecords.sql"
:r "..\Scripts\AP\FixBillData.sql"
--:r "..\Scripts\AP\UpdateBillPONumber.sql"



-- TAX FORMS
:r ..\dbo\Views\vyuTFTaxCycle.sql

--ACCOUNTS RECEIVABLE
:r "..\dbo\Stored Procedures\uspARImportAccount.sql"
:r "..\dbo\Stored Procedures\uspARImportCustomer.sql"
:r "..\dbo\Stored Procedures\uspARImportSalesperson.sql"
:r "..\dbo\Stored Procedures\uspARImportMarketZone.sql"
:r "..\dbo\Stored Procedures\uspARImportServiceCharge.sql"
:r "..\dbo\Stored Procedures\uspARImportCustomerContacts.sql"
:r "..\dbo\Stored Procedures\uspARImportInvoice.sql"
:r "..\dbo\Stored Procedures\uspARImportTaxAuthority.sql"
:r "..\dbo\Stored Procedures\uspARImportTerm.sql"
:r "..\dbo\Stored Procedures\uspARSyncTerms.sql"
:r "..\dbo\Stored Procedures\uspARImportPayments.sql"


-- C-Store
:r ..\dbo\Views\vyustpbkmst.sql





