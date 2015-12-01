CREATE PROCEDURE [dbo].[uspPATGetCustomerCalculation] 
	@intFiscalYearId INT = NULL,
	@strStockStatus CHAR(1) = NULL,
	@dblMinimumRefund NUMERIC(18,6) = NULL,
	@dblCashCutoffAmount NUMERIC(18,6) = NULL,
	@FWT NUMERIC(18,6) = NULL,
	@LessService NUMERIC(18,6) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    -- ==================================================================
	-- Begin Transaction
	-- ==================================================================

SELECT DISTINCT intCustomerId = CV.intCustomerPatronId,
			   strCustomerName = ENT.strName,
			   AC.strStockStatus,
			   dtmLastActivityDate = CV.dtmLastActivityDate,
			   TC.strTaxCode,
			   ysnEligibleRefund = (CASE WHEN AC.strStockStatus = @strStockStatus THEN 1 ELSE 0 END),
			   dblTotalPurchases = (CASE WHEN PC.strPurchaseSale = 'Purchase' THEN SUM(dblVolume) ELSE 0 END),
			   dblTotalSales = (CASE WHEN PC.strPurchaseSale = 'Sale' THEN SUM(dblVolume) ELSE 0 END),
			   dblRefundAmount = (CASE WHEN SUM(RRD.dblRate) <= @dblMinimumRefund THEN 0 ELSE SUM(RRD.dblRate) END),
			   dblEquityRefund = (SUM(RRD.dblRate) - (SUM(RRD.dblRate) * (RR.dblCashPayout/100))),
			   dblCashRefund = (SUM(RRD.dblRate) * (RR.dblCashPayout/100)),
			   dbLessFWT =	((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @FWT),
			   dblLessServiceFee = ((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @LessService),
			   dblCheckAmount =  (SUM(RRD.dblRate) * (RR.dblCashPayout/100)) - ((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @FWT) - ((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @LessService),
			   dblTotalVolume = SUM(dblVolume),
			   dblTotalRefund = SUM(RRD.dblRate)
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