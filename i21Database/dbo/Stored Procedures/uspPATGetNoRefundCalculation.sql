CREATE PROCEDURE [dbo].[uspPATGetNoRefundCalculation]
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

SELECT DISTINCT intCustomerId = EC.intCorporateCustomerId,
			   strCustomerName = ENT.strName,
			   AC.strStockStatus,
			   dblTotalPurchases = (CASE WHEN PC.strPurchaseSale = 'Purchase' THEN SUM(dblVolume) ELSE 0 END),
			   dblTotalSales = (CASE WHEN PC.strPurchaseSale = 'Sale' THEN SUM(dblVolume) ELSE 0 END),
			   dblRefundAmount = (CASE WHEN SUM(RRD.dblRate) <= @dblMinimumRefund THEN 0 ELSE SUM(RRD.dblRate) END),
			   dblEquityRefund = (SUM(RRD.dblRate) - (SUM(RRD.dblRate) * (RR.dblCashPayout/100))),
			   dblTotalVolume = SUM(dblVolume),
			   dblTotalRefund = SUM(RRD.dblRate)
		   FROM tblPATEstateCorporation EC
     INNER JOIN tblPATRefundRate RR
             ON RR.intRefundTypeId = EC.intRefundTypeId
	 INNER JOIN tblARCustomer AC
			 ON AC.intEntityCustomerId = EC.intCorporateCustomerId
	  LEFT JOIN tblSMTaxCode TC
			 ON TC.intTaxCodeId = AC.intTaxCodeId
	 INNER JOIN tblEntity ENT
			 ON ENT.intEntityId = EC.intCorporateCustomerId
	 INNER JOIN tblPATRefundRateDetail RRD
			 ON RRD.intRefundTypeId = RR.intRefundTypeId
	 INNER JOIN tblPATPatronageCategory PC
			 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
	  LEFT JOIN tblPATCustomerVolume CV
			 ON CV.intCustomerPatronId = EC.intCorporateCustomerId
		  WHERE CV.intFiscalYear = @intFiscalYearId
		    AND AC.strStockStatus <> @strStockStatus 
	   GROUP BY EC.intCorporateCustomerId, 
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


