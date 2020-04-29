CREATE PROCEDURE [dbo].[uspAPReverseTransaction]
	@billId AS INT,
	@userId AS INT,
	@transactionType NVARCHAR(30) = NULL,
	@billCreatedId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @generatedBillRecordId NVARCHAR(50);
DECLARE @error NVARCHAR(200);

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

IF (SELECT intTransactionReversed FROM tblAPBill WHERE intBillId = @billId) > 0
BEGIN
	RAISERROR('Transaction already reversed.', 16, 1);
	RETURN;
END

IF (SELECT intTransactionType FROM tblAPBill WHERE intBillId = @billId) != 1
BEGIN
	RAISERROR('Voucher type is only a valid transaction for reversal.', 16, 1);
	RETURN;
END

SELECT * INTO #tmpDuplicateBill FROM tblAPBill WHERE intBillId = @billId
ALTER TABLE #tmpDuplicateBill DROP COLUMN intBillId

EXEC uspSMGetStartingNumber 18, @generatedBillRecordId OUT

UPDATE A
SET 
	A.strBillId = @generatedBillRecordId
	,A.intTransactionType = 3
	,A.intEntityId = @userId
	,A.dblDiscount = 0
	,A.dblPayment = 0
	,A.dblAmountDue = A.dblTotal
	,A.dtmDatePaid = NULL
	,A.ysnPaid = 0
	,A.intReversalId = @billId
FROM #tmpDuplicateBill A

INSERT INTO tblAPBill
SELECT * FROM #tmpDuplicateBill

SET @billCreatedId = SCOPE_IDENTITY();

IF OBJECT_ID('tempdb..#tmpVoucherDetailReversal') IS NOT NULL DROP TABLE #tmpVoucherDetailReversal

DECLARE @billDetailTaxes TABLE(intCreatedBillDetailId INT, originalBillDetailId INT)

SELECT * INTO #tmpVoucherDetailReversal FROM tblAPBillDetail WHERE intBillId = @billId ORDER BY intBillDetailId

UPDATE A
	SET A.intBillId = @billCreatedId
FROM #tmpVoucherDetailReversal A

MERGE INTO tblAPBillDetail
USING #tmpVoucherDetailReversal A
ON 1 = 0
	WHEN NOT MATCHED THEN
		INSERT
		VALUES
		(
			intBillId
			,strMiscDescription
			,strBundleDescription
			,strComment
			,intAccountId
			,intUnitOfMeasureId
			,intCostUOMId
			,intWeightUOMId
			,intBundletUOMId
			,intInvoiceDetailRefId
			,intItemId
			,intInventoryReceiptItemId
			,intDeferredVoucherId
			,intInventoryReceiptChargeId
			,intContractCostId
			,intPaycheckHeaderId
			,intPurchaseDetailId
			,intContractHeaderId
			,intContractDetailId
			,intCustomerStorageId
			,intSettleStorageId
			,intStorageLocationId
			,intSubLocationId
			,intLocationId
			,intLoadDetailId
			,intLoadShipmentCostId
			,intLoadId
			,intScaleTicketId
			,intTicketId
			,intCCSiteDetailId
			,intPrepayTypeId
			,intPrepayTransactionId
			,intReallocationId
			,intItemBundleId
			,dblTotal
			,dblBundleTotal
			,intConcurrencyId
			,dblQtyContract
			,dblContractCost
			,dblQtyOrdered
			,dblQtyReceived
			,dblQtyBundleReceived
			,dblDiscount
			,dblCost
			,dblOldCost
			,dblLandedCost
			,dblRate
			,dblTax
			,dblActual
			,dblBasis
			,dblFutures
			,dblDifference
			,dblPrepayPercentage
			,dblWeightUnitQty
			,dblCostUnitQty
			,dblUnitQty
			,dblBundleUnitQty
			,dblNetWeight
			,dblWeight
			,dblVolume
			,dblNetShippedWeight
			,dblWeightLoss
			,dblFranchiseWeight
			,dblFranchiseAmount
			,dblClaimAmount
			,dbl1099
			,dtmExpectedDate
			,int1099Form
			,int1099Category
			,ysn1099Printed
			,ysnRestricted
			,ysnSubCurrency
			,ysnStage
			,intLineNo
			,intTaxGroupId
			,intInventoryShipmentChargeId
			,intCurrencyExchangeRateTypeId
			,intCurrencyId
			,strBillOfLading
			,intContractSeq
			,intInvoiceId
			,intBuybackChargeId
		)
		OUTPUT inserted.intBillDetailId, A.intBillDetailId INTO @billDetailTaxes(intCreatedBillDetailId, originalBillDetailId); --get the new and old bill detail id

IF OBJECT_ID('tempdb..#tmpVoucherDetailDetailTaxes') IS NOT NULL DROP TABLE #tmpVoucherDetailDetailTaxes

SELECT A.* INTO #tmpVoucherDetailDetailTaxes 
FROM tblAPBillDetailTax A
INNER JOIN tblAPBillDetail B ON A.intBillDetailId = B.intBillDetailId
WHERE B.intBillId = @billId

ALTER TABLE #tmpVoucherDetailDetailTaxes DROP COLUMN intBillDetailTaxId

UPDATE A
SET A.intBillDetailId = B.intCreatedBillDetailId
FROM #tmpVoucherDetailDetailTaxes A
INNER JOIN @billDetailTaxes B ON A.intBillDetailId = B.originalBillDetailId

INSERT INTO tblAPBillDetailTax
SELECT * FROM #tmpVoucherDetailDetailTaxes

IF (SELECT ysnPosted FROM #tmpDuplicateBill) = 1
BEGIN
	DECLARE @billToPost NVARCHAR(50) = CAST(@billCreatedId AS NVARCHAR);
	DECLARE @postSuccess BIT = 0;
	DECLARE @batchIdUsed NVARCHAR(50);

	UPDATE A
	SET A.ysnPosted = 0
	FROM tblAPBill A
	WHERE A.intBillId = @billCreatedId

	EXEC uspAPPostBill 
		@post=1,
		@recap=0,
		@isBatch=0,
		@transactionType = @transactionType,
		@param=@billToPost,
		@userId=@userId,
		@batchIdUsed = @batchIdUsed OUTPUT,
		@success= @postSuccess OUTPUT

	IF @postSuccess = 0
	BEGIN
		DECLARE @postError NVARCHAR(200);
		SET @postError = (SELECT TOP 1 strMessage FROM tblAPPostResult WHERE intTransactionId = @billCreatedId AND strBatchNumber = @batchIdUsed)
		RAISERROR(@postError, 16, 1);
		RETURN;
	END
END

UPDATE A
SET A.intReversalId = @billCreatedId
FROM tblAPBill A
WHERE A.intBillId = @billId

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR(@error, 16, 1);
END CATCH
