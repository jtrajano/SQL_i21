CREATE VIEW [dbo].[vyuPATAdjustmentVolumeDetail]
	AS
SELECT AVD.intAdjustmentDetailId,
		AVD.intAdjustmentId,
		AVD.intCustomerVolumeId,
		AVD.intPatronageCategoryId,
		AVD.intFiscalYearId,
		FY.strFiscalYear,
		PC.strCategoryCode,
		PC.strDescription,
		PC.strPurchaseSale,
		PC.strUnitAmount,
		AVD.dblQuantityAvailable,
		AVD.dblQuantityAdjusted,
		dblNewQuantity = AVD.dblQuantityAvailable + AVD.dblQuantityAdjusted,
		AVD.intConcurrencyId
FROM tblPATAdjustVolumeDetails AVD
INNER JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = AVD.intPatronageCategoryId
INNER JOIN tblGLFiscalYear FY
	ON FY.intFiscalYearId = AVD.intFiscalYearId 