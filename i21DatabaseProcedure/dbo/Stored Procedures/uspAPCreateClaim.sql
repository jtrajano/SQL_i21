/*
	Claim should have the following.
	1. Receiving of items were already completed.
	2. Voucher already posted.
	3. Prepayment has been applied fully
*/
CREATE PROCEDURE [dbo].[uspAPCreateClaim]
	@billId INT,
	@userId INT,
	@claimCreated INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @voucherDetailClaim AS VoucherDetailClaim;
DECLARE @voucherId INT, @shipTo INT, @vendorId INT;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

IF OBJECT_ID('tempdb..#tmpClaimData') IS NOT NULL DROP TABLE #tmpClaimData

SELECT 
* 
INTO #tmpClaimData
FROM (
	SELECT
		SUM(dblNetQtyReceived) AS dblNetQtyReceived,
		SUM(dblAppliedPrepayment) AS dblAppliedPrepayment,
		SUM(dblNetShippedWeight) AS dblNetShippedWeight,
		SUM(dblQtyBillCreated) AS dblQtyBillCreated,
		dblFranchiseWeight,
		dblCost,
		dblQtyReceived,
		intCostUOMId,
		intWeightUOMId,
		strItemNo,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		dblAmountPaid,
		dblContractItemQty,
		intEntityVendorId,
		intShipToId,
		dblWeightLoss,
		dblClaim,
		dblPrepaidTotal
	FROM (
		SELECT 
			Loads.dblNetShippedWeight
			,Receipts.dblNetQtyReceived
			,J.dblAmountApplied AS dblAppliedPrepayment
			,CASE 
				WHEN I.dblFranchise > 0
					THEN E.dblQuantity * (I.dblFranchise / 100)
				ELSE 0
				END AS dblFranchiseWeight
			,B.dblCost
			,B.dblQtyReceived
			,B.dblQtyOrdered AS dblQtyBillCreated
			,B.intCostUOMId
			,B.intWeightUOMId
			,G.strItemNo
			,G.intItemId
			,E.intContractDetailId
			,E.intContractHeaderId
			,E.intContractSeq
			,E.dblTotalCost AS dblAmountPaid
			,E.dblQuantity AS dblContractItemQty
			,H.strContractNumber
			,A.intEntityVendorId
			,A.intShipToId
			,0 AS dblWeightLoss
			,0 AS dblClaim
			,L.dblTotal + L.dblTax AS dblPrepaidTotal
		FROM tblAPBill A
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN tblICInventoryReceiptItem C2 ON B.intInventoryReceiptItemId = C2.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt D ON C2.intInventoryReceiptId = D.intInventoryReceiptId
		INNER JOIN tblCTContractDetail E ON C2.intLineNo = E.intContractDetailId
		INNER JOIN tblCTContractHeader H ON H.intContractHeaderId = E.intContractHeaderId
		INNER JOIN tblCTWeightGrade I ON H.intWeightId = I.intWeightGradeId
		INNER JOIN tblICItem G ON B.intItemId = G.intItemId
		INNER JOIN tblAPAppliedPrepaidAndDebit J ON J.intContractHeaderId = E.intContractHeaderId AND B.intBillDetailId = J.intBillDetailApplied
		INNER JOIN tblAPBill K ON J.intTransactionId = K.intBillId
		INNER JOIN tblAPBillDetail L ON K.intBillId = L.intBillId 
					AND B.intItemId = L.intItemId 
					AND E.intContractDetailId = L.intContractDetailId
					AND E.intContractHeaderId = L.intContractHeaderId
		CROSS APPLY (
			SELECT SUM(F.dblGross) AS dblNetShippedWeight
			FROM tblLGLoadDetail F
			WHERE C2.intSourceId = F.intLoadDetailId
			) Loads
		CROSS APPLY (
			SELECT 
				SUM(C.dblNet) AS dblNetQtyReceived
			FROM tblICInventoryReceiptItem C 
			WHERE C.intLineNo = C2.intLineNo AND C.intOrderId = C2.intOrderId AND B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
		) Receipts
		WHERE A.ysnPosted = 1 
		AND D.intSourceType = 2 --Inbound Shipment
		AND E.intContractStatusId = 5
	) tmpClaim
	GROUP BY dblFranchiseWeight,
		dblCost,
		dblQtyReceived,
		intCostUOMId,
		intWeightUOMId,
		strItemNo,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		dblContractItemQty,
		dblAmountPaid,
		intEntityVendorId,
		intShipToId,
		dblWeightLoss,
		dblClaim,
		dblPrepaidTotal
) Claim
WHERE dblQtyBillCreated = dblContractItemQty --make sure we fully billed the contract item

SELECT
	@vendorId = A.intEntityVendorId,
	@shipTo = A.intShipToId
FROM #tmpClaimData A

INSERT INTO @voucherDetailClaim(
	dblNetShippedWeight	,
	dblWeightLoss		,
	dblFranchiseWeight	,
	dblClaim			,
	dblCost				,
	intItemId			,
	intContractHeaderId ,
	intContractDetailId 
)
SELECT
	dblNetShippedWeight	=	A.dblNetShippedWeight,
	dblWeightLoss		=	A.dblWeightLoss,
	dblFranchiseWeight	=	A.dblFranchiseWeight,
	dblClaim			=	A.dblClaim,
	dblCost				=	A.dblCost,
	intItemId			=	A.intItemId,
	intContractHeaderId =	A.intContractHeaderId,
	intContractDetailId =	A.intContractDetailId
FROM #tmpClaimData A

EXEC uspAPCreateBillData @userId = @userId,
		@type = 11,
		@vendorId = @vendorId,
		@voucherDetailClaim = @voucherDetailClaim, 
		@shipTo = @shipTo, 
		@billId = @voucherId OUTPUT

SET @claimCreated = @voucherId;

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH