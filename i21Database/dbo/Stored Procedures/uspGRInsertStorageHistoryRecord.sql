CREATE PROCEDURE [dbo].[uspGRInsertStorageHistoryRecord]
(
	@StorageHistoryData AS StorageHistoryStagingTable READONLY,
    @intStorageHistoryId AS INT OUTPUT,
	@strStorageHistoryIds as nvarchar(max) = '' output
)
AS
BEGIN TRY   
     DECLARE @ErrMsg NVARCHAR(MAX)
	 DECLARE @StorageHistoryDataDummy AS StorageHistoryStagingTable
	 DECLARE @intId INT
	 DECLARE @intIds Id

	 INSERT INTO @StorageHistoryDataDummy
	 (
		intCustomerStorageId
		,intSettleStorageId
		,intTransferStorageId
		,intTicketId
		,intDeliverySheetId
		,intInventoryReceiptId
		,intInvoiceId
		,intInventoryShipmentId
		,intBillId
		,intContractHeaderId
		,intInventoryAdjustmentId
		,dblUnits
		,dtmHistoryDate
		,dblPaidAmount
		,dblCost
		,dblCurrencyRate
		,intUserId
		,ysnPost
		,intTransactionTypeId
		,strPaidDescription
		,strType
		,strTransactionId
		,strTransferTicket
		,strSettleTicket
		,strVoucher
		,dblOldCost
		,intTransferStorageReferenceId
	 )
	 SELECT intCustomerStorageId
		,intSettleStorageId
		,intTransferStorageId
		,intTicketId
		,intDeliverySheetId
		,intInventoryReceiptId
		,intInvoiceId
		,intInventoryShipmentId
		,intBillId
		,intContractHeaderId
		,intInventoryAdjustmentId
		,dblUnits
		,dtmHistoryDate
		,dblPaidAmount
		,dblCost
		,dblCurrencyRate
		,intUserId
		,ysnPost
		,intTransactionTypeId
		,strPaidDescription
		,strType
		,strTransactionId
		,strTransferTicket
		,strSettleTicket
		,strVoucher
		,dblOldCost
		,intTransferStorageReferenceId
	FROM @StorageHistoryData

    IF (SELECT COUNT(*) FROM @StorageHistoryData) > 0
    BEGIN
        IF NOT EXISTS(SELECT 
                            intStorageHistoryTransactionId 
                        FROM tblGRStorageHistoryTypeTransaction SHT 
                        INNER JOIN @StorageHistoryData SH 
                            ON SH.intTransactionTypeId = SHT.intTypeId)
            BEGIN
                RAISERROR('Invalid storage transaction.', 16, 1);
                RETURN;
            END                
    END
    ELSE 
        RETURN;
        
	WHILE EXISTS (SELECT TOP 1 1 FROM @StorageHistoryDataDummy)
	BEGIN
		SELECT @intId = intId FROM @StorageHistoryDataDummy

		INSERT INTO [dbo].[tblGRStorageHistory]
		(
			[intCustomerStorageId],
			[intSettleStorageId],
			[intTransferStorageId],
			[intTicketId],
			[intDeliverySheetId],
			[intInventoryReceiptId],
			[intInvoiceId],
			[intInventoryShipmentId],
			[intBillId],
			[intContractHeaderId],
			[intInventoryAdjustmentId],
			[dblUnits],
			[dtmHistoryDate],
			[dblPaidAmount],
			[dblCost],
			[strPaidDescription],
			[dblCurrencyRate],
			[strType],
			[intUserId],
			[ysnPost],
			[dtmDistributionDate],
			[intTransactionTypeId],
			[strTransactionId],
			[intConcurrencyId],
			[strTransferTicket],
			[strSettleTicket],
			[strVoucher],
			[intTransferStorageReferenceId]
		) 
		OUTPUT INSERTED.intStorageHistoryId INTO @intIds(intId)
		SELECT 
			[intCustomerStorageId]          = SH.intCustomerStorageId,
			[intSettleStorageId]            = SH.intSettleStorageId,
			[intTransferStorageId]          = SH.intTransferStorageId,
			[intTicketId]                   = SH.intTicketId,
			[intDeliverySheetId]            = SH.intDeliverySheetId,
			[intInventoryReceiptId]         = SH.intInventoryReceiptId,
			[intInvoiceId]                  = SH.intInvoiceId,
			[intInventoryShipmentId]        = SH.intInventoryShipmentId,
			[intBillId]                     = SH.intBillId,
			[intContractHeaderId]           = SH.intContractHeaderId,
			[intInventoryAdjustmentId]      = SH.intInventoryAdjustmentId,
			[dblUnits]                      = SH.dblUnits,
			[dtmHistoryDate]                = SH.dtmHistoryDate,
			[dblPaidAmount]                 = SH.dblPaidAmount,
			[dblCost]                 		= SH.dblCost,
			[strPaidDescription]            = SH.strPaidDescription,
			[dblCurrencyRate]               = SH.dblCurrencyRate,
			[strType]                       = SH.strType,
			[intUserId]                     = SH.intUserId,
			[ysnPost]                       = SH.ysnPost,
			[dtmDistributionDate]           = GETDATE(),
			[intTransactionTypeId]          = SH.intTransactionTypeId,
			[strTransactionId]			    = SH.strTransactionId,
			1,
			[strTransferTicket]			    = SH.strTransferTicket,
			[strSettleTicket]			    = SH.strSettleTicket,
			[strVoucher]				    = SH.strVoucher,
			[intTransferStorageReferenceId] = SH.intTransferStorageReferenceId
		FROM @StorageHistoryDataDummy SH
		WHERE intId = @intId

		SELECT @intStorageHistoryId = SCOPE_IDENTITY();


		select @strStorageHistoryIds =  @strStorageHistoryIds + cast(intId as nvarchar) + ',' from @intIds


		IF NOT EXISTS(SELECT 1 FROM tblGRStorageHistory WHERE intStorageHistoryId = @intStorageHistoryId AND (intTransactionTypeId IN (1,5,3) OR (intTransactionTypeId = 4 AND strType = 'Settlement')))
		BEGIN
			EXEC uspGRRiskSummaryLog @intStorageHistoryId
		END

		DELETE FROM @StorageHistoryDataDummy WHERE intId = @intId

		IF @intStorageHistoryId IS NULL 
		BEGIN
			RAISERROR('Unable to get Identity value from Storage History', 16, 1);
			RETURN;
		END
	END

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH