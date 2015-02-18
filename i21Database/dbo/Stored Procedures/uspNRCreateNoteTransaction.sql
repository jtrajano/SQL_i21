CREATE PROCEDURE [dbo].[uspNRCreateNoteTransaction]
@XML varchar(max)
AS
BEGIN TRY  
	DECLARE 
	 @idoc int
	,@ErrMsg nvarchar(max)
	,@intNoteId Int
	,@isWriteOff bit
	, @intNoteTransId Int
	,@NoteTransID Int
	,@TransDate DateTime
	,@TransTypeID Int
	,@Amount Decimal(18,2)
	,@PayOffBalance Decimal(18,2)
	,@InvoiceNumber nvarchar(10)
	,@InvoiceDate DateTime
	,@Location Char(3)
	,@BatchNumber Char(3)
	,@Days Int
	,@AmountAppliedToPrincipal Decimal(18,2)
	,@AmountAppliesToInterest Decimal(18,2)
	,@AsOf DateTime
	,@Principal Decimal(18,2)
	,@CheckNumber nvarchar(10)
	,@UserId nvarchar(10)
	,@LastUpdateDate DateTime
	,@Comments nvarchar(200)
	,@OnPrincipalOrInterest nvarchar(50)
	,@AccountAffected nvarchar(50)
	,@InvoiceLocation nvarchar(20)
	,@ReferenceNumber nvarchar(20)
	,@PaymentType nvarchar(20)
	,@InterestToDate Decimal(18,4)
	,@BulkInterest Int = 0
	, @AsOfForInterestCal DateTime
	,@AdjustmentType nvarchar(200)	
	,@NoteType char(50)
	,@UnPaidInterest Decimal(18,2)
	,@ConcurrencyId int
	, @dblInterestRate Decimal(18,6)
	, @dblPrevPrincipal Decimal(18,6) 
	, @intInvDays Int
	, @dblPrevUnpaidInterest Decimal(18,6) = NULL
	, @intInvNoteTransId Int = NULL
	
	DECLARE @dtmPrevAsOfDate DateTime
			, @intLastTransTypeID Int
	
	
	SET @dblPrevPrincipal = NULL
	SET @intInvDays = NULL
	
	--BEGIN TRANSACTION
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT @intNoteId = NoteID,@isWriteOff= WriteOff
	 From OPENXML(@idoc, 'root',2) WITH( NoteID int
	 ,WriteOff bit)
			
	SELECT @isWriteOff = ysnWriteOff, @NoteType = strNoteType, @dblInterestRate = dblInterestRate 
	FROM dbo.tblNRNote WHERE intNoteId = @intNoteId
	--SELECT @NoteType = strNoteType FROM dbo.tblNRNote Where intNoteId = @intNoteId
	
	SELECT top 1 @dtmPrevAsOfDate = dtmAsOfDate, @intLastTransTypeID = intNoteTransTypeId
		, @dblPrevPrincipal = ISNULL(dblPrincipal,0)
		, @dblPrevUnpaidInterest = ISNULL(dblUnpaidInterest,0)
		FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId Order By intNoteTransId DESC
		
	
	DECLARE CurTrans CURSOR FOR
	SELECT 
		TransDate
      ,TransTypeID
      ,Amount
      ,PayOffBalance 
      ,InvoiceNumber
      ,InvoiceDate
      ,Location
      ,BatchNumber
      ,[Days]
      ,AmountAppliedToPrincipal
      ,AmountAppliesToInterest
      ,AsOf
      ,Principal
      ,CheckNumber
      ,UserId
      ,LastUpdateDate
      ,Comments
      ,OnPrincipalOrInterest
      ,AccountAffected
      ,InvoiceLocation
      ,ReferenceNumber
      ,PaymentType
      ,AdjustmentType
      ,ConcurrencyId
	FROM OPENXML(@idoc, 'root/NoteTrans/NoteTransDetail',2)
	WITH(
	  TransDate DateTime
      ,TransTypeID Int
      ,Amount Decimal(18,2)
      ,PayOffBalance Decimal(18,2)
      ,InvoiceNumber nvarchar(10)
      ,InvoiceDate DateTime
      ,Location Char(3)
      ,BatchNumber Char(3)
      ,[Days] Int
      ,AmountAppliedToPrincipal Decimal(18,2)
      ,AmountAppliesToInterest Decimal(18,2)
      ,AsOf DateTime
	  ,Principal Decimal(18,2)
	  ,CheckNumber nvarchar(10)
	  ,UserId nvarchar(10)
	  ,LastUpdateDate datetime
	  ,Comments nvarchar(200)
	  ,OnPrincipalOrInterest nvarchar(50)
	  ,AccountAffected nvarchar(50)
	  ,InvoiceLocation nvarchar(20)
	  ,ReferenceNumber nvarchar(20)
	  ,PaymentType nvarchar(20)
	  ,AdjustmentType nvarchar(200)
	  ,ConcurrencyId int)  
	  
	OPEN CurTrans
	  
	FETCH NEXT FROM curTrans INTO 
	 @TransDate 
	,@TransTypeID 
	,@Amount 
	,@PayOffBalance 
	,@InvoiceNumber 
	,@InvoiceDate 
	,@Location 
	,@BatchNumber 
	,@Days 
	,@AmountAppliedToPrincipal 
	,@AmountAppliesToInterest 
	,@AsOf 
	,@Principal 
	,@CheckNumber 
	,@UserId 
	,@LastUpdateDate
	,@Comments
	,@OnPrincipalOrInterest
	,@AccountAffected
	,@InvoiceLocation
	,@ReferenceNumber
	,@PaymentType
	,@AdjustmentType
	,@ConcurrencyId
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		
		IF @TransTypeID = 6
		SET @Amount = @Amount * (-1)
		
		
		if CONVERT(nvarchar(10), @dtmPrevAsOfDate, 101) = CONVERT(nvarchar(10), @AsOf, 101)
		BEGIN
			Select Top 1 @Days = intTransDays From dbo.tblNRNoteTransaction WHERE intNoteId =  @intNoteId Order By intNoteTransId DESC
		END
		ELSE IF @TransTypeID = 6
		BEGIN
			DECLARE @PayNoteTransID Int
		
			SELECT @NoteTransID = intNoteTransId FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND intNoteTransTypeId = 4 AND strCheckNumber = @CheckNumber
		
			SELECT TOP 1 @dtmPrevAsOfDate = dtmAsOfDate FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND intNoteTransTypeId > (@NoteTransID) --<= @PrvAsOfDate AND TransTypeID = 4 and 	
			SET @Days = DATEDIFF(day,@dtmPrevAsOfDate,@AsOf)
		END
		ELSE IF @intLastTransTypeID = 6 
		BEGIN			
			SELECT TOP 1 @dtmPrevAsOfDate = dtmAsOfDate From dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND intNoteTransTypeId <> 6 ORDER By intNoteTransId DESC
			SET @Days = DATEDIFF(day,@dtmPrevAsOfDate,@AsOf)
		END
		ELSE
		BEGIN
			SET @Days = DATEDIFF(day,@dtmPrevAsOfDate,@AsOf)
		END
		
		IF @TransTypeID = 1
		BEGIN
			SET @intInvDays = ISNULL(@intInvDays, @Days)
			SET @intInvNoteTransId = ISNULL(@intInvNoteTransId, @intNoteTransId)
		END
		
				
		INSERT INTO dbo.tblNRNoteTransaction
		SELECT 
		 @intNoteId 
		,@TransDate 
		,@TransTypeID 
		,ISNULL(@Days,0) 
		,ISNULL(@Amount,0) 
		,ISNULL(@Principal,0) 
		,ISNULL(@InterestToDate,0)
		,ISNULL(@UnPaidInterest,0)
		,ISNULL(@PayOffBalance,0) 
		,@InvoiceNumber 
		,@InvoiceDate 
		,@InvoiceLocation
		,@Location 
		,@ReferenceNumber
		,@BatchNumber 
		,ISNULL(@AmountAppliedToPrincipal,0) 
		,ISNULL(@AmountAppliesToInterest,0) 
		,@PaymentType
		,@AsOf 
		,@CheckNumber 
		,@Comments
		,@OnPrincipalOrInterest
		,@AccountAffected
		,@AdjustmentType
		,@UserId 
		,@ConcurrencyId
		--,@dtmPrevAsOfDate 
		--,@ReferenceNumber
		
		SET @intNoteTransId = @@IDENTITY
		
		IF(@TransTypeID = 1)
		BEGIN
			EXEC dbo.uspNRCreateAREntry @intNoteTransId
		END
		IF(@TransTypeID = 4)
		BEGIN
			DECLARE @intCMTransactionId Int, @intGLReceivableAccountId Int
			IF(@NoteType = 'Scheduled Invoice' AND @CheckNumber <> 'AutoSchedule')
			BEGIN
				DECLARE @ExpectedPayAmount numeric(18,6), @LateFee numeric(18,6)
				SELECT TOP 1 @ExpectedPayAmount = dblExpectedPayAmt FROM dbo.tblNRScheduleTransaction Where intNoteId = @intNoteId
				SELECT TOP 1 @LateFee = dblLateFeePayAmt FROM dbo.tblNRScheduleTransaction Where intNoteId = @intNoteId 
				AND dblLateFeePayAmt > 0 
				AND CAST(CONVERT(nvarchar(10),dtmLateFeePaidOn,101)AS DateTime)  = CAST(CONVERT(nvarchar(10),GETDATE(),101)AS DateTime)
				ORDER BY intScheduleTransId DESC
				
				SET @Comments = ''
				
				IF(ISNULL(@Amount,0) > @ExpectedPayAmount)
				BEGIN
					DECLARE @ExtraAmount numeric(18,6)
					SET @ExtraAmount = (@Amount - @ExpectedPayAmount)
					--EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, 4, @intNoteTransId, @UserId, 1, @ExtraAmount, 0, ''
					SELECT @intGLReceivableAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
					EXEC dbo.uspNRCreateCashEntry  @intNoteId, @intNoteTransId, @ExtraAmount, @intGLReceivableAccountId, @intCMTransactionId OUTPUT 
					SET @Comments = @Comments + CAST(@intCMTransactionId as nvarchar(30))
					SET @intCMTransactionId = 0
					
					--EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, 4, @intNoteTransId, @UserId, 1, 0, 0, ''
					SELECT @intGLReceivableAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
					EXEC dbo.uspNRCreateCashEntry  @intNoteId, @intNoteTransId, @ExpectedPayAmount, @intGLReceivableAccountId, @intCMTransactionId OUTPUT 
					SET @Comments = @Comments + ',' + CAST(@intCMTransactionId as nvarchar(30))
					SET @intCMTransactionId = 0
					
				END
				ELSE
				BEGIN
					--EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, 4, @intNoteTransId, @UserId, 0, 0, 0, ''
					SELECT @intGLReceivableAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
					EXEC dbo.uspNRCreateCashEntry  @intNoteId, @intNoteTransId, @Amount, @intGLReceivableAccountId, @intCMTransactionId OUTPUT 
					SET @Comments = @Comments + CAST(@intCMTransactionId as nvarchar(30))
					SET @intCMTransactionId = 0
				END
				
				IF(ISNULL(@LateFee,0) <> 0)
				BEGIN
					--EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, 4, @intNoteTransId, @UserId, 0, 0, @LateFee, ''
					SELECT @intGLReceivableAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
					EXEC dbo.uspNRCreateCashEntry  @intNoteId, @intNoteTransId, @LateFee, @intGLReceivableAccountId, @intCMTransactionId OUTPUT 
					SET @Comments = @Comments + ',' + CAST(@intCMTransactionId as nvarchar(30))
					SET @intCMTransactionId = 0
				END
				
				UPDATE dbo.tblNRNoteTransaction Set strTransComments = @Comments Where intNoteTransId = @intNoteTransId
				
			END
			ELSE
			BEGIN
				--EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, 4, @intNoteTransId, @UserId, 0, 0, 0, ''
				SELECT @intGLReceivableAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
				EXEC dbo.uspNRCreateCashEntry  @intNoteId, @intNoteTransId, @Amount, @intGLReceivableAccountId, @intCMTransactionId OUTPUT 
				SET @Comments = @Comments + CAST(@intCMTransactionId as nvarchar(30))
				SET @intCMTransactionId = 0
				
				UPDATE dbo.tblNRNoteTransaction Set strTransComments = @Comments Where intNoteTransId = @intNoteTransId
				
			END
		END
		IF(@TransTypeID = 6)
		BEGIN
			--EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, @TransTypeID, @intNoteTransId, @UserId, 0, 0, 0, ''
			EXEC dbo.uspNRCreateCashRevarseEntry @intNoteTransId
		END
		IF(@TransTypeID = 7)
		BEGIN
			IF ISNULL(@Amount,0) < 0 
			BEGIN
				EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, @TransTypeID, @intNoteTransId, @UserId, 1, 0, 0, @AccountAffected
			END
			ELSE
			BEGIN
				EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, @TransTypeID, @intNoteTransId, @UserId, 0, 0, 0, @AccountAffected
			END	
		END
		
		--Declare @TransId
	
	FETCH NEXT FROM curTrans INTO 
	 @TransDate 
	,@TransTypeID 
	,@Amount 
	,@PayOffBalance 
	,@InvoiceNumber 
	,@InvoiceDate 
	,@Location 
	,@BatchNumber 
	,@Days 
	,@AmountAppliedToPrincipal 
	,@AmountAppliesToInterest 
	,@AsOf 
	,@Principal 
	,@CheckNumber 
	,@UserId 
	,@LastUpdateDate
	,@Comments
	,@OnPrincipalOrInterest
	,@AccountAffected 
	,@InvoiceLocation
	,@ReferenceNumber
	,@PaymentType
	,@AdjustmentType
	,@ConcurrencyId
	
		
	END
		
	Close CurTrans
	Deallocate CurTrans
		
		IF @TransTypeID = 1
		BEGIN
			SET @Days = @intInvDays
			SET @intNoteTransId = @intInvNoteTransId
		END
		
		
		-- ***** Interest since last creation *****
		IF @TransTypeID = 6
			SET @InterestToDate = NULL
		ELSE
			SET @InterestToDate = @dblPrevPrincipal * ((@dblInterestRate/100)/360) * @Days
			
			
		-- ***** Amount Applied To Principal *****
		IF(@TransTypeID= 7 AND @OnPrincipalOrInterest = 'Principal' AND @Amount > 0)
			SET @AmountAppliedToPrincipal = @Amount 
		ELSE IF(@TransTypeID= 7 AND @OnPrincipalOrInterest = 'Principal' AND @Amount < 0)
			SET @AmountAppliedToPrincipal = @Amount  * (-1) 
		ELSE IF(@TransTypeID= 1) 
			SET @AmountAppliedToPrincipal = @Amount
		ELSE IF(@TransTypeID= 6) 
			SET @AmountAppliedToPrincipal = @Amount  * (-1)  
		ELSE IF(@TransTypeID = 4) 
		BEGIN
			IF (@NoteType = 'Pay Principal First')
			BEGIN
				IF(@Amount>@dblPrevPrincipal)
					SET @AmountAppliedToPrincipal = @dblPrevPrincipal * (-1)
				ELSE
					SET @AmountAppliedToPrincipal = @Amount * (-1)
			END
			IF (@NoteType = 'Pay Interest First' OR @NoteType = 'Scheduled Invoice')
			BEGIN
				IF(@Amount > @dblPrevUnpaidInterest)
					SET @AmountAppliedToPrincipal = (@Amount - @dblPrevUnpaidInterest) * (-1)
				ELSE
					SET @AmountAppliedToPrincipal = 0
			END
		END	
		ELSE
			SET @AmountAppliedToPrincipal = 0			
		
		
		-- ***** Amount Applied To Interest *****
		IF (@TransTypeID= 7 AND @OnPrincipalOrInterest = 'Interest' AND @Amount > 0) 
			SET @AmountAppliesToInterest = @Amount 
		ELSE IF(@TransTypeID= 7 AND @OnPrincipalOrInterest = 'Interest' AND @Amount < 0) 
			SET @AmountAppliesToInterest = @Amount  * (-1)
		ELSE IF(@TransTypeID= 1) 
			SET @AmountAppliesToInterest = @Amount
		ELSE IF(@TransTypeID= 4) 
		BEGIN
			IF (@NoteType = 'Pay Principal First')
			BEGIN
				IF(@Amount>@dblPrevPrincipal)
					SET @AmountAppliesToInterest = (@Amount-@dblPrevPrincipal)*(-1)
				ELSE
					SET @AmountAppliesToInterest = 0
			END
			IF (@NoteType = 'Pay Interest First' OR @NoteType = 'Scheduled Invoice')
			BEGIN
				IF(@Amount > @dblPrevUnpaidInterest)
					SET @AmountAppliesToInterest = (@dblPrevUnpaidInterest) * (-1)
				ELSE
					SET @AmountAppliesToInterest = (@Amount) * (-1)
			END
		END	
		ELSE
			SET @AmountAppliesToInterest = 0 
			
		
		-- ***** Principal ****************
		IF((@dblPrevPrincipal + @AmountAppliedToPrincipal)<=0)
			SET @Principal = 0
		ELSE
			SET @Principal = @dblPrevPrincipal + @AmountAppliedToPrincipal
			
			
		-- ***** Unpaid Interest **********
		SET @UnPaidInterest = ISNULL(@dblPrevUnpaidInterest,0) + ISNULL(@InterestToDate, 0) + ISNULL(@AmountAppliesToInterest, 0) 				
		
		SET @PayOffBalance = ISNULL(@Principal,0) + ISNULL(@UnPaidInterest,0)
		
		
		-- ****** Update note transaction table with calculated values *******
		UPDATE dbo.tblNRNoteTransaction
		SET dblInterestToDate = @InterestToDate
		, dblAmtAppToPrincipal = @AmountAppliedToPrincipal
		, dblAmtAppToInterest = @AmountAppliesToInterest
		, dblPrincipal = @Principal
		, dblUnpaidInterest = @UnPaidInterest
		, dblPayOffBalance = @PayOffBalance
		WHERE intNoteTransId = @intNoteTransId
		
		UPDATE dbo.tblNRNote SET dblNotePrincipal = (SELECT ISNULL(dblPrincipal,0) FROM dbo.tblNRNoteTransaction WHERE intNoteTransId = @intNoteTransId) WHERE intNoteId = @intNoteId
		
	--EXEC [dbo].[Note_Future_Trans_Update] @intNoteId=@intNoteId
		
	--RETURN @intNoteTransId

	  	--COMMIT TRANSACTION	
	  	
	 END TRY   
	   
      
BEGIN CATCH       
 --IF XACT_STATE() != 0 ROLLBACK TRANSACTION    
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
