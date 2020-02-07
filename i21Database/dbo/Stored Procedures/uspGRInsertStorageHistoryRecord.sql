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

	-----------------------------------------
	-- Call Risk Module's Summary Log sp
	-----------------------------------------
	BEGIN 
		DECLARE @SummaryLogs AS RKSummaryLog 

		-- Settle Storage
		INSERT INTO @SummaryLogs ( 
			  strBatchId
			, strTransactionType
			, intTransactionRecordId 
			, strTransactionNumber 
			, dtmTransactionDate 
			, intContractDetailId 
			, intContractHeaderId 
			, intTicketId 
			, intCommodityId 
			, intCommodityUOMId 
			, intItemId 
			, intBookId 
			, intSubBookId 
			, intLocationId 
			, intFutureMarketId 
			, intFutureMonthId 
			, dblNoOfLots 
			, dblQty 
			, dblPrice 
			, intEntityId 
			, ysnDelete 
			, intUserId 
			, strNotes  
		)
		SELECT 
			  strBatchId = t.strBatchId
			, strTransactionType = h.strType
			, intTransactionRecordId = h.intSettleStorageId
			, strTransactionNumber = t.strTransactionId
			, dtmTransactionDate = t.dtmDate
			, intContractDetailId = sc.intContractDetailId
			, intContractHeaderId = h.intContractHeaderId
			, intTicketId = NULL
			, intCommodityId = i.intCommodityId
			, intCommodityUOMId = u.intUnitMeasureId
			, intItemId = t.intItemId
			, intBookId = NULL
			, intSubBookId = NULL
			, intLocationId = il.intLocationId
			, intFutureMarketId = NULL
			, intFutureMonthId = NULL
			, dblNoOfLots = NULL
			, dblQty = t.dblQty
			, dblPrice = t.dblCost
			, intEntityId = s.intEntityId
			, ysnDelete = 0
			, intUserId = h.intUserId
			, strNotes = t.strDescription
		FROM tblICInventoryTransaction t
			INNER JOIN @StorageHistoryData h ON t.intTransactionId = h.intSettleStorageId
			INNER JOIN tblGRSettleStorage s ON s.intSettleStorageId = h.intSettleStorageId
			INNER JOIN tblICItem i ON i.intItemId = t.intItemId
			INNER JOIN tblICItemUOM iu ON iu.intItemUOMId = t.intItemUOMId
			INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
			INNER JOIN tblICItemLocation il ON il.intItemLocationId = t.intItemLocationId
			LEFT OUTER JOIN tblGRSettleContract sc ON sc.intSettleStorageId = s.intSettleStorageId
		WHERE t.intTransactionTypeId = 44 -- Magic string for Settle Storage

		-- Storage Transfer
		INSERT INTO @SummaryLogs ( 
			  strBatchId
			, strTransactionType
			, intTransactionRecordId 
			, strTransactionNumber 
			, dtmTransactionDate 
			, intContractDetailId 
			, intContractHeaderId 
			, intTicketId 
			, intCommodityId 
			, intCommodityUOMId 
			, intItemId 
			, intBookId 
			, intSubBookId 
			, intLocationId 
			, intFutureMarketId 
			, intFutureMonthId 
			, dblNoOfLots 
			, dblQty 
			, dblPrice 
			, intEntityId 
			, ysnDelete 
			, intUserId 
			, strNotes  
		)
		SELECT 
			  strBatchId = t.strBatchId
			, strTransactionType = h.strType
			, intTransactionRecordId = h.intCustomerStorageId
			, strTransactionNumber = t.strTransactionId
			, dtmTransactionDate = t.dtmDate
			, intContractDetailId = ct.intContractDetailId
			, intContractHeaderId = ct.intContractHeaderId
			, intTicketId = NULL
			, intCommodityId = i.intCommodityId
			, intCommodityUOMId = u.intUnitMeasureId
			, intItemId = t.intItemId
			, intBookId = NULL
			, intSubBookId = NULL
			, intLocationId = il.intLocationId
			, intFutureMarketId = NULL
			, intFutureMonthId = NULL
			, dblNoOfLots = NULL
			, dblQty = t.dblQty
			, dblPrice = t.dblCost
			, intEntityId = NULL
			, ysnDelete = 0
			, intUserId = h.intUserId
			, strNotes = t.strDescription
		FROM tblICInventoryTransaction t
			INNER JOIN @StorageHistoryData h ON t.intTransactionId = h.intCustomerStorageId
			INNER JOIN tblGRTransferStorageReference sr ON sr.intToCustomerStorageId = h.intCustomerStorageId
			INNER JOIN tblICItem i ON i.intItemId = t.intItemId
			INNER JOIN tblICItemUOM iu ON iu.intItemUOMId = t.intItemUOMId
			INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
			INNER JOIN tblICItemLocation il ON il.intItemLocationId = t.intItemLocationId
			INNER JOIN tblGRTransferStorageSplit spt ON spt.intTransferStorageSplitId = sr.intTransferStorageSplitId
			LEFT OUTER JOIN tblCTContractDetail ct ON ct.intContractDetailId = spt.intContractDetailId
		WHERE t.intTransactionTypeId = 44 -- Magic string for Settle Storage

		EXEC uspRKLogRiskPosition @SummaryLogs
	END

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