CREATE FUNCTION [dbo].[fnGRCheckStorageBalance]
(
	@intCustomerStorageId INT
	,@intTransferStorageId INT
)
RETURNS @Transfers TABLE
(
	intCustomerStorageId INT
	,strStorageTicketNo NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,dblSettlementTotal DECIMAL(24,10)
	,dblTransferTotal DECIMAL(24,10)
	,dblHistoryTotalUnits DECIMAL(24,10)
)
AS
BEGIN
	DECLARE @intSourceId INT
	DECLARE @dblSettlementTotal DECIMAL(24,10)
	DECLARE @dblTransferTotal DECIMAL(24,10)
	DECLARE @dblHistoryTotalUnits DECIMAL(24,10)
	DECLARE @strStorageTicketNo NVARCHAR(40)

	SELECT @strStorageTicketNo = strStorageTicketNumber FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId

	SELECT @dblSettlementTotal = SUM(dblUnits) 
	FROM tblGRSettleStorageTicket A
	INNER JOIN tblGRSettleStorage B
		ON B.intSettleStorageId = A.intSettleStorageId
		AND B.intParentSettleStorageId IS NULL
	WHERE intCustomerStorageId = @intCustomerStorageId	
	
	SELECT @dblTransferTotal = SUM(B.dblOriginalUnits)
	FROM tblGRCustomerStorage A 
	INNER JOIN tblGRTransferStorageSourceSplit B 
		ON B.intSourceCustomerStorageId = A.intCustomerStorageId 
	WHERE B.intSourceCustomerStorageId = @intCustomerStorageId

	SELECT @dblHistoryTotalUnits = SUM(dblUnits)
	FROM tblGRStorageHistory
	WHERE ((intTransactionTypeId IN (5,1,9)) OR (intTransactionTypeId = 3 AND strType = 'From Transfer'))
		AND intCustomerStorageId = @intCustomerStorageId
	GROUP BY intCustomerStorageId

	INSERT INTO @Transfers
	SELECT @intCustomerStorageId, @strStorageTicketNo, @dblSettlementTotal, @dblTransferTotal, @dblHistoryTotalUnits

	RETURN
END