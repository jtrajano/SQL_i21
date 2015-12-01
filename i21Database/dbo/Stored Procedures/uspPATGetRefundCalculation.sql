CREATE PROCEDURE [dbo].[uspPATGetRefundCalculation]
	@intFiscalYearId INT = NULL,
	@strStockStatus CHAR(1) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- ==================================================================
	-- Begin Transaction
	-- ==================================================================

SELECT DISTINCT RR.intRefundTypeId,
				RR.strRefundType,
				RR.strRefundDescription,
				RR.dblCashPayout,
				RR.ysnQualified,
				ysnEligibleRefund = (CASE WHEN AC.strStockStatus = @strStockStatus THEN 1 ELSE 0 END),
				dblVolume = (CASE WHEN AC.strStockStatus = @strStockStatus THEN ISNULL(CV.dblVolume,0) ELSE 0 END),
				dblRefundAmount = (CASE WHEN AC.strStockStatus = @strStockStatus THEN ISNULL(SUM(RRD.dblRate),0) ELSE 0 END),
				dblNonRefundAmount = (CASE WHEN AC.strStockStatus <> @strStockStatus THEN ISNULL(SUM(RRD.dblRate),0) ELSE 0 END),
				dblCashRefund = ISNULL((SUM(RRD.dblRate) * (RR.dblCashPayout/100)),0),
				dblEquityRefund = ISNULL((SUM(RRD.dblRate) - (SUM(RRD.dblRate) * (RR.dblCashPayout/100))), 0)
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
				RR.intRefundTypeId,
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