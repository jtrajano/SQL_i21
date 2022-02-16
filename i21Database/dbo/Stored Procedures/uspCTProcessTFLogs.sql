
Create PROCEDURE [dbo].[uspCTProcessTFLogs]
	@strXML    NVARCHAR(MAX),
	@intUserId INT
AS    
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN 

	begin try

		DECLARE
			@strErrorMessage nvarchar(max)
			,@xmlDocumentId INT
			,@TRFLog TRFLog
			,@TRFTradeFinance TRFTradeFinance
			,@TFTransNo nvarchar(50)
			,@intActiveContractDetailId int = 0
			,@strAction nvarchar(20)
			,@intTradeFinanceId int = 0;
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
			intContractDetailId
		FROM OPENXML(@xmlDocumentId, 'rows/row', 2)
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
				select intTradeFinanceLogId = max(intTradeFinanceLogId) from tblTRFTradeFinanceLog where intContractDetailId = tf.intContractDetailId
			) et
		;

		if exists (select top 1 1 from @TRFLog)
		begin
			exec uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
		end




		select
			  @strAction = (case when et.intTradeFinanceLogId is null then 'Created' else  'UPDATE REJECTED' end)
			 ,@intTradeFinanceId = et.intTradeFinanceLogId
		from
			@TFXML tf
			join tblCTContractDetail cd on cd.intContractDetailId = tf.intContractDetailId
			join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			left join tblCMBankLoan bl on bl.intBankLoanId = cd.intLoanLimitId
			cross apply (
				select  intTradeFinanceLogId = max(intTradeFinanceId) from tblTRFTradeFinance where intTransactionDetailId = tf.intContractDetailId
			) et
		;

		insert into @TRFTradeFinance
		select
			intTradeFinanceId = @intTradeFinanceId
			,strTradeFinanceNumber = isnull(cd.strFinanceTradeNo,tf.strFinanceTradeNo)
			,strTransactionType = 'Contract'
			,strTransactionNumber = ch.strContractNumber + '-' + convert(nvarchar(20),cd.intContractSeq)
			, intTransactionHeaderId = cd.intContractHeaderId
			, intTransactionDetailId = tf.intContractDetailId
			, intBankId = cd.intBankId
			, intBankAccountId = cd.intBankAccountId
			, intBorrowingFacilityId = cd.intBorrowingFacilityId
			, intLimitTypeId = cd.intBorrowingFacilityLimitId
			, intSublimitTypeId = cd.intBorrowingFacilityLimitDetailId
			, ysnSubmittedToBank = cd.ysnSubmittedToBank
			, dtmDateSubmitted = cd.dtmDateSubmitted
			, strApprovalStatus = ap.strApprovalStatus
			, dtmDateApproved = cd.dtmDateApproved
			, strRefNo = cd.strReferenceNo
			, intOverrideFacilityValuation = cd.intBankValuationRuleId
			, strCommnents = cd.strComments
			, dtmCreatedDate = GETDATE()
			, intConcurrencyId = 1
		from

			@TFXML tf
			join tblCTContractDetail cd on cd.intContractDetailId = tf.intContractDetailId
			join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			left join tblCTApprovalStatusTF ap on ap.intApprovalStatusId = cd.intApprovalStatusId
			left join tblCMBankLoan bl on bl.intBankLoanId = cd.intLoanLimitId
			
		;

		Declare @strCurrentStatus  nvarchar(20)
		SELECT @strCurrentStatus = strApprovalStatus 
		FROM tblTRFTradeFinance 
		WHERE intTradeFinanceId = @intTradeFinanceId


		IF  (@strCurrentStatus = 'Rejected')
		BEGIN
			SET @strAction = 'UPDATE'
		END
	
		If @strAction = 'Created'
		BEGIN
			EXEC [uspTRFCreateTFRecord] @records = @TRFTradeFinance, @intUserId = @intUserId
		END	
		ELSE
		BEGIN
			EXEC [uspTRFModifyTFRecord] @records = @TRFTradeFinance, @intUserId = @intUserId, @strAction = @strAction

			UPDATE tblCTContractDetail
			SET intBankAccountId = 0
				,intBankId = 0
				,intBorrowingFacilityId = 0
				,intBorrowingFacilityLimitId = 0
				,intBorrowingFacilityLimitDetailId = 0
				,strReference = ''
				,dblLoanAmount = 0
				,intBankValuationRuleId = 0
				,strBankReferenceNo = ''
				,strComments = ''
				,intFacilityId = 0
				,intLoanLimitId = 0
				,intOverrideFacilityId = 0
				,ysnSubmittedToBank = 0
				,dtmDateSubmitted = '1/1/1900'
				,intApprovalStatusId = 0
				,dtmDateApproved = '1/1/1900'
			WHERE intApprovalStatusId = 3
		END






	end try
	begin catch
		SET @strErrorMessage = ERROR_MESSAGE()
		RAISERROR (@strErrorMessage,18,1,'WITH NOWAIT')
	end catch


END;