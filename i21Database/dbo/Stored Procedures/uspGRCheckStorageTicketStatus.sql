CREATE PROCEDURE [dbo].[uspGRCheckStorageTicketStatus]
(
	@intTransactionId INT, --deliverysheet / scaleticket id
	@strTransactionCode NVARCHAR(20), --DS (delivery sheet) / SC (scale)
	@intUserId INT
)
AS
BEGIN
	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @transCount INT
	DECLARE @CustomerStorageIds AS Id

	IF @strTransactionCode = 'SC'
	BEGIN
		INSERT INTO @CustomerStorageIds
		SELECT 
			intCustomerStorageId
		FROM tblGRCustomerStorage
		WHERE intTicketId = @intTransactionId
	END
	ELSE IF @strTransactionCode = 'DS'
	BEGIN
		INSERT INTO @CustomerStorageIds
		SELECT 
			intCustomerStorageId
		FROM tblGRCustomerStorage
		WHERE intDeliverySheetId = @intTransactionId
	END

	--Check if storage has been settled or transferred
	IF EXISTS(SELECT TOP 1 1 
		FROM tblGRSettleStorageTicket SST
		INNER JOIN tblGRSettleStorage SS
			ON SS.intSettleStorageId = SST.intSettleStorageId
				AND SS.intParentSettleStorageId IS NOT NULL
				AND SS.ysnReversed = 0
		INNER JOIN @CustomerStorageIds CS
			ON CS.intId = SST.intCustomerStorageId
	)
	OR
	EXISTS(SELECT TOP 1 1 
		FROM tblGRTransferStorageSourceSplit TSS
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = TSS.intTransferStorageId
				AND TS.ysnReversed = 0
		INNER JOIN @CustomerStorageIds CS
			ON CS.intId = TSS.intSourceCustomerStorageId
	)
	BEGIN
		SET @ErrMsg = 'Unable to unpost this transaction. <br/>The Open Balance of one or more Storage Tickets no longer matches its Original Balance.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END
END