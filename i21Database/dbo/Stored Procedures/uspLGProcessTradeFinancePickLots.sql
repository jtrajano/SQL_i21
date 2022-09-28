CREATE PROCEDURE dbo.uspLGProcessTradeFinancePickLots
	@intPickLotHeaderId AS INT,
    @intUserSecurityId AS INT,
    @ysnDeleted AS BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

    DECLARE @TRFLog TRFLog

    INSERT INTO @TRFLog (
        strAction
        , strTransactionType
        , intTradeFinanceTransactionId
        , strTradeFinanceTransaction
        , intTransactionHeaderId
        , intTransactionDetailId
        , strTransactionNumber
        , dtmTransactionDate
        , intBankTransactionId
        , strBankTransactionId
        , dblTransactionAmountAllocated
        , dblTransactionAmountActual
        , intLoanLimitId
        , strLoanLimitNumber
        , strLoanLimitType
        , dtmAppliedToTransactionDate
        , intStatusId
        , intWarrantId
        , strWarrantId
        , intUserId
        , intConcurrencyId
        , intContractHeaderId
        , intContractDetailId
        , intBankId
        , intBankAccountId
        , intBorrowingFacilityId
        , intLimitId
        , intSublimitId
        , strBankTradeReference
        , strBankApprovalStatus
        , dblLimit
        , dblSublimit
        , dblFinanceQty
        , dblFinancedAmount
        , strBorrowingFacilityBankRefNo
        , ysnDeleted
        , intOverrideBankValuationId
    )
 SELECT
        strAction = 'Created Pick Lot'
        , strTransactionType = 'Logistics'
        , intTradeFinanceTransactionId = tf.intTradeFinanceId
        , strTradeFinanceTransaction = tf.strTradeFinanceNumber
        , intTransactionHeaderId = PLD.intPickLotHeaderId
        , intTransactionDetailId = PLD.intPickLotDetailId
        , strTransactionNumber = PLH.strPickLotNumber
        , dtmTransactionDate = getdate()
        , intBankTransactionId = null
        , strBankTransactionId = null
        , dblTransactionAmountAllocated = cd.dblLoanAmount
        , dblTransactionAmountActual = cd.dblLoanAmount
        , intLoanLimitId = cd.intLoanLimitId
        , strLoanLimitNumber = bl.strBankLoanId
        , strLoanLimitType = bl.strLimitDescription
        , dtmAppliedToTransactionDate = getdate()
        , intStatusId = 1
        , intWarrantId = null
        , strWarrantId = null
        , intUserId = @intUserSecurityId
        , intConcurrencyId = 1
        , intContractHeaderId = cd.intContractHeaderId
        , intContractDetailId = cd.intContractDetailId
        , intBankId = IC.intBankId
        , intBankAccountId = IC.intBankAccountId
        , intBorrowingFacilityId = IC.intBorrowingFacilityId
        , intLimitId = CFL.intBorrowingFacilityLimitId
        , intSublimitId = IC.intSublimitTypeId
        , strBankTradeReference = IC.strReferenceNo
        , strBankApprovalStatus = IC.strApprovalStatus
        , dblLimit = limit.dblLimit
        , dblSublimit = sublimit.dblLimit
        , dblFinanceQty = PLD.dblLotPickedQty
        , dblFinancedAmount = (cd.dblTotalCost / cd.dblQuantity) * (PLD.dblLotPickedQty)
                            * (case when cd.intCurrencyId <> cd.intInvoiceCurrencyId and isnull(cd.dblRate,0) <> 0 then cd.dblRate else 1 end)
        , strBorrowingFacilityBankRefNo = IC.strBankReferenceNo
        , ysnDeleted = @ysnDeleted
        , intOverrideBankValuationId = tf.intOverrideFacilityValuation
    FROM
        tblLGPickLotHeader PLH
        JOIN tblLGPickLotDetail PLD ON PLD.intPickLotHeaderId = PLH.intPickLotHeaderId
        JOIN tblLGAllocationDetail ad ON ad.intAllocationDetailId = PLD.intAllocationDetailId
        JOIN tblCTContractDetail cd ON cd.intContractDetailId = ad.intPContractDetailId
        JOIN tblTRFTradeFinance tf ON tf.strTradeFinanceNumber = (cd.strFinanceTradeNo COLLATE Latin1_General_CI_AS) and tf.strTransactionType = 'Inventory'
        LEFT JOIN tblCMBankLoan bl ON bl.intBankLoanId = cd.intLoanLimitId
        LEFT JOIN tblCTApprovalStatusTF STF ON STF.intApprovalStatusId = cd.intApprovalStatusId
        LEFT JOIN tblCMBorrowingFacilityLimit limit ON limit.intBorrowingFacilityLimitId = cd.intBorrowingFacilityLimitId
        LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit ON sublimit.intBorrowingFacilityLimitDetailId = cd.intBorrowingFacilityLimitDetailId
        LEFT JOIN tblICInventoryReceipt IC ON IC.intInventoryReceiptId = tf.intTransactionHeaderId
        LEFT JOIN tblCMBorrowingFacilityLimit CFL ON CFL.intBorrowingFacilityId =
                    CASE WHEN ISNULL(IC.strReceiptNumber, '') <> '' THEN IC.intBorrowingFacilityId ELSE cd.intBorrowingFacilityId END 
                    AND CFL.strBorrowingFacilityLimit = 'Logistics'
    WHERE PLH.intPickLotHeaderId = @intPickLotHeaderId

    -- Log Trade Finance
    IF EXISTS(SELECT 1 FROM @TRFLog)
    BEGIN
        EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog
    END

END TRY

BEGIN CATCH
    DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
END CATCH