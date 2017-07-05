CREATE FUNCTION [dbo].[fnAPGetReceiptTotal]
(
	@receiptId INT
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	DECLARE @totalReceiptAmount DECIMAL(18,6);
	DECLARE @totalReceipts INT;
	DECLARE @totalReceiptDetails INT;
	DECLARE @totalChargesCount INT;
	DECLARE @totalCharges DECIMAL(18,6);
	DECLARE @receiptAmount DECIMAL(18,6);
	DECLARE @totalLineItem DECIMAL(18,6);

	SELECT @totalCharges = ISNULL((SUM((CASE WHEN ysnPrice > 0 THEN dblUnitCost * -1 ELSE dblUnitCost END)) + ISNULL(SUM((CASE WHEN ysnPrice > 0 THEN dblTax * -1 ELSE dblTax END)),0.00)),0.00)
	FROM vyuICChargesForBilling WHERE intInventoryReceiptId = @receiptId
	
	SELECT @totalLineItem =   ISNULL(SUM(A.dblLineTotal),0) + ISNULL(SUM(dblTax),0)
	FROM dbo.tblICInventoryReceiptItem A 
	WHERE A.dblUnitCost > 0 AND A.intInventoryReceiptId = @receiptId
	
	SET @totalReceiptAmount = @totalLineItem + @totalCharges;

	RETURN @totalReceiptAmount;
END
GO