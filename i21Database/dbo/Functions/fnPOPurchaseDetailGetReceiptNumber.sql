CREATE FUNCTION [dbo].[fnPOPurchaseDetailGetReceiptNumber]
(
	@PurchaseDetailId int
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(strReceiptNumber)) 
	FROM (
		SELECT a.strReceiptNumber
		from tblICInventoryReceipt a
			join tblICInventoryReceiptItem b
				on a.intInventoryReceiptId = b.intInventoryReceiptId
			join tblPOPurchaseDetail c
				on c.intPurchaseDetailId = b.intLineNo
		where c.intPurchaseDetailId = @PurchaseDetailId
		and a.strReceiptType = 'Purchase Order'
		UNION ALL
		SELECT a.strReceiptNumber
		from tblICInventoryReceipt a
			join tblICInventoryReceiptItem b
				on a.intInventoryReceiptId = b.intInventoryReceiptId
			join tblPOPurchaseDetail c
				on c.intContractDetailId = b.intLineNo
		where c.intPurchaseDetailId = @PurchaseDetailId
		and a.strReceiptType = 'Purchase Contract' AND a.intSourceType = 6
	) tmpData
	RETURN @col

END
