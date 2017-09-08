CREATE VIEW [dbo].[vyuPATCustomerVolumeLogDetail]
	AS
SELECT  CVL.intCustomerVolumeLogId,
		CVL.intBillId,
		CVL.intInvoiceId,
		CVL.intItemId,
		IC.strItemNo,
		PC.strCategoryCode,
		PC.strPurchaseSale,
		PC.strUnitAmount,
		ysnDirectSale,
		ysnIsUnposted,
		dblVolume
FROM tblPATCustomerVolumeLog CVL
INNER JOIN tblICItem IC
	ON IC.intItemId = CVL.intItemId
INNER JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = IC.intPatronageCategoryId
WHERE CVL.ysnIsUnposted <> 1