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
FROM (
	SELECT	CV.intFiscalYear,
		CV.intCustomerPatronId,
		dblPurchase = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN CV.dblVolume - CV.dblVolumeProcessed ELSE 0 END,
		dblSale = CASE WHEN PC.strPurchaseSale = 'Sale' THEN CV.dblVolume - CV.dblVolumeProcessed ELSE 0 END,
		ysnRefundProcessed = CAST(0 AS BIT)
		FROM tblPATCustomerVolume CV
	--INNER JOIN tblEMEntity ENT
	--	ON ENT.intEntityId = intCustomerPatronId
	INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = CV.intPatronageCategoryId
	WHERE CV.dblVolume > CV.dblVolumeProcessed 
	OR (CV.dblVolume < 0 AND CV.dblVolumeProcessed = 0) --This is to include negative values
	UNION
	SELECT	CV.intFiscalYear,
		CV.intCustomerPatronId,
		dblPurchase = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN CV.dblVolumeProcessed ELSE 0 END,
		dblSale = CASE WHEN PC.strPurchaseSale = 'Sale' THEN CV.dblVolumeProcessed ELSE 0 END,
		ysnRefundProcessed = CAST(1 AS BIT)
		FROM tblPATCustomerVolume CV
	--INNER JOIN tblEMEntity ENT
	--	ON ENT.intEntityId = intCustomerPatronId
	INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = CV.intPatronageCategoryId
	WHERE CV.dblVolumeProcessed > 0
	UNION
	SELECT FY.intFiscalYearId,
			EM.intEntityId,
			dblPurchase = 0,
			dblSale = 0,
			ysnRefundProcessed = CAST(0 AS BIT)
	FROM tblEMEntity EM
	INNER JOIN tblARCustomer AR
		ON AR.intEntityId = EM.intEntityId AND AR.strStockStatus != '' AND AR.dtmMembershipDate IS NULL
	CROSS JOIN (
		SELECT	FY.intFiscalYearId
		FROM tblGLFiscalYear FY
		CROSS JOIN tblGLCurrentFiscalYear CurrentFY
		WHERE FY.dtmDateFrom <= CurrentFY.dtmBeginDate
	) FY
	UNION
	SELECT	FY.intFiscalYearId,
			EM.intEntityId,
			dblPurchase = 0,
			dblSale = 0,
			ysnRefundProcessed = CAST(0 AS BIT)
	FROM tblEMEntity EM
	INNER JOIN tblARCustomer AR
		ON AR.intEntityId = EM.intEntityId AND AR.strStockStatus != '' AND AR.dtmMembershipDate IS NOT NULL
	CROSS JOIN tblGLFiscalYear FY
	--INNER JOIN tblGLFiscalYear FY
	--	ON YEAR(FY.dtmDateFrom) >= YEAR(AR.dtmMembershipDate)
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