CREATE FUNCTION [dbo].[fnGRCheckStorageIfFromLoadOut]
(
	@intCustomerStorageId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @ysnFromLoadOut BIT

	SELECT TOP 1 @ysnFromLoadOut = CAST(CASE WHEN intInventoryShipmentId IS NOT NULL THEN 1 ELSE 0 END AS BIT)
	FROM tblGRStorageHistory
	WHERE intTransactionTypeId = 1
		AND intCustomerStorageId = @intCustomerStorageId
		AND intInventoryShipmentId IS NOT NULL

	RETURN ISNULL(@ysnFromLoadOut,0)

END