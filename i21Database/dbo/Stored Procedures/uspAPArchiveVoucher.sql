CREATE PROCEDURE [dbo].[uspAPArchiveVoucher]
	@billId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @hasVoidedPayment BIT;
DECLARE @posted BIT;
IF @transCount = 0 BEGIN TRANSACTION

SELECT
	@posted = A.ysnPosted, @hasVoidedPayment = ISNULL(latestPayment.ysnVoid,0)
FROM tblAPBill A
OUTER APPLY (
	SELECT TOP 1
		ISNULL(H.ysnCheckVoid,0) AS ysnVoid,
		C.intBillId
	FROM dbo.tblAPPayment B 
		LEFT JOIN dbo.tblAPPaymentDetail C ON B.intPaymentId = C.intPaymentId
	LEFT JOIN dbo.tblCMBankAccount G ON B.intBankAccountId = G.intBankAccountId
	LEFT JOIN dbo.tblCMBankTransaction H ON B.strPaymentRecordNum = H.strTransactionId
	WHERE C.intOrigBillId = A.intBillId
	ORDER BY B.dtmDatePaid DESC
) latestPayment
WHERE A.intBillId = @billId;

IF (@posted = 0 AND @hasVoidedPayment = 1)
BEGIN

MERGE INTO tblAPBillArchive AS destination
USING
(
	SELECT
		A.intBillId
		,A.intBillBatchId
		,A.strVendorOrderNumber
		,A.intTermsId
		,A.intTransactionReversed
		,A.intCommodityId
		,A.intCompanyId
		,A.intBankInfoId
		,A.intBookId
		,A.intSubBookId
		,A.ysnPrepayHasPayment
		,A.dtmDate
		,A.dtmDueDate
		,A.intAccountId
		,A.strReference
		,A.strTempPaymentInfo
		,A.strApprovalNotes
		,A.strRemarks
		,A.strComment
		,A.dblTotal
		,A.dblTotalController
		,A.dbl1099
		,A.dblSubtotal
		,A.ysnPosted
		,A.ysnPaid
		,A.strBillId
		,A.dblAmountDue
		,A.dtmDatePaid
		,A.dtmApprovalDate
		,A.dtmDiscountDate
		,A.dtmDeferredInterestDate
		,A.dtmInterestAccruedThru
		,A.intUserId
		,A.intConcurrencyId
		,A.dtmBillDate
		,A.intEntityId
		,A.intEntityVendorId
		,A.intShipFromEntityId
		,A.dblWithheld
		,A.dblTempWithheld
		,A.dblDiscount
		,A.dblTempDiscount
		,A.dblTax
		,A.dblPayment
		,A.dblTempPayment
		,A.dblInterest
		,A.dblTempInterest
		,A.intTransactionType
		,A.intPurchaseOrderId
		,A.strPONumber
		,A.strShipToAttention
		,A.strShipToAddress
		,A.strShipToCity
		,A.strShipToState
		,A.strShipToZipCode
		,A.strShipToCountry
		,A.strShipToPhone
		,A.strShipFromAttention
		,A.strShipFromAddress
		,A.strShipFromCity
		,A.strShipFromState
		,A.strShipFromZipCode
		,A.strShipFromCountry
		,A.strShipFromPhone
		,A.intShipFromId
		,A.intDeferredVoucherId
		,A.intPayToAddressId
		,A.intVoucherDifference
		,A.intShipToId
		,A.intShipViaId
		,A.intStoreLocationId
		,A.intContactId
		,A.intOrderById
		,A.intCurrencyId
		,A.intSubCurrencyCents
		,A.ysnApproved
		,A.ysnForApproval
		,A.ysnOrigin
		,A.ysnDeleted
		,A.ysnIsPaymentScheduled
		,A.ysnDiscountOverride
		,A.ysnReadyForPayment
		,A.ysnRecurring
		,A.ysnExported
		,A.ysnForApprovalSubmitted
		,A.ysnOldPrepayment
		--IF DATE OF VOUCHER IS GREATER THAN THE CURRENT DATE, USE SAME DATE WITH VOUCHER
		--CURRENT DATE CANNOT BET LESS THAN THE DATE OF VOUCHER
		--THIS ARCHIVE ONLY OCCURS IF THERE IS VOIDED PAYMENT
		,LP.dtmDateDeleted
		,A.dtmExportedDate
		,A.dtmDateCreated
		,CASE WHEN GETDATE() < A.dtmDate THEN A.dtmDate ELSE GETDATE() END AS dtmOrigDateDeleted
	FROM tblAPBill A
	OUTER APPLY (
		SELECT TOP 1 MAX(P.dtmDatePaid) AS dtmDateDeleted
		FROM tblAPPayment P
		LEFT JOIN tblAPPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
		WHERE PD.intOrigBillId = A.intBillId
	) LP
	WHERE A.intBillId = @billId
)
AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	intBillId
	,intBillBatchId
	,strVendorOrderNumber
	,intTermsId
	,intTransactionReversed
	,intCommodityId
	,intCompanyId
	,intBankInfoId
	,intBookId
	,intSubBookId
	,ysnPrepayHasPayment
	,dtmDate
	,dtmDueDate
	,intAccountId
	,strReference
	,strTempPaymentInfo
	,strApprovalNotes
	,strRemarks
	,strComment
	,dblTotal
	,dblTotalController
	,dbl1099
	,dblSubtotal
	,ysnPosted
	,ysnPaid
	,strBillId
	,dblAmountDue
	,dtmDatePaid
	,dtmApprovalDate
	,dtmDiscountDate
	,dtmDeferredInterestDate
	,dtmInterestAccruedThru
	,intUserId
	,intConcurrencyId
	,dtmBillDate
	,intEntityId
	,intEntityVendorId
	,intShipFromEntityId
	,dblWithheld
	,dblTempWithheld
	,dblDiscount
	,dblTempDiscount
	,dblTax
	,dblPayment
	,dblTempPayment
	,dblInterest
	,dblTempInterest
	,intTransactionType
	,intPurchaseOrderId
	,strPONumber
	,strShipToAttention
	,strShipToAddress
	,strShipToCity
	,strShipToState
	,strShipToZipCode
	,strShipToCountry
	,strShipToPhone
	,strShipFromAttention
	,strShipFromAddress
	,strShipFromCity
	,strShipFromState
	,strShipFromZipCode
	,strShipFromCountry
	,strShipFromPhone
	,intShipFromId
	,intDeferredVoucherId
	,intPayToAddressId
	,intVoucherDifference
	,intShipToId
	,intShipViaId
	,intStoreLocationId
	,intContactId
	,intOrderById
	,intCurrencyId
	,intSubCurrencyCents
	,ysnApproved
	,ysnForApproval
	,ysnOrigin
	,ysnDeleted
	,ysnIsPaymentScheduled
	,ysnDiscountOverride
	,ysnReadyForPayment
	,ysnRecurring
	,ysnExported
	,ysnForApprovalSubmitted
	,ysnOldPrepayment
	,dtmDateDeleted
	,dtmExportedDate
	,dtmDateCreated
	,dtmOrigDateDeleted
)
VALUES
(
	SourceData.intBillId
	,SourceData.intBillBatchId
	,SourceData.strVendorOrderNumber
	,SourceData.intTermsId
	,SourceData.intTransactionReversed
	,SourceData.intCommodityId
	,SourceData.intCompanyId
	,SourceData.intBankInfoId
	,SourceData.intBookId
	,SourceData.intSubBookId
	,SourceData.ysnPrepayHasPayment
	,SourceData.dtmDate
	,SourceData.dtmDueDate
	,SourceData.intAccountId
	,SourceData.strReference
	,SourceData.strTempPaymentInfo
	,SourceData.strApprovalNotes
	,SourceData.strRemarks
	,SourceData.strComment
	,SourceData.dblTotal
	,SourceData.dblTotalController
	,SourceData.dbl1099
	,SourceData.dblSubtotal
	,SourceData.ysnPosted
	,SourceData.ysnPaid
	,SourceData.strBillId
	,SourceData.dblAmountDue
	,SourceData.dtmDatePaid
	,SourceData.dtmApprovalDate
	,SourceData.dtmDiscountDate
	,SourceData.dtmDeferredInterestDate
	,SourceData.dtmInterestAccruedThru
	,SourceData.intUserId
	,SourceData.intConcurrencyId
	,SourceData.dtmBillDate
	,SourceData.intEntityId
	,SourceData.intEntityVendorId
	,SourceData.intShipFromEntityId
	,SourceData.dblWithheld
	,SourceData.dblTempWithheld
	,SourceData.dblDiscount
	,SourceData.dblTempDiscount
	,SourceData.dblTax
	,SourceData.dblPayment
	,SourceData.dblTempPayment
	,SourceData.dblInterest
	,SourceData.dblTempInterest
	,SourceData.intTransactionType
	,SourceData.intPurchaseOrderId
	,SourceData.strPONumber
	,SourceData.strShipToAttention
	,SourceData.strShipToAddress
	,SourceData.strShipToCity
	,SourceData.strShipToState
	,SourceData.strShipToZipCode
	,SourceData.strShipToCountry
	,SourceData.strShipToPhone
	,SourceData.strShipFromAttention
	,SourceData.strShipFromAddress
	,SourceData.strShipFromCity
	,SourceData.strShipFromState
	,SourceData.strShipFromZipCode
	,SourceData.strShipFromCountry
	,SourceData.strShipFromPhone
	,SourceData.intShipFromId
	,SourceData.intDeferredVoucherId
	,SourceData.intPayToAddressId
	,SourceData.intVoucherDifference
	,SourceData.intShipToId
	,SourceData.intShipViaId
	,SourceData.intStoreLocationId
	,SourceData.intContactId
	,SourceData.intOrderById
	,SourceData.intCurrencyId
	,SourceData.intSubCurrencyCents
	,SourceData.ysnApproved
	,SourceData.ysnForApproval
	,SourceData.ysnOrigin
	,SourceData.ysnDeleted
	,SourceData.ysnIsPaymentScheduled
	,SourceData.ysnDiscountOverride
	,SourceData.ysnReadyForPayment
	,SourceData.ysnRecurring
	,SourceData.ysnExported
	,SourceData.ysnForApprovalSubmitted
	,SourceData.ysnOldPrepayment
	,SourceData.dtmDateDeleted
	,SourceData.dtmExportedDate
	,SourceData.dtmDateCreated
	,SourceData.dtmOrigDateDeleted
);

MERGE INTO tblAPBillDetailArchive AS destination
USING
(
	SELECT
		A.intBillDetailId
		,A.intBillId
		,A.strMiscDescription
		,A.strBundleDescription
		,A.strComment
		,A.intAccountId
		,A.intUnitOfMeasureId
		,A.intCostUOMId
		,A.intWeightUOMId
		,A.intBundletUOMId
		,A.intItemId
		,A.intInventoryReceiptItemId
		,A.intDeferredVoucherId
		,A.intInventoryReceiptChargeId
		,A.intContractCostId
		,A.intPaycheckHeaderId
		,A.intPurchaseDetailId
		,A.intContractHeaderId
		,A.intContractDetailId
		,A.intCustomerStorageId
		,A.intStorageLocationId
		,A.intSubLocationId
		,A.intLocationId
		,A.intLoadDetailId
		,A.intLoadShipmentCostId
		,A.intLoadId
		,A.intScaleTicketId
		,A.intCCSiteDetailId
		,A.intPrepayTypeId
		,A.intPrepayTransactionId
		,A.intItemBundleId
		,A.dblTotal
		,A.dblBundleTotal
		,A.intConcurrencyId
		,A.dblQtyContract
		,A.dblContractCost
		,A.dblQtyOrdered
		,A.dblQtyReceived
		,A.dblQtyBundleReceived
		,A.dblDiscount
		,A.dblCost
		,A.dblOldCost
		,A.dblLandedCost
		,A.dblRate
		,A.dblTax
		,A.dblActual
		,A.dblBasis
		,A.dblFutures
		,A.dblDifference
		,A.dblPrepayPercentage
		,A.dblWeightUnitQty
		,A.dblCostUnitQty
		,A.dblUnitQty
		,A.dblBundleUnitQty
		,A.dblNetWeight
		,A.dblWeight
		,A.dblVolume
		,A.dblNetShippedWeight
		,A.dblWeightLoss
		,A.dblFranchiseWeight
		,A.dblFranchiseAmount
		,A.dblClaimAmount
		,A.dbl1099
		,A.dtmExpectedDate
		,A.int1099Form
		,A.int1099Category
		,A.ysn1099Printed
		,A.ysnRestricted
		,A.ysnSubCurrency
		,A.ysnStage
		,A.intLineNo
		,A.intTaxGroupId
		,A.intInventoryShipmentChargeId
		,A.intCurrencyExchangeRateTypeId
		,A.intCurrencyId
		,A.strBillOfLading
		,A.intContractSeq
		,A.intInvoiceId
		,A.intBuybackChargeId
	FROM tblAPBillDetail A
	WHERE A.intBillId = @billId
)
AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	intBillDetailId
	,intBillId
	,strMiscDescription
	,strBundleDescription
	,strComment
	,intAccountId
	,intUnitOfMeasureId
	,intCostUOMId
	,intWeightUOMId
	,intBundletUOMId
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
	,intStorageLocationId
	,intSubLocationId
	,intLocationId
	,intLoadDetailId
	,intLoadShipmentCostId
	,intLoadId
	,intScaleTicketId
	,intCCSiteDetailId
	,intPrepayTypeId
	,intPrepayTransactionId
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
VALUES
(
	SourceData.intBillDetailId
	,SourceData.intBillId
	,SourceData.strMiscDescription
	,SourceData.strBundleDescription
	,SourceData.strComment
	,SourceData.intAccountId
	,SourceData.intUnitOfMeasureId
	,SourceData.intCostUOMId
	,SourceData.intWeightUOMId
	,SourceData.intBundletUOMId
	,SourceData.intItemId
	,SourceData.intInventoryReceiptItemId
	,SourceData.intDeferredVoucherId
	,SourceData.intInventoryReceiptChargeId
	,SourceData.intContractCostId
	,SourceData.intPaycheckHeaderId
	,SourceData.intPurchaseDetailId
	,SourceData.intContractHeaderId
	,SourceData.intContractDetailId
	,SourceData.intCustomerStorageId
	,SourceData.intStorageLocationId
	,SourceData.intSubLocationId
	,SourceData.intLocationId
	,SourceData.intLoadDetailId
	,SourceData.intLoadShipmentCostId
	,SourceData.intLoadId
	,SourceData.intScaleTicketId
	,SourceData.intCCSiteDetailId
	,SourceData.intPrepayTypeId
	,SourceData.intPrepayTransactionId
	,SourceData.intItemBundleId
	,SourceData.dblTotal
	,SourceData.dblBundleTotal
	,SourceData.intConcurrencyId
	,SourceData.dblQtyContract
	,SourceData.dblContractCost
	,SourceData.dblQtyOrdered
	,SourceData.dblQtyReceived
	,SourceData.dblQtyBundleReceived
	,SourceData.dblDiscount
	,SourceData.dblCost
	,SourceData.dblOldCost
	,SourceData.dblLandedCost
	,SourceData.dblRate
	,SourceData.dblTax
	,SourceData.dblActual
	,SourceData.dblBasis
	,SourceData.dblFutures
	,SourceData.dblDifference
	,SourceData.dblPrepayPercentage
	,SourceData.dblWeightUnitQty
	,SourceData.dblCostUnitQty
	,SourceData.dblUnitQty
	,SourceData.dblBundleUnitQty
	,SourceData.dblNetWeight
	,SourceData.dblWeight
	,SourceData.dblVolume
	,SourceData.dblNetShippedWeight
	,SourceData.dblWeightLoss
	,SourceData.dblFranchiseWeight
	,SourceData.dblFranchiseAmount
	,SourceData.dblClaimAmount
	,SourceData.dbl1099
	,SourceData.dtmExpectedDate
	,SourceData.int1099Form
	,SourceData.int1099Category
	,SourceData.ysn1099Printed
	,SourceData.ysnRestricted
	,SourceData.ysnSubCurrency
	,SourceData.ysnStage
	,SourceData.intLineNo
	,SourceData.intTaxGroupId
	,SourceData.intInventoryShipmentChargeId
	,SourceData.intCurrencyExchangeRateTypeId
	,SourceData.intCurrencyId
	,SourceData.strBillOfLading
	,SourceData.intContractSeq
	,SourceData.intInvoiceId
	,SourceData.intBuybackChargeId
);

MERGE INTO tblAPBillDetailTaxArchive AS destination
USING
(
	SELECT
		A.intBillDetailTaxId
		,A.intBillDetailId
		,A.intTaxGroupMasterId
		,A.intTaxGroupId
		,A.intTaxCodeId
		,A.intTaxClassId
		,A.strTaxableByOtherTaxes
		,A.strCalculationMethod
		,A.dblRate
		,A.intAccountId
		,A.dblTax
		,A.dblAdjustedTax
		,A.ysnTaxAdjusted
		,A.ysnSeparateOnBill
		,A.ysnCheckOffTax
		,A.intConcurrencyId
		,A.ysnTaxExempt
		,A.ysnTaxOnly
	FROM tblAPBillDetailTax A
	WHERE A.intBillDetailId IN (SELECT B.intBillDetailId FROM tblAPBillDetail B WHERE B.intBillId = @billId)
)
AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	intBillDetailTaxId
	,intBillDetailId
	,intTaxGroupMasterId
	,intTaxGroupId
	,intTaxCodeId
	,intTaxClassId
	,strTaxableByOtherTaxes
	,strCalculationMethod
	,dblRate
	,intAccountId
	,dblTax
	,dblAdjustedTax
	,ysnTaxAdjusted
	,ysnSeparateOnBill
	,ysnCheckOffTax
	,intConcurrencyId
	,ysnTaxExempt
	,ysnTaxOnly	
)
VALUES
(
	SourceData.intBillDetailTaxId
	,SourceData.intBillDetailId
	,SourceData.intTaxGroupMasterId
	,SourceData.intTaxGroupId
	,SourceData.intTaxCodeId
	,SourceData.intTaxClassId
	,SourceData.strTaxableByOtherTaxes
	,SourceData.strCalculationMethod
	,SourceData.dblRate
	,SourceData.intAccountId
	,SourceData.dblTax
	,SourceData.dblAdjustedTax
	,SourceData.ysnTaxAdjusted
	,SourceData.ysnSeparateOnBill
	,SourceData.ysnCheckOffTax
	,SourceData.intConcurrencyId
	,SourceData.ysnTaxExempt
	,SourceData.ysnTaxOnly	
);

END

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
    SET @ErrorProc     = ERROR_PROCEDURE()
    SET @ErrorMessage  = 'Problem duplicating bill.' + CHAR(13) + 
			'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
			' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
    -- Not all errors generate an error state, to set to 1 if it's zero
    IF @ErrorState  = 0
    SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
    RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH