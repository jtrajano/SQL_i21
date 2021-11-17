CREATE PROCEDURE [dbo].[uspCTProcessTFLogs]
	@strXML    NVARCHAR(MAX),
	@intUserId INT
AS    

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN 

	begin try

		DECLARE
			@strErrorMessage nvarchar(max)
			,@xmlDocumentId INT
			,@TRFLog TRFLog
			,@TFTransNo nvarchar(50)
			;

		DECLARE @TFXML TABLE(
			intContractDetailId INT
		) 

		EXEC sp_xml_preparedocument @xmlDocumentId output, @strXML

		INSERT INTO @TFXML
		(
			intContractDetailId
		)
		SELECT
			*
		FROM OPENXML(@xmlDocumentId, 'TFLogs', 2)
		WITH (
			intContractDetailId INT
		)

		EXEC uspSMGetStartingNumber 166, @TFTransNo OUTPUT;

		insert into @TRFLog
		select
			strAction = (case when l.intTradeFinanceLogId is null then 'Create Contract' else 'Update Contract' end)
			, strTransactionType = 'Contract'
			, intTradeFinanceTransactionId = null
			, strTradeFinanceTransaction = isnull(cd.strFinanceTradeNo,@TFTransNo)
			, intTransactionHeaderId = null
			, intTransactionDetailId = null
			, strTransactionNumber = isnull(cd.strFinanceTradeNo,@TFTransNo)
			, dtmTransactionDate = null
			, intBankTransactionId = cd.intBankAccountId
			, strBankTransactionId = cd.strBankReferenceNo
			, dblTransactionAmountAllocated = null
			, dblTransactionAmountActual = cd.dblLoanAmount
			, intLoanLimitId = cd.intLoanLimitId
			, strLoanLimitNumber = bl.strBankLoanId
			, strLoanLimitType = bl.strLimitDescription
			, dtmAppliedToTransactionDate = null
			, intStatusId = null
			, intWarrantId = null
			, strWarrantId = null
			, intUserId = @intUserId
			, intConcurrencyId = isnull(l.intConcurrencyId,0) + 1
			, intContractHeaderId = cd.intContractHeaderId
			, intContractDetailId = tf.intContractDetailId
		from
			@TFXML tf
			join tblCTContractDetail cd on cd.intContractDetailId = tf.intContractDetailId
			left join tblCMBankLoan bl on bl.intBankLoanId = cd.intLoanLimitId
			left join tblTRFTradeFinanceLog l on l.intContractDetailId = tf.intContractDetailId
		;

		if exists (select top 1 1 from @TRFLog)
		begin
			exec uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
		end


	end try
	begin catch
		SET @strErrorMessage = ERROR_MESSAGE()
		RAISERROR (@strErrorMessage,18,1,'WITH NOWAIT')
	end catch


END;