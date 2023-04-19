CREATE FUNCTION [dbo].[fnAPGetVoucherDetailQty]
(
	@voucherDetailId INT
)
RETURNS DECIMAL(38,15)
AS
BEGIN
	DECLARE @qty DECIMAL(18,6)

	SELECT
		@qty = 
			CASE 
				WHEN A.intComputeTotalOption = 0 AND A.intWeightUOMId IS NOT NULL AND WC.intWeightClaimDetailId IS NULL
					THEN A.dblNetWeight * A.dblWeightUnitQty
				ELSE A.dblQtyReceived * A.dblUnitQty 
			END
	FROM tblAPBillDetail A
	INNER JOIN tblAPBill B ON B.intBillId = A.intBillId
	LEFT JOIN tblLGWeightClaimDetail WC ON WC.intBillId = B.intBillId
	WHERE A.intBillDetailId = @voucherDetailId

	RETURN @qty;
END
