CREATE FUNCTION [dbo].[fnAPGetVoucherDetailCost]
(
	@voucherDetailId INT
)
RETURNS DECIMAL(38,20)
AS
BEGIN
	DECLARE @cost DECIMAL(38,20);

	SELECT
		@cost =	
			CASE 
				WHEN A.ysnSubCurrency <> 0
					THEN A.dblCost / ISNULL(B.intSubCurrencyCents, 1)
				ELSE A.dblCost
			END / ISNULL(A.dblCostUnitQty, 1)
	FROM tblAPBillDetail A
	INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	WHERE A.intBillDetailId = @voucherDetailId

	RETURN @cost;
END