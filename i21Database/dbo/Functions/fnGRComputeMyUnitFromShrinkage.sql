CREATE FUNCTION [dbo].[fnGRComputeMyUnitFromShrinkage]
(
	@intInventoryReceiptId int
	,@intInventoryReceiptItemId int
	,@dblUnitToCompute decimal(24,10)
)
returns decimal(24, 10)
as 
begin
	declare @Computed decimal(24,10)
	SELECT top 1
			@Computed = (@dblUnitToCompute + ((@dblUnitToCompute / dblNetUnits) * ABS(dblShrinkage)))
			/*intCustomerStorageId
			,intInventoryReceiptId
			,intInventoryReceiptItemId
			,dblNetUnits
			,dblShrinkage
			,dblTransactionUnits			*/
		FROM tblGRStorageInventoryReceipt
		WHERE ysnUnposted = 0
			and intInventoryReceiptId = @intInventoryReceiptId
			and intInventoryReceiptItemId = @intInventoryReceiptItemId
		order by intStorageInventoryReceipt 


	return @Computed
end