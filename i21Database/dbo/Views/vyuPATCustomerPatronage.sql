CREATE VIEW [dbo].[vyuPATCustomerPatronage]
	AS 
SELECT	RCatPCat.intPatronageCategoryId,
		R.intRefundId,
		RCus.intCustomerId,
		RCatPCat.strDescription,
		RCatPCat.strCategoryCode,
		dblRate = RCatPCat.dblRefundRate,
		RCatPCat.dblVolume,
		RCus.dblRefundAmount
FROM tblPATRefundCustomer RCus
INNER JOIN tblPATRefund R
	ON RCus.intRefundId = R.intRefundId
INNER JOIN tblEMEntity EN
	ON EN.intEntityId = RCus.intCustomerId
INNER JOIN tblARCustomer ARC
	ON ARC.intEntityCustomerId = RCus.intCustomerId
INNER JOIN
(
	SELECT	intRefundCustomerId = RCat.intRefundCustomerId,
			intPatronageCategoryId = RCat.intPatronageCategoryId,
			dblRefundRate = RCat.dblRefundRate,
			strPurchaseSale = PCat.strPurchaseSale,
			strDescription = PCat.strDescription,
			strCategoryCode = PCat.strCategoryCode,
			intRefundTypeId = RRD.intRefundTypeId,
			strRefundType = RR.strRefundType,
			strRefundDescription = RR.strRefundDescription,
			dblCashPayout = RR.dblCashPayout,
			ysnQualified = RR.ysnQualified,
			dblVolume = RCat.dblVolume
	FROM tblPATRefundCategory RCat
	INNER JOIN tblPATPatronageCategory PCat
		ON RCat.intPatronageCategoryId	 = PCat.intPatronageCategoryId
	INNER JOIN tblPATRefundRateDetail RRD
		ON RRD.intPatronageCategoryId = RCat.intPatronageCategoryId
	INNER JOIN tblPATRefundRate RR
		ON RR.intRefundTypeId = RRD.intRefundTypeId
) RCatPCat
	ON RCatPCat.intRefundCustomerId = RCus.intRefundCustomerId
LEFT JOIN tblSMTaxCode TC
	ON TC.intTaxCodeId = ARC.intTaxCodeId