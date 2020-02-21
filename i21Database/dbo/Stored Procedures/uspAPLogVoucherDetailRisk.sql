CREATE PROCEDURE [dbo].[uspAPLogVoucherDetailRisk]
	@voucherDetailIds AS Id,
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
		dtmCreatedDate,
		strBucketType,
		strTransactionType,
		intTransactionRecordId,
		intTransactionHeaderRecordId,
		strDistributionType,
		strTransactionNumber,
		dtmTransactionDate,
		intCommodityId,
		intItemId,
		intOrigUOMId,
		intLocationId,
		dblOrigQty,
		dblPrice,
		intEntityId,
		intUserId,
		strMiscFields
	)
	SELECT 
		strBatchId = NULL
		, dtmCreatedDate = b.dtmDateCreated
		, strBucketType = 'Accounts Payables'
		, strTransactionType = 'Voucher'
		, intTransactionRecordId = bd.intBillDetailId
		, intTransactionHeaderRecordId = bd.intBillId
		, strDistributionType = ''
		, strTransactionNumber = b.strBillId
		, dtmTransactionDate = b.dtmBillDate 
		, c.intCommodityId
		, bd.intItemId
		, intOrigUOMId = cum.intCommodityUnitMeasureId
		, intLocationId = b.intShipToId
		, dblOrigQty = CASE WHEN @remove = 1 THEN -bd.dblQtyReceived ELSE bd.dblQtyReceived END
		, dblPrice = CASE WHEN @remove = 1 THEN -b.dblTotal ELSE b.dblTotal END
		, intEntityId = b.intEntityVendorId
		, intUserId = b.intUserId
		, strMiscFields = '{intInventoryReceiptItemId = "'+ CAST(ISNULL(bd.intInventoryReceiptItemId,'') AS NVARCHAR) +'"} {intLoadDetailId = "' + CAST(ISNULL(bd.intLoadDetailId,'') AS NVARCHAR) +'"}'
	FROM tblAPBill b
	INNER JOIN tblAPBillDetail bd ON bd.intBillId = b.intBillId
	CROSS APPLY (
		SELECT * FROM dbo.fnAPGetVoucherCommodity(b.intBillId)
	) c
	INNER JOIN tblICItemUOM iuom ON iuom.intItemUOMId = bd.intUnitOfMeasureId
	INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = c.intCommodityId AND cum.intUnitMeasureId = iuom.intUnitMeasureId
	
	EXEC [dbo].[uspRKLogRiskPosition] @SummaryLogs = @rkSummaryLog, @Rebuild = 0

END