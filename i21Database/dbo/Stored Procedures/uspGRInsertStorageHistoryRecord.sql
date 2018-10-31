CREATE PROCEDURE [dbo].[uspGRInsertStorageHistoryRecord]
(
	@StorageHistoryData AS StorageHistoryStagingTable READONLY,
    @intStorageHistoryId AS INT = 0 OUTPUT
)
AS
BEGIN TRY   
     DECLARE @ErrMsg NVARCHAR(MAX)


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
        RETURN
        

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
        [strPaidDescription],
        [dblCurrencyRate],
        [strType],
        [intUserId],
        [ysnPost],
        [dtmDistributionDate],
        [intTransactionTypeId],
		[strTransactionId],
        [intConcurrencyId]
    ) 
    SELECT 
        [intCustomerStorageId]      = SH.intCustomerStorageId,
        [intSettleStorageId]        = SH.intSettleStorageId,
        [intTransferStorageId]      = SH.intTransferStorageId,
        [intTicketId]               = SH.intTicketId,
        [intDeliverySheetId]        = SH.intDeliverySheetId,
        [intInventoryReceiptId]     = SH.intInventoryReceiptId,
        [intInvoiceId]              = SH.intInvoiceId,
        [intInventoryShipmentId]    = SH.intInventoryShipmentId,
        [intBillId]                 = SH.intBillId,
        [intContractHeaderId]       = SH.intContractHeaderId,
        [intInventoryAdjustmentId]  = SH.intInventoryAdjustmentId,
        [dblUnits]                  = SH.dblUnits,
        [dtmHistoryDate]            = SH.dtmHistoryDate,
        [dblPaidAmount]             = SH.dblPaidAmount,
        [strPaidDescription]        = SH.strPaidDescription,
        [dblCurrencyRate]           = SH.dblCurrencyRate,
        [strType]                   = SH.strType,
        [intUserId]                 = SH.intUserId,
        [ysnPost]                   = SH.ysnPost,
        [dtmDistributionDate]       = GETDATE(),
        [intTransactionTypeId]      = SH.intTransactionTypeId,
		[strTransactionId]			= SH.strTransactionId,
        1
    FROM @StorageHistoryData SH

    SELECT @intStorageHistoryId = SCOPE_IDENTITY();

    IF @intStorageHistoryId IS NULL 
	BEGIN
		RAISERROR('Unable to get Identity value from Storage History', 16, 1);
		RETURN;
	END

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH