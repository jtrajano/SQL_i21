CREATE FUNCTION [dbo].[fnGRGetVoucheredUnits]
(
	-- Add the parameters for the function here
	@intSettleStorageId INT
)
RETURNS DECIMAL(24,10)
AS
BEGIN
	
	return (select sum(dblQtyReceived) from tblAPBillDetail where intBillId in (select intBillId from tblAPBill where strVendorOrderNumber = (select strStorageTicket from tblGRSettleStorage where intSettleStorageId = @intSettleStorageId)) and intContractSeq is not null)
END

