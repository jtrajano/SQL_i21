CREATE PROCEDURE [dbo].[uspPATGetCustomerPatronage] 
	@intFiscalYearId INT = NULL,
	@intCustomerPatronId INT = NULL,
	@intRefundId INT = 0
AS
BEGIN
				
				IF (@intRefundId <= 0)
				BEGIN
					SELECT DISTINCT RRD.intPatronageCategoryId,
						   PC.strDescription,
						   PC.strCategoryCode,
						   RRD.dblRate,
						   dblVolume = CV.dblVolume,
						   dblRefundAmount = ISNULL((RRD.dblRate * CV.dblVolume),0)
					  FROM tblPATRefundRate RR
				INNER JOIN tblPATRefundRateDetail RRD
						ON RRD.intRefundTypeId = RR.intRefundTypeId
				INNER JOIN tblPATPatronageCategory PC
						ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
				INNER JOIN tblPATCustomerVolume CV
						ON CV.intPatronageCategoryId = RRD.intPatronageCategoryId
					 WHERE CV.intCustomerPatronId = @intCustomerPatronId AND CV.intFiscalYear = @intFiscalYearId
				END
				ELSE
				BEGIN
					SELECT	RCatPCat.intPatronageCategoryId,
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
					WHERE R.intRefundId = @intRefundId AND RCus.intCustomerId = @intCustomerPatronId
				END
END
GO