CREATE FUNCTION [dbo].[fnPATGetCustomerRequiredDetailsForVoucher]
(
	@intRefundId			INT
)
RETURNS @returntable TABLE
(
	[intCustomerId]				INT		NULL,
	[dblCheckAmount]			DECIMAL	NULL
)
AS
BEGIN
	INSERT INTO @returntable
	(
		 [intCustomerId]				
		,[dblCheckAmount]
	)
	SELECT	RCus.intCustomerId,
			dblCheckAmount = CASE WHEN (RCus.dblCashRefund - (CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 ELSE RCus.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RCus.dblCashRefund * (R.dblServiceFee/100)) < 0) THEN 0 ELSE RCus.dblCashRefund - (CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 ELSE RCus.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RCus.dblCashRefund * (R.dblServiceFee/100)) END
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
	WHERE R.intRefundId = @intRefundId

	RETURN
END

GO