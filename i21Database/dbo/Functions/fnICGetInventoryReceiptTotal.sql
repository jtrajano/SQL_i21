CREATE FUNCTION [dbo].[fnICGetInventoryReceiptTotal] (
	@intInventoryReceiptId INT
)

RETURNS NUMERIC(18, 6)

AS

BEGIN
	DECLARE @dblGrandTotal NUMERIC(18, 6) = 0
        , @dblTotalReceiptTax NUMERIC(18, 6) = 0
        , @intInventoryReceiptItemId INT
        , @transactionCurrencyId INT
        , @transactionVendorId INT
        , @totalAmount NUMERIC(18, 6) = 0
        , @totalTax NUMERIC(18, 6) = 0
        , @totalGross NUMERIC(18, 6) = 0
        , @totalTare NUMERIC(18, 6) = 0
        , @totalNet NUMERIC(18, 6) = 0
        , @totalCharges NUMERIC(18, 6) = 0
        , @totalChargesTax NUMERIC(18, 6) = 0

    SELECT @dblTotalReceiptTax = dblTotalReceiptTax, @transactionCurrencyId = intCurrencyId, @transactionVendorId = intEntityVendorId FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId
	
	SELECT @totalAmount = SUM(ISNULL(dblLineTotal, 0))
        , @totalTax = SUM(ISNULL(dblTax, 0))
    FROM tblICInventoryReceiptItem IRI
    WHERE intInventoryReceiptId = @intInventoryReceiptId

    SELECT @totalCharges = ISNULL(SUM(CASE WHEN ISNULL(intCurrencyId, @transactionCurrencyId) = @transactionCurrencyId
                                    THEN (CASE WHEN ISNULL(ysnPrice, 0) = 1 THEN -dblAmount
                                                ELSE (CASE WHEN intEntityVendorId = @transactionVendorId THEN dblAmount ELSE 0 END) END)
                                ELSE 0 END), 0)
        , @totalChargesTax = ISNULL(SUM(CASE WHEN ISNULL(intCurrencyId, @transactionCurrencyId) = @transactionCurrencyId
                                    THEN (CASE WHEN ISNULL(ysnPrice, 0) = 1 THEN -dblTax
                                                ELSE (CASE WHEN ISNULL(intEntityVendorId, @transactionVendorId) = @transactionVendorId THEN dblTax ELSE 0 END) END)
                                ELSE 0 END), 0)
    FROM tblICInventoryReceiptCharge
    WHERE intInventoryReceiptId = @intInventoryReceiptId
    
    SET @dblGrandTotal = @totalAmount + @totalCharges + (@totalTax + @totalChargesTax + @dblTotalReceiptTax)
	
	RETURN @dblGrandTotal
END