/*
	Validates the quantity to receive for PO Detail.
	1. If quantity is null default to 0
	2. If quantity is greater than the remaining quantity to receive for po detail, default to remaining quantity.
	Returns the valid quantity to receive.
*/
CREATE FUNCTION [dbo].[fnAPValidatePODetailQtyToReceive]
(
	@poDetailId INT,
	@quantity DECIMAL(18,6)
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	
	DECLARE @qtyToReceive DECIMAL (18,6);
	DECLARE @qty DECIMAL(18,6);

	SET @qty = ISNULL(@quantity,0);

	SELECT
		@qtyToReceive = (CASE WHEN @qty > (B.dblQtyOrdered - B.dblQtyReceived)
								THEN (B.dblQtyOrdered - B.dblQtyReceived)
								ELSE @qty END)
	FROM tblPOPurchaseDetail B
	WHERE B.intPurchaseDetailId = @poDetailId

	RETURN @qtyToReceive;
END
