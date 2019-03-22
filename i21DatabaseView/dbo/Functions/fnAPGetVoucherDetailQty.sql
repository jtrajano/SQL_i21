CREATE FUNCTION [dbo].[fnAPGetVoucherDetailQty]
(
	@voucherDetailId INT
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	DECLARE @qty DECIMAL(18,6)

	SELECT
		@qty = CASE WHEN A.dblNetWeight > 0
					THEN A.dblNetWeight
					ELSE A.dblQtyReceived
					END
	FROM tblAPBillDetail A
	WHERE A.intBillDetailId = @voucherDetailId

	RETURN @qty;
END
