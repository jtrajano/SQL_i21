CREATE PROCEDURE [dbo].[uspAPLogPaymentRisk]
	@payVoucherDetailIds AS Id READONLY,
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
		, strTransactionType = 'AP Payment'
		, intTransactionRecordId = D.intBillDetailId
		, intTransactionRecordHeaderId = C.intBillId
		, intContractDetailId = D.intContractDetailId
		, intContractHeaderId = D.intContractHeaderId
		, strDistributionType = ''
		, strTransactionNumber = C.strBillId
		, dtmTransactionDate = B.dtmDatePaid
		, C.intCommodityId
		, D.intItemId
		, intCommodityUOMId = cum.intCommodityUnitMeasureId
		, intLocationId = C.intShipToId
		, dblQty = (A.dblPayment + (CASE WHEN (A.dblAmountDue = 0) THEN A.dblDiscount ELSE 0 END))
		 							--get the percentage of payment made to total amount due
									/ (CASE WHEN @remove = 1 THEN (C.dblAmountDue + A.dblPayment) 
											ELSE (C.dblTotal) END) --get the percentage of payment
									* D.dblQtyReceived
									* (CASE WHEN @remove = 1 THEN -1 ELSE 1 END)
		, dblPrice = (CAST(dbo.fnAPGetPaymentAmountFactor(D.dblTotal + D.dblTax, A.dblPayment 
																		+ (CASE WHEN (A.dblAmountDue = 0) THEN A.dblDiscount ELSE 0 END)
																		, C.dblTotal) AS DECIMAL(18,2))) 
					* (CASE WHEN @remove = 1 THEN -1 ELSE 1 END)
		, intEntityId = C.intEntityVendorId
		, intUserId = B.intEntityId
		, intTicketId = D.intScaleTicketId
		, strMiscFields = '{intInventoryReceiptItemId = "'+ CAST(ISNULL(D.intInventoryReceiptItemId,'') AS NVARCHAR) +'"} {intLoadDetailId = "' + CAST(ISNULL(D.intLoadDetailId,'') AS NVARCHAR) +'"}'
		, intActionId = 15
	FROM tblAPPaymentDetail A
	INNER JOIN @payVoucherDetailIds A2 ON A.intPaymentDetailId = A2.intId
	INNER JOIN tblAPPayment B ON A.intPaymentId = B.intPaymentId
	INNER JOIN tblAPBill C ON C.intBillId = A.intBillId
	INNER JOIN tblAPBillDetail D ON D.intBillId = C.intBillId
	CROSS APPLY (
		SELECT * FROM dbo.fnAPGetVoucherCommodity(C.intBillId)
	) commodity
	INNER JOIN tblICItemUOM iuom ON iuom.intItemUOMId = D.intUnitOfMeasureId
	INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = C.intCommodityId AND cum.intUnitMeasureId = iuom.intUnitMeasureId
	
	EXEC [dbo].[uspRKLogRiskPosition] @SummaryLogs = @rkSummaryLog, @Rebuild = 0

END