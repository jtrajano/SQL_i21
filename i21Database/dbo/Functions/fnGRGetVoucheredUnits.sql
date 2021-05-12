CREATE FUNCTION [dbo].[fnGRGetVoucheredUnits]
(
	-- Add the parameters for the function here
	@intSettleStorageId INT
)
RETURNS DECIMAL(24,10)
AS
BEGIN
	--Mon
	return (select sum(dblQtyReceived) 
				from tblAPBillDetail 
					where intSettleStorageId = @intSettleStorageId
						and intContractSeq is not null)
END

