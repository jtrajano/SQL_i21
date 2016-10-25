CREATE FUNCTION [dbo].[fnPATGetCustomerRequiredDetailsForVoucher]
(
	@intRefundId			INT
)
RETURNS @returntable TABLE
(
	[intCustomerId]				INT		NULL,
	[dblCheckAmount]			NUMERIC(18,6)	NULL
)
AS
BEGIN
	INSERT INTO @returntable
	(
		 [intCustomerId]				
		,[dblCheckAmount]
	)
	SELECT	RCus.intCustomerId,
			dblCheckAmount = RCus.dblCashRefund
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