CREATE FUNCTION [dbo].[fnICGetReceiptTotal] (
	@intInventoryReceiptId AS INT 
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @itemTotal NUMERIC(18,6) = 0;
	DECLARE @chargeTotal NUMERIC(18,6) = 0;

	SELECT	@itemTotal = SUM(ISNULL(ri.dblLineTotal, 0) + ISNULL(ri.dblTax, 0)) 
	FROM	tblICInventoryReceiptItem ri
	WHERE	ri.intInventoryReceiptId = @intInventoryReceiptId

	SELECT	@chargeTotal = SUM(
				ISNULL(
					CASE 
						WHEN r.intCurrencyId = c.intCurrencyId THEN 
							CASE 
								WHEN c.ysnPrice = 1 THEN -c.dblAmount 
								WHEN r.intEntityVendorId = ISNULL(c.intEntityVendorId, r.intEntityVendorId) THEN c.dblAmount 
								ELSE 0.00
							END 
						ELSE
							0.00
					END
					,0.00
				)						
				+ 
				ISNULL(
					CASE 
						WHEN r.intCurrencyId = c.intCurrencyId THEN 
							CASE 
								WHEN c.ysnPrice = 1 THEN -c.dblTax 
								WHEN r.intEntityVendorId = ISNULL(c.intEntityVendorId, r.intEntityVendorId) THEN c.dblTax 
								ELSE 0.00
							END 
						ELSE
							0.00
					END
					,0.00
				)
			) 

	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge c 
				ON r.intInventoryReceiptId = c.intInventoryReceiptId
	WHERE	r.intInventoryReceiptId = @intInventoryReceiptId	
	
	RETURN ISNULL(@itemTotal, 0) + ISNULL(@chargeTotal, 0.00)
END