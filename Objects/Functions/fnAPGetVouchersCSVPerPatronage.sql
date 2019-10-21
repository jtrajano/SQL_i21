CREATE FUNCTION [dbo].[fnAPGetVouchersCSVPerPatronage]
(
	@intId INT,
	@intItemId INT
)
RETURNS @table TABLE
(
	intId INT,
	intItemId INT,
	strVoucherIds NVARCHAR(MAX)
)
AS
BEGIN

SET ANSI_NULLS OFF 

INSERT INTO @table
SELECT 
	refundEntity.intRefundCustomerId
	,NULL
	,STUFF(
			(
				SELECT  ', ' + b.strBillId
				FROM	tblAPBill b INNER JOIN tblPATRefundCustomer refundBill
							ON b.intBillId = refundBill.intBillId
				WHERE	refundBill.intRefundCustomerId = refundEntity.intRefundCustomerId
						AND b.ysnPosted =1 AND refundBill.ysnEligibleRefund = 1
				GROUP BY b.strBillId
				FOR xml path('')
			)
		, 1
		, 1
		, ''
	)
FROM	tblAPBill bill 
INNER JOIN (tblPATRefund refund INNER JOIN tblPATRefundCustomer refundEntity ON refund.intRefundId = refundEntity.intRefundId)
    ON bill.intBillId = refundEntity.intBillId
WHERE 
	bill.ysnPosted = 1
AND refund.ysnPosted = 1
AND refundEntity.ysnEligibleRefund = 1
AND refundEntity.intRefundCustomerId = @intId
GROUP BY refundEntity.intRefundCustomerId

RETURN;

END

GO