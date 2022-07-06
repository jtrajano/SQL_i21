CREATE PROCEDURE dbo.uspLGProcessTradeFinanceAllocation
	@intAllocationHeaderId AS INT,
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
    )
    SELECT
        strAction = 'Allocated Contract'
        , strTransactionType = 'Logistics'
        , intTradeFinanceTransactionId = tf.intTradeFinanceId
        , strTradeFinanceTransaction = tf.strTradeFinanceNumber
        , intTransactionHeaderId = ah.intAllocationHeaderId
        , intTransactionDetailId = ad.intAllocationDetailId
        , strTransactionNumber = ah.strAllocationNumber
        , dtmTransactionDate = getdate()
        , intBankTransactionId = null
        , strBankTransactionId = null
        , dblTransactionAmountAllocated = cd.dblLoanAmount
        , dblTransactionAmountActual = cd.dblLoanAmount
        , intLoanLimitId = cd.intLoanLimitId
        , strLoanLimitNumber = bl.strBankLoanId
        , strLoanLimitType = bl.strLimitDescription
        , dtmAppliedToTransactionDate = getdate()
        , intStatusId = case when cd.intContractStatusId = 5 then 2 else 1 end
        , intWarrantId = null
        , strWarrantId = null
        , intUserId = @intUserSecurityId
        , intConcurrencyId = 1
        , intContractHeaderId = cd.intContractHeaderId
        , intContractDetailId = cd.intContractDetailId
        , intBankId = cd.intBankId
        , intBankAccountId = cd.intBankAccountId
        , intBorrowingFacilityId = cd.intBorrowingFacilityId
        , intLimitId = cd.intBorrowingFacilityLimitId
        , intSublimitId = cd.intBorrowingFacilityLimitDetailId
        , strBankTradeReference = cd.strReferenceNo
        , strBankApprovalStatus = STF.strApprovalStatus
        , dblLimit = limit.dblLimit
        , dblSublimit = sublimit.dblLimit
        , dblFinanceQty = SUM(ad.dblPAllocatedQty)
        , dblFinancedAmount = SUM((cd.dblTotalCost / cd.dblQuantity) * (ad.dblPAllocatedQty)
                            * (case when cd.intCurrencyId <> cd.intInvoiceCurrencyId and isnull(cd.dblRate,0) <> 0 then cd.dblRate else 1 end))
        , strBorrowingFacilityBankRefNo = cd.strBankReferenceNo
        , ysnDeleted = @ysnDeleted
    FROM
        tblLGAllocationHeader ah
        JOIN tblLGAllocationDetail ad ON ad.intAllocationHeaderId = ah.intAllocationHeaderId
        JOIN tblCTContractDetail cd ON cd.intContractDetailId = ad.intPContractDetailId
        JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
        JOIN tblTRFTradeFinance tf ON tf.strTradeFinanceNumber = (cd.strFinanceTradeNo COLLATE Latin1_General_CI_AS) and tf.strTransactionType = 'Contract'
        LEFT JOIN tblCMBankLoan bl ON bl.intBankLoanId = cd.intLoanLimitId
        LEFT JOIN tblCTApprovalStatusTF STF ON STF.intApprovalStatusId = cd.intApprovalStatusId
        LEFT JOIN tblCMBorrowingFacilityLimit limit ON limit.intBorrowingFacilityLimitId = cd.intBorrowingFacilityLimitId
        LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit ON sublimit.intBorrowingFacilityLimitDetailId = cd.intBorrowingFacilityLimitDetailId
    WHERE
        ah.intAllocationHeaderId = @intAllocationHeaderId
    GROUP BY
        tf.intTradeFinanceId
        ,tf.strTradeFinanceNumber
        ,ah.intAllocationHeaderId
        ,ad.intAllocationDetailId
        ,ah.strAllocationNumber
        ,cd.dblLoanAmount
        ,cd.dblLoanAmount
        ,cd.intLoanLimitId
        ,bl.strBankLoanId
        ,bl.strLimitDescription
        ,cd.intContractStatusId
        ,cd.intContractHeaderId
        ,cd.intContractDetailId
        ,cd.intBankId
        ,cd.intBankAccountId
        ,cd.intBorrowingFacilityId
        ,cd.intBorrowingFacilityLimitId
        ,cd.intBorrowingFacilityLimitDetailId
        ,cd.strReferenceNo
        ,STF.strApprovalStatus
        ,limit.dblLimit
        ,sublimit.dblLimit
        ,cd.intCurrencyId
        ,cd.intInvoiceCurrencyId
        ,cd.dblRate
        ,cd.strBankReferenceNo

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