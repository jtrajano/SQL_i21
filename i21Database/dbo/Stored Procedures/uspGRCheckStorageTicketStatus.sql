CREATE PROCEDURE [dbo].[uspGRCheckStorageTicketStatus]
(
	@intTransactionId INT, --deliverysheet/scaleticket id
	@intUserId INT
)
AS
BEGIN
	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @transCount INT
	DECLARE @intCustomerStorageId INT

	IF OBJECT_ID (N'tempdb.dbo.#tmpCustomerStorage') IS NOT NULL
		DROP TABLE #tmpCustomerStorage
	CREATE TABLE #tmpCustomerStorage (
		[intCustomerStorageId] INT PRIMARY KEY,
		UNIQUE ([intCustomerStorageId])
	);
	INSERT INTO #tmpCustomerStorage
	SELECT 
		intCustomerStorageId
	FROM tblGRCustomerStorage
	WHERE intTicketId = @intTransactionId
		OR intDeliverySheetId = @intTransactionId

	--Check if storage has been settled or transferred
	IF EXISTS(SELECT TOP 1 1 
		FROM tblGRSettleStorageTicket SST
		INNER JOIN #tmpCustomerStorage CS
			ON CS.intCustomerStorageId = SST.intCustomerStorageId
	)
	OR
	EXISTS(SELECT TOP 1 1 
		FROM tblGRTransferStorageSourceSplit TSS
		INNER JOIN #tmpCustomerStorage CS
			ON CS.intCustomerStorageId = TSS.intSourceCustomerStorageId
	)
	BEGIN
		SET @ErrMsg = 'Unable to unpost this Delivery Sheet. <br/>The Open Balance of one or more Storage Tickets no longer matches its Original Balance.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END
END