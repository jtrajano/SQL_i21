CREATE VIEW [dbo].[vyuPATVolumeDetails]
	AS 
SELECT	id = CAST(ROW_NUMBER() OVER(ORDER BY FY.dtmDateFrom DESC, ENT.strName) AS int),
		CustomerVolume.intCustomerPatronId,
		ENT.strEntityNo,
		ENT.strName,
		CustomerVolume.intFiscalYear,
		FY.strFiscalYear,
		AR.strStockStatus,
		TC.strTaxCode,
		dblPurchase = SUM(CustomerVolume.dblPurchase),
		dblSale = SUM(CustomerVolume.dblSale),
		dtmLastActivityDate = MAX(AR.dtmLastActivityDate),
		dblTotalVolume = SUM(CustomerVolume.dblPurchase + CustomerVolume.dblSale),
		CustomerVolume.ysnRefundProcessed
FROM (SELECT	CV.intFiscalYear,
		CV.intCustomerPatronId,
		dblPurchase = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN CV.dblVolume ELSE 0 END,
		dblSale = CASE WHEN PC.strPurchaseSale = 'Sale' THEN CV.dblVolume ELSE 0 END,
		CV.ysnRefundProcessed
		FROM tblPATCustomerVolume CV
	INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = intCustomerPatronId
	INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = CV.intPatronageCategoryId
	UNION
	SELECT FY.intFiscalYearId,
			EM.intEntityId,
			dblPurchase = 0,
			dblSale = 0,
			ysnRefundProcessed = CAST(0 AS BIT)
	FROM tblEMEntity EM
	INNER JOIN tblARCustomer AR
		ON AR.intEntityId = EM.intEntityId AND AR.strStockStatus != '' AND AR.dtmMembershipDate IS NULL
	INNER JOIN tblAPVendor AP
		ON AP.intEntityId = EM.intEntityId
	CROSS JOIN tblGLFiscalYear FY
	WHERE YEAR(FY.dtmDateFrom) <= YEAR(GETDATE())
	UNION
	SELECT	FY.intFiscalYearId,
			EM.intEntityId,
			dblPurchase = 0,
			dblSale = 0,
			ysnRefundProcessed = CAST(0 AS BIT)
	FROM tblEMEntity EM
	INNER JOIN tblARCustomer AR
		ON AR.intEntityId = EM.intEntityId AND AR.strStockStatus != '' AND AR.dtmMembershipDate IS NOT NULL
	INNER JOIN tblAPVendor AP
		ON AP.intEntityId = EM.intEntityId
	INNER JOIN tblGLFiscalYear FY
		ON FY.dtmDateFrom >= AR.dtmMembershipDate
	WHERE YEAR(FY.dtmDateFrom) <= YEAR(GETDATE())
) CustomerVolume
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = CustomerVolume.intCustomerPatronId
INNER JOIN tblARCustomer AR
	ON AR.intEntityId = CustomerVolume.intCustomerPatronId
INNER JOIN tblGLFiscalYear FY
	ON FY.intFiscalYearId = CustomerVolume.intFiscalYear
LEFT JOIN tblSMTaxCode TC
	ON TC.intTaxCodeId = AR.intTaxCodeId
GROUP BY CustomerVolume.intCustomerPatronId,
		ENT.strEntityNo,
		ENT.strName,
		CustomerVolume.intFiscalYear,
		FY.strFiscalYear,
		AR.strStockStatus,
		TC.strTaxCode,
		FY.dtmDateFrom,
		CustomerVolume.ysnRefundProcessed