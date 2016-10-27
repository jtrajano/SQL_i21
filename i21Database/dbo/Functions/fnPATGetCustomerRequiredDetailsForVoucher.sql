CREATE FUNCTION [dbo].[fnPATGetCustomerRequiredDetailsForVoucher]
(
	@intRefundId			INT
)
RETURNS @returntable TABLE
(
	[intRefundCustomerId] INT			NULL,
	[intCustomerId]		INT				NULL,
	[dblCheckAmount]	NUMERIC(18,6)	NULL,
	[dblServiceFee]		NUMERIC(18,6)	NULL
)
AS
BEGIN
	INSERT INTO @returntable
	(	
		[intRefundCustomerId]
		,[intCustomerId]				
		,[dblCheckAmount]
		,[dblServiceFee]
	)
	SELECT	RCus.intRefundCustomerId,
			RCus.intCustomerId,
			dblCheckAmount = RCus.dblCashRefund,
			dblServiceFee = R.dblServiceFee
	FROM tblPATRefundCustomer RCus
	INNER JOIN tblPATRefund R
		ON RCus.intRefundId = R.intRefundId
	INNER JOIN tblEMEntity EN
		ON EN.intEntityId = RCus.intCustomerId
	INNER JOIN tblAPVendor APV
		ON APV.intEntityVendorId = RCus.intCustomerId
	WHERE R.intRefundId = @intRefundId AND RCus.dblRefundAmount <> 0

	RETURN
END

GO