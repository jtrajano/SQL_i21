CREATE PROCEDURE [dbo].[uspPATGetCustomerRefundCalculation]
			@intFiscalYearId INT = NULL,
			@strStockStatus CHAR(1) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	-- ==================================================================
	-- Begin Transaction
	-- ==================================================================

		 SELECT intCustomerId = CV.intCustomerPatronId,
				strCustomerName = ENT.strName,
				ysnEligibleRefund = (CASE WHEN AC.strStockStatus = @strStockStatus THEN 1 ELSE 0 END),
				AC.strStockStatus,
				PC.strPurchaseSale,
				TC.strTaxCode,
				RR.strRefundType,
				RR.strRefundDescription,
				RR.dblCashPayout,
				RR.ysnQualified,
				dtmLastActivityDate = CV.dtmLastActivityDate,
				dblRefundAmount = SUM(RRD.dblRate),
				dblCashRefund = (SUM(RRD.dblRate) * (RR.dblCashPayout/100)),
				dblEquityRefund = (SUM(RRD.dblRate) - (SUM(RRD.dblRate) * (RR.dblCashPayout/100))),
				PC.intPatronageCategoryId,
				PC.strCategoryCode,
				RRD.dblRate,
				dblVolume = CASE WHEN RRD.intPatronageCategoryId = CV.intPatronageCategoryId THEN ISNULL(CV.dblVolume,0) ELSE 0 END,
				dblRefundAmountL2 = (RRD.dblRate * (CASE WHEN PC.intPatronageCategoryId = CV.intPatronageCategoryId THEN ISNULL(CV.dblVolume,0) ELSE 0 END))
		   FROM tblPATCustomerVolume CV
	 INNER JOIN tblPATRefundRateDetail RRD
			 ON RRD.intPatronageCategoryId = CV.intPatronageCategoryId 
     INNER JOIN tblPATRefundRate RR
             ON RR.intRefundTypeId = RRD.intRefundTypeId
	 INNER JOIN tblARCustomer AC
			 ON AC.intEntityCustomerId = CV.intCustomerPatronId
	  LEFT JOIN tblSMTaxCode TC
			 ON TC.intTaxCodeId = AC.intTaxCodeId
	 INNER JOIN tblEntity ENT
			 ON ENT.intEntityId = CV.intCustomerPatronId

	 INNER JOIN tblPATPatronageCategory PC
			 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
		  WHERE CV.intFiscalYear = @intFiscalYearId 
	   GROUP BY CV.intCustomerPatronId, 
				ENT.strName, 
				AC.strStockStatus, 
				RR.strRefundType, 
				RR.strRefundDescription, 
				RR.dblCashPayout, 
				RR.ysnQualified, 
				PC.strCategoryCode, 
				RRD.dblRate, 
				CV.dblVolume, 
				RRD.intPatronageCategoryId, 
				CV.intPatronageCategoryId, 
				PC.intPatronageCategoryId, 
				TC.strTaxCode, 
				CV.dtmLastActivityDate,
				PC.strPurchaseSale

	-- ==================================================================
	-- End Transaction
	-- ==================================================================
END

GO