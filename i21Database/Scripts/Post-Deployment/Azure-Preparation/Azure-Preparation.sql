PRINT N'BEGIN Dropping SQL Objects that are obsolete'
GO

-- System Manager

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuFRMColumnDescription]'))
	EXEC('DROP VIEW [dbo].[vyuFRMColumnDescription]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspFRMColumnDescription]'))
	EXEC('DROP PROCEDURE [dbo].[uspFRMColumnDescription]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuSMOriginColumn]'))
	EXEC('DROP VIEW [dbo].[vyuSMOriginColumn]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuSMOriginTable]'))
	EXEC('DROP VIEW [dbo].[vyuSMOriginTable]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspSMMigrateUserEntity]'))
	EXEC('DROP PROCEDURE [dbo].[uspSMMigrateUserEntity]')

-- Accounts Payable

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPVendorToIPayablesJob]'))
	EXEC('DROP PROCEDURE [dbo].[uspAPVendorToIPayablesJob]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPGetVendorContact]'))
	EXEC('DROP PROCEDURE [dbo].[uspAPGetVendorContact]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportBillsFromAPIVCMST]'))
	EXEC('DROP PROCEDURE [dbo].[uspAPImportBillsFromAPIVCMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportBillsFromAPTRXMST]'))
	EXEC('DROP PROCEDURE [dbo].[uspAPImportBillsFromAPTRXMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportVoucherBackUpAPTRXMST]'))
	EXEC('DROP PROCEDURE [dbo].[uspAPImportVoucherBackUpAPTRXMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPCreateMissingPaymentOfBills]'))
	EXEC('DROP PROCEDURE [dbo].[uspAPCreateMissingPaymentOfBills]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportVoucherBackUpAPIVCMST]'))
	EXEC('DROP PROCEDURE [dbo].[uspAPImportVoucherBackUpAPIVCMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportVoucherBackupAPIVCMST]'))
	EXEC('DROP PROCEDURE [dbo].[uspAPImportVoucherBackupAPIVCMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[tblAPVoucherPayableCompleted2017]'))
	EXEC('DROP TABLE [dbo].[tblAPVoucherPayableCompleted2017]')

-- Logistics

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuLGDashboardJDE]'))
	EXEC('DROP VIEW [dbo].[vyuLGDashboardJDE]')

-- Accounts Receivable

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspARDeleteCustomer]'))
	EXEC('DROP PROCEDURE [dbo].[uspARDeleteCustomer]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspARImportInvoiceCSV]'))
	EXEC('DROP PROCEDURE [dbo].[uspARImportInvoiceCSV]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspARUpdatePOSLog]'))
	EXEC('DROP PROCEDURE [dbo].[uspARUpdatePOSLog]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspARPostInvoicesIntegrationsNew]'))
	EXEC('DROP PROCEDURE [dbo].[uspARPostInvoicesIntegrationsNew]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnARGetInvoiceDetailsForPosting]'))
	EXEC('DROP FUNCTION [dbo].[fnARGetInvoiceDetailsForPosting]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnARGetCustomerDefaultCurreny]'))
	EXEC('DROP FUNCTION [dbo].[fnARGetCustomerDefaultCurreny]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnGetTaxMasterIdForCustomer]'))
	EXEC('DROP FUNCTION [dbo].[fnGetTaxMasterIdForCustomer]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnGetTaxGroupTaxCodes]'))
	EXEC('DROP FUNCTION [dbo].[fnGetTaxGroupTaxCodes]')

-- General Ledger

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspGLUpdateSegmentCategory]'))
	EXEC('DROP PROCEDURE [dbo].[uspGLUpdateSegmentCategory]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspCMGetBankAccountRegister]'))
	EXEC('DROP PROCEDURE [dbo].[uspCMGetBankAccountRegister]')

-- Patronage

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnPATCreateIssueStockGLEntries]'))
	EXEC('DROP FUNCTION [dbo].[fnPATCreateIssueStockGLEntries]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnPATCreateRetireStockGLEntries]'))
	EXEC('DROP FUNCTION [dbo].[fnPATCreateRetireStockGLEntries]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnPATGetCustomerRequiredDetailsForVoucher]'))
	EXEC('DROP FUNCTION [dbo].[fnPATGetCustomerRequiredDetailsForVoucher]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspPATBillToCustomerVolume]'))
	EXEC('DROP PROCEDURE [dbo].[uspPATBillToCustomerVolume]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspPATProcessRefundsToVoucher]'))
	EXEC('DROP PROCEDURE [dbo].[uspPATProcessRefundsToVoucher]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspPATProcessVoid]'))
	EXEC('DROP PROCEDURE [dbo].[uspPATProcessVoid]')

-- Transport

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTRDeleteLoadHeader]'))
	EXEC('DROP PROCEDURE [dbo].[uspTRDeleteLoadHeader]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTRDeleteTransportLoad]'))
	EXEC('DROP PROCEDURE [dbo].[uspTRDeleteTransportLoad]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTRPosting]'))
	EXEC('DROP PROCEDURE [dbo].[uspTRPosting]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTRProcessToInventoryReceipt]'))
	EXEC('DROP PROCEDURE [dbo].[uspTRProcessToInventoryReceipt]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTRProcessToInventoryTransfer]'))
	EXEC('DROP PROCEDURE [dbo].[uspTRProcessToInventoryTransfer]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTRProcessToItemReceipt]'))
	EXEC('DROP PROCEDURE [dbo].[uspTRProcessToItemReceipt]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTRProcessToInvoice]'))
	EXEC('DROP PROCEDURE [dbo].[uspTRProcessToInvoice]')

-- Store

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspSTUpdateShiftPhysicalCount]'))
	EXEC('DROP PROCEDURE [dbo].[uspSTUpdateShiftPhysicalCount]')

-- Manufacturing

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspMFInventoryAdjustment_CreatePostLotItemChange]'))
	EXEC('DROP PROCEDURE [dbo].[uspMFInventoryAdjustment_CreatePostLotItemChange]')

-- Motor Fuel Tax

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTFGT103RunTax]'))
	EXEC('DROP PROCEDURE [dbo].[uspTFGT103RunTax]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTFOriginDataIntegration]'))
	EXEC('DROP PROCEDURE [dbo].[uspTFOriginDataIntegration]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspTFRunTax]'))
	EXEC('DROP PROCEDURE [dbo].[uspTFRunTax]')

-- API

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspApiSchemaTransformBoilerplate]'))
	EXEC('DROP PROCEDURE [dbo].[uspApiSchemaTransformBoilerplate]')

GO