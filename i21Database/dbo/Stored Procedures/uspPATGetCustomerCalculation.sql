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
			   dblTotalPurchases = Total.dblTotalPurchases,
			   dblTotalSales = Total.dblTotalSales,
			   dblRefundAmount = Total.dblRefundAmount,
			   dblEquityRefund = Total.dblEquityRefund,
			   dblCashRefund = Total.dblCashRefund,
			   dbLessFWT = Total.dbLessFWT ,
			   dblLessServiceFee = Total.dblLessServiceFee,
			   dblCheckAmount =  Total.dblCheckAmount,
			   dblTotalVolume = Total.dblVolume,
			   dblTotalRefund = Total.dblTotalRefund
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
	 CROSS APPLY (
	 SELECT DISTINCT CV.intCustomerPatronId AS intCustomerId,
				    (CASE WHEN PC.strPurchaseSale = 'Purchase' THEN SUM(dblVolume) ELSE 0 END) AS dblTotalPurchases,
					(CASE WHEN PC.strPurchaseSale = 'Sale' THEN SUM(dblVolume) ELSE 0 END) AS dblTotalSales,
					(CASE WHEN SUM(RRD.dblRate) <= @dblMinimumRefund THEN 0 ELSE SUM(RRD.dblRate) END) AS dblRefundAmount,
					(SUM(RRD.dblRate) - (SUM(RRD.dblRate) * (RR.dblCashPayout/100))) AS dblEquityRefund,
					(SUM(RRD.dblRate) * (RR.dblCashPayout/100)) AS dblCashRefund,
					((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @FWT) AS dbLessFWT,
					((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @LessService) AS dblLessServiceFee,
					(SUM(RRD.dblRate) * (RR.dblCashPayout/100)) - ((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @FWT) - ((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @LessService) AS dblCheckAmount,
					SUM(dblVolume) AS dblVolume,
					SUM(RRD.dblRate) AS dblTotalRefund
			   FROM tblPATCustomerVolume B
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
			   WHERE B.intCustomerPatronId = CV.intCustomerPatronId
		   GROUP BY PC.strPurchaseSale,
					B.intCustomerPatronId,
					RR.dblCashPayout,
					AC.ysnSubjectToFWT
	 ) Total
		  WHERE CV.intFiscalYear = @intFiscalYearId
	   GROUP BY CV.intCustomerPatronId, 
				ENT.strName, 
				AC.strStockStatus, 
				RR.strRefundType, 
				RR.strRefundDescription, 
				RR.dblCashPayout, 
				RR.ysnQualified, 
				PC.strCategoryCode, 
				RRD.intPatronageCategoryId, 
				CV.intPatronageCategoryId, 
				PC.intPatronageCategoryId, 
				TC.strTaxCode, 
				CV.dtmLastActivityDate,
				PC.strPurchaseSale,
				Total.dblTotalPurchases,
				Total.dblTotalSales,
				Total.dblRefundAmount,
				Total.dblEquityRefund,
				Total.dblCashRefund,
				Total.dbLessFWT,
				Total.dblLessServiceFee,
				Total.dblCheckAmount,
				Total.dblVolume,
				Total.dblTotalRefund,
				AC.ysnSubjectToFWT

	-- ==================================================================
	-- End Transaction
	-- ==================================================================
END

GO