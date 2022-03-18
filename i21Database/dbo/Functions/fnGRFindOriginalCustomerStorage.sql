CREATE FUNCTION [dbo].[fnGRFindOriginalCustomerStorage]
(
	@intCustomerStorageId int
)
RETURNS @Transfers TABLE
(
	intSourceCustomerStorageId INT
	,dblOriginalBalance DECIMAL(24,10)
	,dblOpenBalance DECIMAL(24,10)
	,dblTotalTransactions DECIMAL(24,10)
	,ysnTransferStorage BIT
)
AS
BEGIN
	DECLARE @intSourceId INT
	DECLARE @ysnTransferStorage BIT
	DECLARE @dblOriginalBalance DECIMAL(24,10)
	DECLARE @dblOpenBalance DECIMAL(24,10)
	DECLARE @dblTotalTransactions DECIMAL(24,10)

	--DELETE FROM @Transfers

	SELECT @intSourceId = intSourceCustomerStorageId
	FROM tblGRTransferStorageReference
	WHERE intToCustomerStorageId = @intCustomerStorageId

	SELECT @ysnTransferStorage = ysnTransferStorage
		,@dblOriginalBalance = dblOriginalBalance
		,@dblOpenBalance = dblOpenBalance
		,@dblTotalTransactions = SH.totalTrans
	FROM tblGRCustomerStorage CS
	OUTER APPLY (
		SELECT totalTrans = SUM(CASE 
						WHEN (strType = 'Settlement' OR strType ='Reduced By Inventory Shipment') AND dblUnits > 0 THEN - dblUnits 
						ELSE dblUnits 
					END)
		FROM tblGRStorageHistory SH
		WHERE intTransactionTypeId NOT IN (2,6)
			AND SH.intCustomerStorageId = CS.intCustomerStorageId
	) SH
	WHERE intCustomerStorageId = @intSourceId

	IF @intSourceId IS NOT NULL
	BEGIN
		INSERT INTO @Transfers
		SELECT @intSourceId, @dblOriginalBalance,@dblOpenBalance,@dblTotalTransactions,@ysnTransferStorage
	END

	WHILE @ysnTransferStorage = 1
	BEGIN
		SELECT @intSourceId = intSourceCustomerStorageId
		FROM tblGRTransferStorageReference
		WHERE intToCustomerStorageId = @intCustomerStorageId

		SELECT @intCustomerStorageId = intToCustomerStorageId
		FROM tblGRTransferStorageReference
		WHERE intToCustomerStorageId = @intSourceId

		SELECT @ysnTransferStorage = ysnTransferStorage
			,@dblOriginalBalance = dblOriginalBalance
			,@dblOpenBalance = dblOpenBalance
			,@dblTotalTransactions = SH.totalTrans
		FROM tblGRCustomerStorage CS
		OUTER APPLY (
			SELECT totalTrans = SUM(CASE 
							WHEN (strType = 'Settlement' OR strType ='Reduced By Inventory Shipment') AND dblUnits > 0 THEN - dblUnits 
							ELSE dblUnits 
						END)
			FROM tblGRStorageHistory SH
			WHERE intTransactionTypeId NOT IN (2,6)
				AND SH.intCustomerStorageId = CS.intCustomerStorageId
		) SH
		WHERE intCustomerStorageId = @intSourceId

		IF @intSourceId NOT IN (SELECT intSourceCustomerStorageId FROM @Transfers)
		BEGIN
			INSERT INTO @Transfers
			SELECT @intSourceId, @dblOriginalBalance,@dblOpenBalance,@dblTotalTransactions,@ysnTransferStorage
		END
	END

	RETURN
END