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
        , intOverrideBankValuationId
    )
    SELECT TOP 1
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
        , intBankId = CASE WHEN ISNULL(IC.strReceiptNumber, '') <> '' THEN IC.intBankId ELSE cd.intBankId END
        , intBankAccountId = CASE WHEN ISNULL(IC.strReceiptNumber, '') <> '' THEN IC.intBankAccountId ELSE cd.intBankAccountId END
        , intBorrowingFacilityId = CASE WHEN ISNULL(IC.strReceiptNumber, '') <> '' THEN IC.intBorrowingFacilityId ELSE cd.intBorrowingFacilityId END
        , intLimitId = CFL.intBorrowingFacilityLimitId
        , intSublimitId = CASE WHEN ISNULL(IC.strReceiptNumber, '') <> '' THEN IC.intSublimitTypeId ELSE cd.intBorrowingFacilityLimitDetailId END
        , strBankTradeReference = CASE WHEN ISNULL(IC.strReceiptNumber, '') <> '' THEN IC.strReferenceNo ELSE cd.strReferenceNo END
        , strBankApprovalStatus = CASE WHEN ISNULL(IC.strReceiptNumber, '') <> '' THEN IC.strApprovalStatus ELSE STF.strApprovalStatus END
        , dblLimit = limit.dblLimit
        , dblSublimit = sublimit.dblLimit
        , dblFinanceQty = SUM(ad.dblPAllocatedQty)
        , dblFinancedAmount = SUM((cd.dblTotalCost / cd.dblQuantity) * (ad.dblPAllocatedQty)
                            * (case when cd.intCurrencyId <> cd.intInvoiceCurrencyId and isnull(cd.dblRate,0) <> 0 then cd.dblRate else 1 end))
        , strBorrowingFacilityBankRefNo = CASE WHEN ISNULL(IC.strReceiptNumber, '') <> '' THEN IC.strBankReferenceNo ELSE cd.strBankReferenceNo END 
        , ysnDeleted = @ysnDeleted
        , intOverrideBankValuationId = cd.intBankValuationRuleId
    FROM
        tblLGAllocationHeader ah
        JOIN tblLGAllocationDetail ad ON ad.intAllocationHeaderId = ah.intAllocationHeaderId
        JOIN tblCTContractDetail cd ON cd.intContractDetailId = ad.intPContractDetailId
        JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
        JOIN tblTRFTradeFinance tf ON tf.strTradeFinanceNumber = (cd.strFinanceTradeNo COLLATE Latin1_General_CI_AS) and (tf.strTransactionType = 'Contract' or tf.strTransactionType = 'Inventory')
        LEFT JOIN tblCMBankLoan bl ON bl.intBankLoanId = cd.intLoanLimitId
        LEFT JOIN tblCTApprovalStatusTF STF ON STF.intApprovalStatusId = cd.intApprovalStatusId
        LEFT JOIN tblCMBorrowingFacilityLimit limit ON limit.intBorrowingFacilityLimitId = cd.intBorrowingFacilityLimitId
        LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit ON sublimit.intBorrowingFacilityLimitDetailId = cd.intBorrowingFacilityLimitDetailId
        LEFT JOIN tblICInventoryReceipt IC ON IC.intInventoryReceiptId = tf.intTransactionHeaderId
        LEFT JOIN tblCMBorrowingFacilityLimit CFL ON CFL.intBorrowingFacilityId =
                    CASE WHEN ISNULL(IC.strReceiptNumber, '') <> '' THEN IC.intBorrowingFacilityId ELSE cd.intBorrowingFacilityId END 
                    AND CFL.strBorrowingFacilityLimit = 'Logistics'
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
        ,cd.intBankValuationRuleId
        ,IC.strApprovalStatus
        ,IC.strReferenceNo
        ,IC.strReceiptNumber
        ,IC.intBankId
        ,IC.intBankAccountId
        ,IC.intBorrowingFacilityId
        ,IC.intSublimitTypeId
        ,IC.strBankReferenceNo
        ,CFL.intBorrowingFacilityLimitId
    ORDER BY tf.intTradeFinanceId DESC

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