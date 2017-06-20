CREATE FUNCTION [dbo].[fnICGetReceiptTotals] 
(
	@intInventoryReceiptId INT
	,@totalType INT -- 1- SubTotal; 2- Tax; 3- Charges; 4- Gross; 5- Net; 6- GrandTotal 
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	DECLARE @returnTotal NUMERIC(38,20) = 0
			,@subTotal NUMERIC(38,20) = 0
			,@totalTax NUMERIC(38,20) = 0
			,@totalGross NUMERIC(38,20) = 0
			,@totalNet NUMERIC(38,20) = 0
			,@grandTotal NUMERIC(38,20) = 0
			,@totalCharges NUMERIC(38,20) = 0
			,@totalChargesTax NUMERIC(38,20) = 0
			
	--Get the totals for the receipt
	SELECT @subTotal = SUM(ReceiptItem.dblLineTotal)
		   ,@totalTax = SUM(ReceiptItem.dblTax)
		   ,@totalGross = SUM(ReceiptItem.dblGross)
		   ,@totalNet = SUM(ReceiptItem.dblNet)
	FROM	tblICInventoryReceiptItem ReceiptItem
	WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
	
	--Get the total tax for receipt charges
	IF EXISTS (SELECT 1 FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptId = @intInventoryReceiptId)
	BEGIN
		-- Get the total receipt charges
		-- Add the charge if:
		-- 1. (Receipt >> Currrency Id) = (Charge >> Currency Id)
		-- 2. (Receipt >> Vendor Id) = (Charge >> Vendor Id)
		SELECT @totalCharges = SUM(
					CASE 
						WHEN Receipt.intCurrencyId = ISNULL(ReceiptCharge.intCurrencyId, Receipt.intCurrencyId) THEN 
							CASE 
								WHEN ReceiptCharge.ysnPrice = 1 THEN -ReceiptCharge.dblAmount 
								WHEN Receipt.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) THEN ReceiptCharge.dblAmount 
								ELSE 0.00
							END 
						ELSE
							0.00
					END
				)
		FROM	tblICInventoryReceipt Receipt INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		WHERE	ReceiptCharge.intInventoryReceiptId = @intInventoryReceiptId
				AND ISNULL(Receipt.intCurrencyId, 1) = ISNULL(ReceiptCharge.intCurrencyId, ISNULL(Receipt.intCurrencyId, 1)) 

		-- Get the total tax for receipt charges
		SELECT	@totalChargesTax = 
				SUM (
					CASE 
						WHEN Receipt.intCurrencyId = ISNULL(ReceiptCharge.intCurrencyId, Receipt.intCurrencyId) THEN 
							CASE 
								WHEN ReceiptCharge.ysnPrice = 1 THEN -ReceiptCharge.dblTax 
								WHEN Receipt.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) THEN ReceiptCharge.dblTax 
								ELSE 0.00
							END 
						ELSE
							0.00
					END
				)
		FROM	tblICInventoryReceipt Receipt INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		WHERE	ReceiptCharge.intInventoryReceiptId = @intInventoryReceiptId
				AND ISNULL(Receipt.intCurrencyId, 1) = ISNULL(ReceiptCharge.intCurrencyId, ISNULL(Receipt.intCurrencyId, 1)) 
	END
	
	--Set Total Tax
	SET @totalTax = @totalTax + @totalChargesTax

	--Set Grand Total
	SET @grandTotal = @subTotal + @totalCharges + @totalTax
	
	--Return Total
	IF @totalType = 1 --SubTotal
		SET @returnTotal = @subTotal

	ELSE IF @totalType = 2 --Tax
		SET @returnTotal = @totalTax

	ELSE IF @totalType = 3 --Charges
		SET @returnTotal = @totalCharges

	ELSE IF @totalType = 4 --Gross
		SET @returnTotal = @totalGross

	ELSE IF @totalType = 5 --Net
		SET @returnTotal = @totalNet

	ELSE IF @totalType = 6 --GrandTotal
		SET @returnTotal = @grandTotal

	RETURN @returnTotal
END