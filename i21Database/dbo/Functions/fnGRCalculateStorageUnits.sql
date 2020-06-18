CREATE FUNCTION [dbo].[fnGRCalculateStorageUnits]
(
	@intCustomerStorageId INT 
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	RETURN (
		SELECT
			SUM(dblUnits)
		FROM tblGRStorageHistory
		WHERE intTransactionTypeId IN (5,1,9)
			AND intCustomerStorageId = @intCustomerStorageId
		GROUP BY intCustomerStorageId
	)
END