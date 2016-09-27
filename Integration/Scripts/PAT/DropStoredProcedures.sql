PRINT N'BEGIN Remove unused stored procedures in Patronage'
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetCustomerCalculation' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetCustomerCalculation]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetCustomerRefundCalculation' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetCustomerRefundCalculation]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetRefundCalculation' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetRefundCalculation]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetFiscalSummary' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetFiscalSummary]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetNoRefundCalculation' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetNoRefundCalculation]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetCustomerPatronage' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetCustomerPatronage]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetRefundPatronage' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetRefundPatronage]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetFiscalPatronage' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetFiscalPatronage]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetDividends' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetDividends]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetDividendsCustomer' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetDividendsCustomer]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetEquityPatronageDetails' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetEquityPatronageDetails]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetPostedRefundFromAPBill' and type = 'P') 
		DROP PROCEDURE [dbo].[uspPATGetPostedRefundFromAPBill]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetPatronageDetails' and type = 'P')
		DROP PROCEDURE [dbo].[uspPATGetPatronageDetails]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATUpdateVolumeAdjustment' and type = 'P')
		DROP PROCEDURE [dbo].[uspPATUpdateVolumeAdjustment]
	GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspPATGetEquityRefundDetails' and type = 'P')
		DROP PROCEDURE [dbo].[uspPATGetEquityRefundDetails]
GO
PRINT N'END Remove unused stored procedures in Patronage'