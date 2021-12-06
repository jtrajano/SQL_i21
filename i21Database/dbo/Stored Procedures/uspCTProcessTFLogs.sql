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
			,@intActiveContractDetailId int = 0
			;

		DECLARE @TFXML TABLE(
			intContractDetailId INT
			,strFinanceTradeNo nvarchar(50)
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

		select top 1 @intActiveContractDetailId = min(intContractDetailId) from @TFXML where intContractDetailId > @intActiveContractDetailId;
		while (@intActiveContractDetailId is not null)
		begin

			select @TFTransNo = strFinanceTradeNo from tblCTContractDetail where intContractDetailId = @intActiveContractDetailId;
			if (@TFTransNo is null)
			begin
				EXEC uspSMGetStartingNumber 166, @TFTransNo OUTPUT;
				update tblCTContractDetail set strFinanceTradeNo = @TFTransNo where intContractDetailId = @intActiveContractDetailId;
			end
			
			update @TFXML set strFinanceTradeNo = @TFTransNo where intContractDetailId = @intActiveContractDetailId;
			
			select top 1 @intActiveContractDetailId = min(intContractDetailId) from @TFXML where intContractDetailId > @intActiveContractDetailId;
		end

		select * from @TFXML;


		insert into @TRFLog
		select
			strAction = (case when et.intTradeFinanceLogId is null then 'Created Contract' else 'Updated Contract' end)
			, strTransactionType = 'Contract'
			, intTradeFinanceTransactionId = null
			, strTradeFinanceTransaction = isnull(cd.strFinanceTradeNo,tf.strFinanceTradeNo)
			, intTransactionHeaderId = cd.intContractHeaderId
			, intTransactionDetailId = cd.intContractDetailId
			, strTransactionNumber = ch.strContractNumber + '-' + convert(nvarchar(20),cd.intContractSeq)
			, dtmTransactionDate = getdate()
			, intBankTransactionId = cd.intBankAccountId
			, strBankTransactionId = cd.strBankReferenceNo
			, dblTransactionAmountAllocated = cd.dblLoanAmount
			, dblTransactionAmountActual = cd.dblLoanAmount
			, intLoanLimitId = cd.intLoanLimitId
			, strLoanLimitNumber = bl.strBankLoanId
			, strLoanLimitType = bl.strLimitDescription
			, dtmAppliedToTransactionDate = isnull(et.dtmAppliedToTransactionDate,getdate())
			, intStatusId = case when cd.intContractStatusId = 5 then 2 else 1 end
			, intWarrantId = null
			, strWarrantId = null
			, intUserId = @intUserId
			, intConcurrencyId = 1
			, intContractHeaderId = cd.intContractHeaderId
			, intContractDetailId = tf.intContractDetailId
		from
			@TFXML tf
			join tblCTContractDetail cd on cd.intContractDetailId = tf.intContractDetailId
			join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			left join tblCMBankLoan bl on bl.intBankLoanId = cd.intLoanLimitId
			cross apply (
				select intTradeFinanceLogId = max(intTradeFinanceLogId),dtmAppliedToTransactionDate from tblTRFTradeFinanceLog where intContractDetailId = tf.intContractDetailId group by dtmAppliedToTransactionDate
			) et
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