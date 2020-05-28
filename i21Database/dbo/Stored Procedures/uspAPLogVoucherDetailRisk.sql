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
		, intActionId = 15
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
	
	EXEC [dbo].[uspRKLogRiskPosition] @SummaryLogs = @rkSummaryLog, @Rebuild = 0

	DECLARE @contractBalance AS CTContractBalanceLog

	INSERT INTO @contractBalance
	(
		strTransactionType
		, intTransactionReferenceId
		, intTransactionReferenceDetailId
		, strTransactionReferenceNo
		, dtmTransactionDate
		, strTransactionReference
		, intContractDetailId
		, intContractHeaderId
		, strContractNumber
		, intContractTypeId
		, intContractSeq
		, intEntityId
		, intCommodityId
		, intItemId
		, intLocationId
		, intPricingTypeId
		, intFutureMarketId
		, intFutureMonthId
		, dblBasis
		, dblFutures
		, intQtyUOMId
		, intQtyCurrencyId
		, intBasisUOMId
		, intBasisCurrencyId
		, intPriceUOMId
		, dtmStartDate
		, dtmEndDate
		, dblQty
		, intContractStatusId
		, intBookId
		, intSubBookId
		, intUserId
		, intActionId
	)
	SELECT 
		 strTransactionType = 'Purchase Basis Deliveries'
		, b.intBillId
		, bd.intBillDetailId
		, b.strBillId
		, dtmTransactionDate = b.dtmDate
		, 'Voucher'
		, intContractDetailId = bd.intContractDetailId
		, intContractHeaderId = bd.intContractHeaderId
		, strContractNumber = ct.strContractNumber
		, intContractTypeId = ct.intContractTypeId
		, intContractSeq	=	bd.intContractSeq
		, intEntityId		=	b.intEntityVendorId
		, c.intCommodityId
		, bd.intItemId
		, b.intShipToId
		, cd.intPricingTypeId
		, cd.intFutureMarketId
		, cd.intFutureMonthId
		, 0 --cd.dblBasis
		, 0 --cd.dblFutures
		, ISNULL(bd.intWeightUOMId, bd.intUnitOfMeasureId)--cd.intUnitMeasureId
		, b.intCurrencyId
		, NULL--cd.intBasisUOMId
		, NULL--cd.intBasisCurrencyId
		, intPriceUOMId = bd.intCostUOMId--cd.intPriceItemUOMId
		, cd.dtmStartDate
		, cd.dtmEndDate
		, dblQty = CASE WHEN @remove = 1 THEN bd.dblQtyReceived ELSE -bd.dblQtyReceived END
		, cd.intContractStatusId
		, cd.intBookId
		, cd.intSubBookId
		, b.intUserId
		, intActionId = 15
	FROM tblAPBill b
	INNER JOIN tblAPBillDetail bd ON bd.intBillId = b.intBillId
	INNER JOIN (tblCTContractDetail cd INNER JOIN tblCTContractHeader ct ON ct.intContractHeaderId = cd.intContractHeaderId)
		ON cd.intContractDetailId = bd.intContractDetailId
	INNER JOIN @voucherDetailIds bb
		on bb.intId = bd.intBillDetailId
	CROSS APPLY (
		SELECT * FROM dbo.fnAPGetVoucherCommodity(b.intBillId)
	) c
	INNER JOIN tblICItemUOM iuom ON iuom.intItemUOMId = bd.intUnitOfMeasureId
	INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = c.intCommodityId AND cum.intUnitMeasureId = iuom.intUnitMeasureId
	WHERE bd.intItemId > 0 AND bd.intContractDetailId > 0

	EXEC uspCTLogContractBalance @contractBalance, 0

END