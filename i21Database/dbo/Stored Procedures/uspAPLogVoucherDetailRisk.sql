﻿CREATE PROCEDURE [dbo].[uspAPLogVoucherDetailRisk]
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
		, strMiscFields = '{intInventoryReceiptItemId = "'+ CAST(ISNULL(bd.intInventoryReceiptItemId,'') AS NVARCHAR) +'"} {intLoadDetailId = "' + CAST(ISNULL(bd.intLoadDetailId,'') AS NVARCHAR) +'"}'
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

	-- DECLARE @contractBalance AS CTContractBalanceLog

	-- INSERT INTO @contractBalance
	-- (
	-- 	strTransactionType
	-- 	, intTransactionReferenceId
	-- 	, intTransactionReferenceDetailId
	-- 	, strTransactionReferenceNo
	-- 	, dtmTransactionDate
	-- 	, strTransactionReference
	-- 	, intContractDetailId
	-- 	, intContractHeaderId
	-- 	, strContractNumber
	-- 	, intContractTypeId
	-- 	, intContractSeq
	-- 	, intEntityId
	-- 	, intCommodityId
	-- 	, intItemId
	-- 	, intLocationId
	-- 	, intPricingTypeId
	-- 	, intFutureMarketId
	-- 	, intFutureMonthId
	-- 	, dblBasis
	-- 	, dblFutures
	-- 	, intQtyUOMId
	-- 	, intQtyCurrencyId
	-- 	, intBasisUOMId
	-- 	, intBasisCurrencyId
	-- 	, intPriceUOMId
	-- 	, dtmStartDate
	-- 	, dtmEndDate
	-- 	, dblQty
	-- 	, intContractStatusId
	-- 	, intBookId
	-- 	, intSubBookId
	-- 	, intUserId
	-- 	, intActionId
	-- )
	-- SELECT 
	-- 	 strTransactionType = 'Purchase Basis Deliveries'
	-- 	, b.intBillId
	-- 	, bd.intBillDetailId
	-- 	, b.strBillId
	-- 	, dtmTransactionDate = b.dtmDate
	-- 	, 'Voucher'
	-- 	, intContractDetailId = bd.intContractDetailId
	-- 	, intContractHeaderId = bd.intContractHeaderId
	-- 	, strContractNumber = ct.strContractNumber
	-- 	, intContractTypeId = ct.intContractTypeId
	-- 	, intContractSeq	=	bd.intContractSeq
	-- 	, intEntityId		=	b.intEntityVendorId
	-- 	, c.intCommodityId
	-- 	, bd.intItemId
	-- 	, b.intShipToId
	-- 	, cd.intPricingTypeId
	-- 	, cd.intFutureMarketId
	-- 	, cd.intFutureMonthId
	-- 	, 0 --cd.dblBasis
	-- 	, 0 --cd.dblFutures
	-- 	, cum.intCommodityUnitMeasureId --ISNULL(bd.intWeightUOMId, bd.intUnitOfMeasureId)--cd.intUnitMeasureId
	-- 	, b.intCurrencyId
	-- 	, NULL--cd.intBasisUOMId
	-- 	, NULL--cd.intBasisCurrencyId
	-- 	, intPriceUOMId = bd.intCostUOMId--cd.intPriceItemUOMId
	-- 	, cd.dtmStartDate
	-- 	, cd.dtmEndDate
	-- 	, dblQty = CASE WHEN @remove = 1 THEN COALESCE(bd.dblNetWeight,bd.dblQtyReceived) ELSE -COALESCE(bd.dblNetWeight,bd.dblQtyReceived) END
	-- 	, cd.intContractStatusId
	-- 	, cd.intBookId
	-- 	, cd.intSubBookId
	-- 	, b.intEntityId
	-- 	, intActionId = CASE WHEN @remove = 1 THEN 62 ELSE 15 END
	-- FROM tblAPBill b
	-- INNER JOIN tblAPBillDetail bd ON bd.intBillId = b.intBillId
	-- INNER JOIN (tblCTContractDetail cd INNER JOIN tblCTContractHeader ct ON ct.intContractHeaderId = cd.intContractHeaderId)
	-- 	ON cd.intContractDetailId = bd.intContractDetailId
	-- INNER JOIN @voucherDetailIds bb
	-- 	on bb.intId = bd.intBillDetailId
	-- CROSS APPLY (
	-- 	SELECT * FROM dbo.fnAPGetVoucherCommodity(b.intBillId)
	-- ) c
	-- INNER JOIN tblICItemUOM iuom ON iuom.intItemUOMId = ISNULL(bd.intWeightUOMId, bd.intUnitOfMeasureId)
	-- INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = c.intCommodityId AND cum.intUnitMeasureId = iuom.intUnitMeasureId
	-- WHERE bd.intItemId > 0 AND bd.intContractDetailId > 0
	-- AND dbo.fnCTCheckIfBasisDeliveries(bd.intContractDetailId, ISNULL(bd.intInventoryReceiptItemId, bd.intSettleStorageId), 'Purchase Basis Deliveries') = 1

	-- EXEC uspCTLogContractBalance @contractBalance, 0

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
			, b.intBillId
			, dblQty = CASE WHEN @remove = 1 THEN COALESCE(bd.dblNetWeight,bd.dblQtyReceived) ELSE -COALESCE(bd.dblNetWeight,bd.dblQtyReceived) END
		FROM tblAPBill b
		INNER JOIN tblAPBillDetail bd ON bd.intBillId = b.intBillId
		INNER JOIN (tblCTContractDetail cd INNER JOIN tblCTContractHeader ct ON ct.intContractHeaderId = cd.intContractHeaderId)
			ON cd.intContractDetailId = bd.intContractDetailId
		INNER JOIN @voucherDetailIds bb
			on bb.intId = bd.intBillDetailId
		CROSS APPLY (
			SELECT * FROM dbo.fnAPGetVoucherCommodity(b.intBillId)
		) c
		INNER JOIN tblICItemUOM iuom ON iuom.intItemUOMId = ISNULL(bd.intWeightUOMId, bd.intUnitOfMeasureId)
		INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = c.intCommodityId AND cum.intUnitMeasureId = iuom.intUnitMeasureId
		WHERE bd.intItemId > 0 AND bd.intContractDetailId > 0
		AND dbo.fnCTCheckIfBasisDeliveries(bd.intContractDetailId, ISNULL(bd.intInventoryReceiptItemId, bd.intSettleStorageId), 'Purchase Basis Deliveries') = 1

	OPEN c;

	DECLARE @ctdId INT;
	DECLARE @cthId INT;
	DECLARE @date DATETIME;
	DECLARE @contractSeq INT;
	DECLARE @basisCurrencyId INT;
	DECLARE @basisUOMId INT;
	DECLARE @source NVARCHAR(20) = 'Voucher';
	DECLARE @process NVARCHAR(100) = 'Purchase Basis Deliveries';
	DECLARE @userId INT;
	DECLARE @transactionId INT;
	DECLARE @dblQty DECIMAL(38,15);
	DECLARE @contractDetailTbl AS ContractDetailTable

	FETCH c 
	INTO @ctdId, @cthId, @date, @contractSeq, @basisCurrencyId, @basisUOMId, @userId, @transactionId, @dblQty
	WHILE @@FETCH_STATUS = 0
	BEGIN

		INSERT INTO @contractDetailTbl(
			[intContractDetailId], 
			[intContractHeaderId],
			[dtmCreated],
			[intContractSeq],
			[intBasisCurrencyId],
			[intBasisUOMId]
		)
		SELECT
			@ctdId,
			@cthId,
			@date,
			@contractSeq,
			@basisCurrencyId,
			@basisUOMId

		EXEC [dbo].[uspCTLogSummary]
			@intContractHeaderId	= @cthId,
			@intContractDetailId	= ctdId,
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