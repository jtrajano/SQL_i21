CREATE VIEW [dbo].[vyuPATCustomerVolumeLogDetail]
	AS
SELECT  CVL.intCustomerVolumeLogId,
		CVL.intBillId,
		CVL.intInvoiceId,
		CVL.intItemId,
		IC.strItemNo,
		strCategoryCode = CASE WHEN ysnDirectSale = 1 THEN DirectPC.strCategoryCode ELSE PC.strCategoryCode END,
		strPurchaseSale = CASE WHEN ysnDirectSale = 1 THEN DirectPC.strPurchaseSale ELSE PC.strPurchaseSale END, 
		strUnitAmount = CASE WHEN ysnDirectSale = 1 THEN DirectPC.strUnitAmount ELSE PC.strUnitAmount END,
		ysnDirectSale,
		ysnIsUnposted,
		dblVolume
FROM tblPATCustomerVolumeLog CVL
INNER JOIN tblICItem IC
	ON IC.intItemId = CVL.intItemId
LEFT JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = IC.intPatronageCategoryId
LEFT JOIN tblPATPatronageCategory DirectPC
	ON DirectPC.intPatronageCategoryId = IC.intPatronageCategoryDirectId
WHERE CVL.ysnIsUnposted <> 1 