CREATE FUNCTION [dbo].[fnPOPurchaseDetailGetReceiptId]
(
	@PurchaseDetailId int
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select 
		@col = COALESCE(@col + '|^|', '') + RTRIM(LTRIM(intInventoryReceiptId)) 
	FROM (
		SELECT
			a.intInventoryReceiptId
		from tblICInventoryReceipt a
			join tblICInventoryReceiptItem b
				on a.intInventoryReceiptId = b.intInventoryReceiptId
			join tblPOPurchaseDetail c
				on c.intPurchaseDetailId = b.intLineNo
		where c.intPurchaseDetailId = @PurchaseDetailId
		and a.strReceiptType = 'Purchase Order'
		--order by c.intPurchaseDetailId DESC
		UNION ALL --purchase contract type
		SELECT
			a.intInventoryReceiptId
		from tblICInventoryReceipt a
			join tblICInventoryReceiptItem b
				on a.intInventoryReceiptId = b.intInventoryReceiptId
			join tblPOPurchaseDetail c
				on c.intContractDetailId = b.intLineNo
		where c.intPurchaseDetailId = @PurchaseDetailId
		AND a.strReceiptType = 'Purchase Contract' AND a.intSourceType = 6
		--order by c.intPurchaseDetailId DESC
	) tmpData

	RETURN @col

END
