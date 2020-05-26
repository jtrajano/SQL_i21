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
		strMiscFields
	)
	SELECT 
		strBatchId = NULL
		, strBucketType = 'Accounts Payables'
		, strTransactionType = 'Bill'
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

END