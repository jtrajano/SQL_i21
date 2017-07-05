﻿GO
PRINT 'DROPPING AP VIEWS'

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPPayments')
	DROP VIEW vyuAPPayments
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPPaymentDetail')
	DROP VIEW vyuAPPaymentDetail
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPBillBatch')
	DROP VIEW vyuAPBillBatch
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPBill')
	DROP VIEW vyuAPBill
GO
--IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPVendor')
--	DROP VIEW vyuAPVendor
--GO
--IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPVendorHistory')
--	DROP VIEW vyuAPVendorHistory
--GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPPayablesAgingSummary')
	DROP VIEW vyuAPPayablesAgingSummary
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPPayablesSummary')
	DROP VIEW vyuAPPayablesSummary
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPPayables')
	DROP VIEW vyuAPPayables
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPOriginCCDTransaction')
	DROP VIEW vyuAPOriginCCDTransaction
GO

PRINT 'END DROPPING AP VIEWS'
GO

