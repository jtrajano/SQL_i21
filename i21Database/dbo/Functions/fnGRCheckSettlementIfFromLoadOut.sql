CREATE FUNCTION [dbo].[fnGRCheckSettlementIfFromLoadOut]
(
	@intSettleStorageId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @ysnFromLoadOut BIT
	DECLARE @intCustomerStorageId INT

	SELECT @intCustomerStorageId = CS.intCustomerStorageId
	FROM tblGRSettleStorage SS
	INNER JOIN tblGRSettleStorageTicket SST
		ON SST.intSettleStorageId = SS.intSettleStorageId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = SST.intCustomerStorageId
	WHERE SS.intSettleStorageId = @intSettleStorageId

	SELECT TOP 1 @ysnFromLoadOut = CAST(CASE WHEN intInventoryShipmentId IS NOT NULL THEN 1 ELSE 0 END AS BIT)
	FROM tblGRStorageHistory
	WHERE intTransactionTypeId = 1
		AND intCustomerStorageId = @intCustomerStorageId
		AND intInventoryShipmentId IS NOT NULL

	RETURN ISNULL(@ysnFromLoadOut,0)

END