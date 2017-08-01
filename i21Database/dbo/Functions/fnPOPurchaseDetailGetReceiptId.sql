CREATE FUNCTION [dbo].[fnPOPurchaseDetailGetReceiptId]
(
	@PurchaseDetailId int
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + '|^|', '') + RTRIM(LTRIM( a.intInventoryReceiptId)) 
	from tblICInventoryReceipt a
		join tblICInventoryReceiptItem b
			on a.intInventoryReceiptId = b.intInventoryReceiptId
				and a.strReceiptType = 'Purchase Order'
		join tblPOPurchaseDetail c
			on c.intPurchaseDetailId = b.intLineNo
	where c.intPurchaseDetailId = @PurchaseDetailId

	order by c.intPurchaseDetailId

	RETURN @col

END
