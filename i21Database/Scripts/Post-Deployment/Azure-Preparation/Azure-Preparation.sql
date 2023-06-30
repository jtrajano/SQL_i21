PRINT N'BEGIN Dropping SQL Objects that are obsolete'
GO

-- System Manager

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuFRMColumnDescription]'))
	EXEC('DROP FUNCTION [dbo].[vyuFRMColumnDescription]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspFRMColumnDescription]'))
	EXEC('DROP FUNCTION [dbo].[uspFRMColumnDescription]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuSMOriginColumn]'))
	EXEC('DROP FUNCTION [dbo].[vyuSMOriginColumn]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuSMOriginTable]'))
	EXEC('DROP FUNCTION [dbo].[vyuSMOriginTable]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspSMMigrateUserEntity]'))
	EXEC('DROP FUNCTION [dbo].[uspSMMigrateUserEntity]')

-- Accounts Payable

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPVendorToIPayablesJob]'))
	EXEC('DROP FUNCTION [dbo].[uspAPVendorToIPayablesJob]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPGetVendorContact]'))
	EXEC('DROP FUNCTION [dbo].[uspAPGetVendorContact]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportBillsFromAPIVCMST]'))
	EXEC('DROP FUNCTION [dbo].[uspAPImportBillsFromAPIVCMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportBillsFromAPTRXMST]'))
	EXEC('DROP FUNCTION [dbo].[uspAPImportBillsFromAPTRXMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportVoucherBackUpAPTRXMST]'))
	EXEC('DROP FUNCTION [dbo].[uspAPImportVoucherBackUpAPTRXMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPCreateMissingPaymentOfBills]'))
	EXEC('DROP FUNCTION [dbo].[uspAPCreateMissingPaymentOfBills]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportVoucherBackUpAPIVCMST]'))
	EXEC('DROP FUNCTION [dbo].[uspAPImportVoucherBackUpAPIVCMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspAPImportVoucherBackupAPIVCMST]'))
	EXEC('DROP FUNCTION [dbo].[uspAPImportVoucherBackupAPIVCMST]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[tblAPVoucherPayableCompleted2017]'))
	EXEC('DROP FUNCTION [dbo].[tblAPVoucherPayableCompleted2017]')

-- Logistics

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuLGDashboardJDE]'))
	EXEC('DROP FUNCTION [dbo].[vyuLGDashboardJDE]')

-- Accounts Receivable

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspARDeleteCustomer]'))
	EXEC('DROP FUNCTION [dbo].[uspARDeleteCustomer]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspARImportInvoiceCSV]'))
	EXEC('DROP FUNCTION [dbo].[uspARImportInvoiceCSV]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspARUpdatePOSLog]'))
	EXEC('DROP FUNCTION [dbo].[uspARUpdatePOSLog]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspARPostInvoicesIntegrationsNew]'))
	EXEC('DROP FUNCTION [dbo].[uspARPostInvoicesIntegrationsNew]')

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
	EXEC('DROP FUNCTION [dbo].[uspGLUpdateSegmentCategory]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspCMGetBankAccountRegister]'))
	EXEC('DROP FUNCTION [dbo].[uspCMGetBankAccountRegister]')
