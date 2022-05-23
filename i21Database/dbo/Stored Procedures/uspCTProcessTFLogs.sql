﻿CREATE PROCEDURE [dbo].[uspCTProcessTFLogs]
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
			,@TRFTradeFinanceFinal TRFTradeFinance
			,@TFTransNo nvarchar(50)
			,@intActiveContractDetailId int = 0
			,@strAction nvarchar(20)
			,@intTradeFinanceId int = 0
			,@intContractDetailId INT;
			;

		DECLARE @TFXML TABLE(
			intContractDetailId INT
			,strFinanceTradeNo nvarchar(50)
			,ysnStatusChange bit
			,strRowState nvarchar(50)
		) 

		EXEC sp_xml_preparedocument @xmlDocumentId output, @strXML

		INSERT INTO @TFXML
		(
			intContractDetailId
			,strFinanceTradeNo
			,ysnStatusChange
			,strRowState
		)
		SELECT
			intContractDetailId
			,strFinanceTradeNo = null
			,ysnStatusChange
			,strRowState
		FROM OPENXML(@xmlDocumentId, 'rows/row', 2)
		WITH (
			intContractDetailId INT
			,ysnStatusChange bit
			,strRowState nvarchar(50)
		)


		select top 1 @intActiveContractDetailId = min(intContractDetailId) from @TFXML where intContractDetailId > @intActiveContractDetailId;
		while (@intActiveContractDetailId is not null)
		begin
			
			IF EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail where intContractDetailId = @intActiveContractDetailId and intBankId IS NOT NULL)
			BEGIN
				select @TFTransNo = strFinanceTradeNo from tblCTContractDetail where intContractDetailId = @intActiveContractDetailId  ;
		
				if (@TFTransNo is null)
				begin
					EXEC uspSMGetStartingNumber 166, @TFTransNo OUTPUT;
					update tblCTContractDetail set strFinanceTradeNo = @TFTransNo where intContractDetailId = @intActiveContractDetailId;
				end
			
				update @TFXML set strFinanceTradeNo = @TFTransNo where intContractDetailId = @intActiveContractDetailId;
			END
				
			
			select top 1 @intActiveContractDetailId = min(intContractDetailId) from @TFXML where intContractDetailId > @intActiveContractDetailId;
		end

		

			insert into @TRFLog
			(
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
				, intBankId = cd.intBankId
				, intBankAccountId = cd.intBankAccountId
				, intBorrowingFacilityId = cd.intBorrowingFacilityId
				, intLimitId = cd.intBorrowingFacilityLimitId
				, intSublimitId = cd.intBorrowingFacilityLimitDetailId
				, strBankTradeReference = cd.strReferenceNo
				, strBankApprovalStatus = STF.strApprovalStatus
				, dblLimit = limit.dblLimit
				, dblSublimit = sublimit.dblLimit
				, dblFinanceQty = CASE WHEN cd.intApprovalStatusId in (3,4) THEN 0 
										ELSE  case when cd.intContractStatusId <> 6 then cd.dblQuantity else (cd.dblQuantity - cd.dblBalance) END 
								  END
				, dblFinancedAmount = (CASE WHEN cd.intApprovalStatusId in (3,4) THEN 0 
											ELSE case when cd.intContractStatusId <> 6 then cd.dblTotalCost else cd.dblTotalCost * ((cd.dblQuantity - cd.dblBalance) / cd.dblQuantity) end
									  END) * (case when cd.intCurrencyId <> cd.intInvoiceCurrencyId and isnull(cd.dblRate,0) <> 0 then cd.dblRate else 1 end)
				, strBorrowingFacilityBankRefNo = cd.strBankReferenceNo
				, ysnDelete = CASE WHEN cd.intContractStatusId = 3 THEN 1 ELSE 0 END
			
			from
				@TFXML tf
				join tblCTContractDetail cd on cd.intContractDetailId = tf.intContractDetailId
				join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
				left join tblCMBankLoan bl on bl.intBankLoanId = cd.intLoanLimitId
				left join tblCTApprovalStatusTF STF on STF.intApprovalStatusId = cd.intApprovalStatusId
				left join tblCMBorrowingFacilityLimit limit on limit.intBorrowingFacilityLimitId = cd.intBorrowingFacilityLimitId
				left join tblCMBorrowingFacilityLimitDetail sublimit on sublimit.intBorrowingFacilityLimitDetailId = cd.intBorrowingFacilityLimitDetailId
				cross apply (
					select intTradeFinanceLogId = max(intTradeFinanceLogId) from tblTRFTradeFinanceLog where intContractDetailId = tf.intContractDetailId and strTradeFinanceTransaction = cd.strFinanceTradeNo COLLATE Database_default
				) et
			where isnull(cd.intBankId,0) > 0 AND ISNULL(tf.strRowState, '') <> 'Delete'
			;

			if exists (select top 1 1 from @TRFLog)
			begin
				exec uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
			end



			DELETE FROM @TRFLog

			DECLARE @deletedSequence TABLE(
			intTradeFinanceLogId INT
			) 

			INSERT INTO @deletedSequence
			SELECT MAX(intTradeFinanceLogId)
			FROM tblTRFTradeFinanceLog TFL
			INNER JOIN @TFXML tf on TFL.intContractDetailId = tf.intContractDetailId
			WHERE strRowState = 'Delete'
			GROUP BY TFL.intContractDetailId
			


			insert into @TRFLog
			(
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
			select
				strAction = 'Deleted Contract'
				, strTransactionType = 'Contract'
				, intTradeFinanceTransactionId = null
				, strTradeFinanceTransaction = isnull(TFL.strTradeFinanceTransaction,tf.strFinanceTradeNo)
				, intTransactionHeaderId = TFL.intTransactionHeaderId
				, intTransactionDetailId = TFL.intTransactionDetailId
				, strTransactionNumber = TFL.strTransactionNumber 
				, dtmTransactionDate = getdate()
				, intBankTransactionId = null
				, strBankTransactionId = null
				, dblTransactionAmountAllocated = TFL.dblTransactionAmountAllocated
				, dblTransactionAmountActual = TFL.dblTransactionAmountActual
				, intLoanLimitId = TFL.intLoanLimitId
				, strLoanLimitNumber = TFL.strLoanLimitNumber
				, strLoanLimitType = TFL.strLoanLimitType
				, dtmAppliedToTransactionDate = getdate()
				, intStatusId = TFL.intStatusId
				, intWarrantId = null
				, strWarrantId = null
				, intUserId = @intUserId
				, intConcurrencyId = 1
				, intContractHeaderId = TFL.intContractHeaderId
				, intContractDetailId = TFL.intContractDetailId
				, intBankId = TFL.intBankId
				, intBankAccountId = TFL.intBankAccountId
				, intBorrowingFacilityId = TFL.intBorrowingFacilityId
				, intLimitId = TFL.intLimitId
				, intSublimitId = TFL.intSublimitId
				, strBankTradeReference = TFL.strBankTradeReference
				, strBankApprovalStatus = TFL.strBankApprovalStatus
				, dblLimit = TFL.dblLimit
				, dblSublimit = TFL.dblSublimit
				, dblFinanceQty = TFL.dblFinanceQty
				, dblFinancedAmount = TFL.dblFinancedAmount
				, strBorrowingFacilityBankRefNo = TFL.strBorrowingFacilityBankRefNo
				, ysnDelete = 1
			from
				@TFXML tf
				INNER JOIN tblTRFTradeFinanceLog TFL on TFL.intContractDetailId = tf.intContractDetailId
				INNER JOIN @deletedSequence ds on ds.intTradeFinanceLogId = TFL.intTradeFinanceLogId
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
			intTradeFinanceId = isnull(tff.intTradeFinanceId, 0)
			,strTradeFinanceNumber = isnull(cd.strFinanceTradeNo,tf.strFinanceTradeNo)
			,strTransactionType = 'Contract'
			,strTransactionNumber = ch.strContractNumber + '-' + convert(nvarchar(20),cd.intContractSeq)
			, intTransactionHeaderId = cd.intContractHeaderId
			, intTransactionDetailId = tf.intContractDetailId
			, intBankId = isnull(cd.intBankId,0)
			, intBankAccountId = CASE WHEN @strAction = 'Created' then cd.intBankAccountId else isnull(cd.intBankAccountId, 0) end
			, intBorrowingFacilityId = isnull(cd.intBorrowingFacilityId, 0)
			, intLimitTypeId = isnull(cd.intBorrowingFacilityLimitId, 0)
			, intSublimitTypeId = isnull(cd.intBorrowingFacilityLimitDetailId, 0)
			, ysnSubmittedToBank = isnull(cd.ysnSubmittedToBank, 0)
			, dtmDateSubmitted = isnull(cd.dtmDateSubmitted, '1/1/1900')
			, strApprovalStatus = isnull(ap.strApprovalStatus, '')
			, dtmDateApproved = isnull(cd.dtmDateApproved, '1/1/1900')
			, strRefNo = isnull(cd.strReferenceNo, '')
			, intOverrideFacilityValuation = isnull(cd.intBankValuationRuleId, 0)
			, strCommnents = isnull(cd.strComments,'')
			, dtmCreatedDate = GETDATE()
			, intConcurrencyId = 1
		from

			@TFXML tf
			join tblCTContractDetail cd on cd.intContractDetailId = tf.intContractDetailId
			join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			left join tblCTApprovalStatusTF ap on ap.intApprovalStatusId = cd.intApprovalStatusId
			left join tblCMBankLoan bl on bl.intBankLoanId = cd.intLoanLimitId
			left join tblTRFTradeFinance tff on tff.intTransactionDetailId = tf.intContractDetailId
		where isnull(cd.intBankId,0) > 0
			
		;

	

		Declare @strCurrentStatus  nvarchar(20)
		SELECT @strCurrentStatus = strApprovalStatus 
		FROM tblTRFTradeFinance 
		WHERE intTradeFinanceId = @intTradeFinanceId


		IF  (@strCurrentStatus in ('Rejected', 'Cancelled'))
		BEGIN
			SET @strAction = 'UPDATE'
		END
	
		DECLARE @Counter INT 
		SET @Counter= (SELECT Count(1) From @TRFTradeFinance)
		WHILE ( 1 <= @Counter)
		BEGIN
			INSERT INTO @TRFTradeFinanceFinal
			select  intTradeFinanceId	
					,strTradeFinanceNumber	
					,strTransactionType	
					,strTransactionNumber	
					,intTransactionHeaderId	
					,intTransactionDetailId	
					,intBankId	
					,intBankAccountId	
					,intBorrowingFacilityId	
					,intLimitTypeId	
					,intSublimitTypeId	
					,ysnSubmittedToBank	
					,dtmDateSubmitted	
					,strApprovalStatus	
					,dtmDateApproved	
					,strRefNo	
					,intOverrideFacilityValuation	
					,strCommnents	
					,dtmCreatedDate	
					,intConcurrencyId
			FROM @TRFTradeFinance where intId = @Counter

		
			
			If @strAction = 'Created'
			BEGIN
				EXEC [uspTRFCreateTFRecord] @records = @TRFTradeFinanceFinal, @intUserId = @intUserId
			END
			ELSE
			BEGIN
				
				

				EXEC [uspTRFModifyTFRecord] @records = @TRFTradeFinanceFinal, @intUserId = @intUserId, @strAction = @strAction

				SELECT @intContractDetailId  = intTransactionDetailId FROM @TRFTradeFinanceFinal

				UPDATE tblCTContractDetail
				SET intBankAccountId = 0
					,intBankId = 0
					,intBorrowingFacilityId = 0
					,intBorrowingFacilityLimitId = 0
					,intBorrowingFacilityLimitDetailId = 0
					,strReferenceNo = ''
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
					,dblInterestRate = null
					,strFinanceTradeNo = CASE WHEN intApprovalStatusId in (3,4) then null else strFinanceTradeNo END
				WHERE intApprovalStatusId in (3,4) and intContractDetailId = @intContractDetailId


				
			

			END


			
			SET @Counter  = @Counter  - 1
			DELETE FROM @TRFTradeFinanceFinal
		END


	end try
	begin catch
		SET @strErrorMessage = ERROR_MESSAGE()
		RAISERROR (@strErrorMessage,18,1,'WITH NOWAIT')
	end catch


END;

