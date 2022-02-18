CREATE PROCEDURE [dbo].[uspAPLogVoucherDetailRisk]
	@voucherDetailIds AS Id READONLY,
	@remove BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @rkSummaryLog AS RKSummaryLog;

	INSERT INTO @rkSummaryLog(
		strBatchId,
		strBucketType,
		strTransactionType,
		intTransactionRecordId,
		intTransactionRecordHeaderId,
		intContractDetailId,
		intContractHeaderId,
		strDistributionType,
		strTransactionNumber,
		dtmTransactionDate,
		intCommodityId,
		intItemId,
		intCommodityUOMId,
		intLocationId,
		dblQty,
		dblPrice,
		intEntityId,
		intUserId,
		intTicketId,
		strMiscFields,
		intInventoryReceiptItemId,
		intLoadDetailId,
		intActionId
	)
	SELECT 
		strBatchId = NULL
		, strBucketType = 'Accounts Payables'
		, strTransactionType = 'Voucher'
		, intTransactionRecordId = bd.intBillDetailId
		, intTransactionRecordHeaderId = bd.intBillId
		, intContractDetailId = bd.intContractDetailId
		, intContractHeaderId = bd.intContractHeaderId
		, strDistributionType = ''
		, strTransactionNumber = b.strBillId
		, dtmTransactionDate = b.dtmBillDate 
		, c.intCommodityId
		, bd.intItemId
		, intCommodityUOMId = cum.intCommodityUnitMeasureId
		, intLocationId = b.intShipToId
		, dblQty = CASE WHEN @remove = 1 THEN -bd.dblQtyReceived ELSE bd.dblQtyReceived END
		, dblPrice = CASE WHEN @remove = 1 THEN -b.dblTotal ELSE b.dblTotal END
		, intEntityId = b.intEntityVendorId
		, intUserId = b.intEntityId
		, intTicketId = bd.intScaleTicketId
		, strMiscFields = NULL
		, bd.intInventoryReceiptItemId
		, bd.intLoadDetailId
		, intActionId = CASE WHEN @remove = 1 THEN 62 ELSE 15 END
	FROM tblAPBill b
	INNER JOIN tblAPBillDetail bd ON bd.intBillId = b.intBillId
	INNER JOIN @voucherDetailIds bb
		on bb.intId = bd.intBillDetailId
	CROSS APPLY (
		SELECT * FROM dbo.fnAPGetVoucherCommodity(b.intBillId)
	) c
	INNER JOIN tblICItemUOM iuom ON iuom.intItemUOMId = bd.intUnitOfMeasureId
	INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = c.intCommodityId AND cum.intUnitMeasureId = iuom.intUnitMeasureId
	WHERE bd.intItemId > 0
	
	EXEC [dbo].[uspRKLogRiskPosition] @SummaryLogs = @rkSummaryLog, @Rebuild = 0, @LogContracts = 0

	DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR
		SELECT
			intContractDetailId = bd.intContractDetailId 
			, intContractHeaderId = bd.intContractHeaderId
			, dtmTransactionDate = b.dtmDate
			, intContractSeq	=	bd.intContractSeq
			, b.intCurrencyId
			, cum.intCommodityUnitMeasureId
			, b.intEntityId
			, bd.intBillDetailId
			, dblQty = CASE WHEN @remove = 1 THEN COALESCE(bd.dblNetWeight,bd.dblQtyReceived) ELSE -COALESCE(bd.dblNetWeight,bd.dblQtyReceived) END
		FROM tblAPBill b
		INNER JOIN tblAPBillDetail bd ON bd.intBillId = b.intBillId
		INNER JOIN @voucherDetailIds bb
			on bb.intId = bd.intBillDetailId
		CROSS APPLY (
			SELECT * FROM dbo.fnAPGetVoucherCommodity(b.intBillId)
		) c
		INNER JOIN tblICItemUOM iuom ON iuom.intItemUOMId = bd.intUnitOfMeasureId
		INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = c.intCommodityId AND cum.intUnitMeasureId = iuom.intUnitMeasureId
		WHERE bd.intItemId > 0

	OPEN c;

	DECLARE @ctdId INT;
	DECLARE @cthId INT;
	DECLARE @date DATETIME;
	DECLARE @contractSeq INT;
	DECLARE @basisCurrencyId INT;
	DECLARE @basisUOMId INT;
	DECLARE @source NVARCHAR(20) = 'Inventory';
	DECLARE @process NVARCHAR(100) = 'Create Voucher';
	DECLARE @userId INT;
	DECLARE @transactionId INT;
	DECLARE @dblQty DECIMAL(38,15);
	DECLARE @contractDetailTbl AS ContractDetailTable

	IF (@remove = 1)
	BEGIN
		SET @process = 'Delete Voucher'
	END

	FETCH c 
	INTO @ctdId, @cthId, @date, @contractSeq, @basisCurrencyId, @basisUOMId, @userId, @transactionId, @dblQty
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC [dbo].[uspCTLogSummary]
			@intContractHeaderId	= @cthId,
			@intContractDetailId	= @ctdId,
			@strSource				= @source,
			@strProcess				= @process,
			@contractDetail			= @contractDetailTbl,
			@intUserId				= @userId,
			@intTransactionId		= @transactionId,
			@dblTransactionQty		= @dblQty

		DELETE FROM @contractDetailTbl

		FETCH c 
		INTO @ctdId, @cthId, @date, @contractSeq, @basisCurrencyId, @basisUOMId, @userId, @transactionId, @dblQty
	END

	CLOSE c; DEALLOCATE c;
END