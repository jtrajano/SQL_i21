﻿CREATE PROCEDURE [dbo].[uspNRGenerateAmortization]
@NoteId Int
AS
BEGIN TRY 

	DECLARE @ErrMsg nvarchar(max)
	--RAISERROR('Test error', 16, 1, 'WITH NOWAIT') 
	--****** Due to rounding off precision issue, using Float instead of decimal for internal calculation. *********
	
	Declare @Duration Int
			, @Schd_Intv Int
			, @Schd_Months Int
			--, @InterestRate Decimal(18,2) --Float
			--, @TranInterest Decimal(18,2) --Float
			--, @MonthlyAmount Decimal(18,6) --Float
			--, @CreditLimit Decimal(18,6) --Float
			--, @Amount Decimal(18,6) --Float
			--, @ForcePaymentAmount Decimal(18,6) --Float
			, @InterestRate Float
			, @TranInterest Float
			, @MonthlyAmount Float
			, @CreditLimit Float
			, @Amount Float
			, @ForcePaymentAmount Float
			, @NoOfPayments Int
			, @ExpectedPayDate DateTime
			, @UserId Int
			, @NoteType nvarchar(100)
			, @NoteTransId Int


	--Get Duration in years and Note ID for further calculations. 
	--Set first expected pay date to schedule start date		
	SELECT @Duration = DATEDIFF(M,dtmSchdStartDate,dtmSchdEndDate)  --Cast((NRScheduleMaster.Schd_EndDate - NRScheduleMaster.Schd_StartDate) as int)/360
		, @NoteId = intNoteId 
		, @ExpectedPayDate = dtmSchdStartDate
		, @Schd_Months = intSchdMonthFreq
		, @ForcePaymentAmount = ISNULL(dblSchdForcePaymentAmt,0)
		, @UserId = intEntityId
		, @NoteType = strNoteType
	FROM  dbo.tblNRNote WHERE intNoteId = @NoteId
	
	--Declare @Fee numeric(18,6)
	Declare @Fee Float
	SELECT @Fee = dblFee FROM dbo.tblNRCompanyPreference 
	
	-- Fee transaction one time entry when note is created
	INSERT into dbo.tblNRNoteTransaction (intNoteId, dtmNoteTranDate, dtmAsOfDate, dtmInvoiceDate, intNoteTransTypeId, intTransDays, dblTransAmount, dblPrincipal, dblInterestToDate, dblUnpaidInterest, dblPayOffBalance, dblAmtAppToInterest, dblAmtAppToPrincipal, intEntityId ,intConcurrencyId)
	SELECT @NoteId, GETDATE(), GETDATE(), GETDATE(), 2, 0, @Fee,@Fee, 0, 0, @Fee, @Fee, 0, @UserId, 1
	SET @NoteTransId = @@IDENTITY
	EXEC dbo.uspNRCreateGLJournalEntry @NoteId, 2, @NoteTransId, @UserId
		
	If @NoteType = 'Scheduled Invoice'	
	BEGIN	
		--Calculate Number Of Payments
		--SET @NoOfPayments = (@Duration * 12)/@Schd_Months
		SET @NoOfPayments = (@Duration + 1) /@Schd_Months
		

		--Get Interest Rate and Credit Limit for the Note
		SELECT @InterestRate = dblInterestRate, @CreditLimit = dblCreditLimit FROM dbo.tblNRNote WHERE intNoteId = @NoteId

		--Get Interest per month
		SET @TranInterest = (@InterestRate/100)/12

		If @ForcePaymentAmount <=0
		BEGIN	
			--Get monthly amount
			SET @MonthlyAmount = ((@TranInterest * @CreditLimit)* Power((1+@TranInterest),@NoOfPayments))/(Power((1+@TranInterest),@NoOfPayments)-1)
			
			--Get payment amount for amortization as per the duration
			SET @Amount = @MonthlyAmount --* @Schd_Months
		END
		ELSE
			SET @Amount = @ForcePaymentAmount
		
		--Start the amortization loop here

		DECLARE @Cnt Int, @CntUpdated Bit
		
		Select Top 1 @Cnt = intPaymentNo from dbo.tblNRScheduleTransaction WHERE intNoteId = @NoteId ORDER BY intScheduleTransId DESC
		
		If ISNULL(@Cnt,0) <= 0 
		BEGIN
			SET @Cnt = 1
			SET @CntUpdated =0
		END
		ELSE
		BEGIN
			SET @Cnt = @Cnt + 1
			SET @NoOfPayments = @NoOfPayments + 1
			SET @CntUpdated = 1
		END
			

		WHILE ((@NoOfPayments + 1) > @Cnt)
		BEGIN
					
			--DECLARE @Principal Decimal(18,6), @Interest Decimal(18,6), @Balance Decimal(18,6), @PrevBalance Decimal(18,6)
			DECLARE @Principal Float, @Interest Float, @Balance Float, @PrevBalance Float
			
			If ((@CntUpdated =  0) AND (@Cnt = 1)) or @CntUpdated = 1
			BEGIN
				SET @PrevBalance = @CreditLimit
				SET @CntUpdated = 0
			END
					
			SET @Interest = @PrevBalance * @TranInterest
			SET @Principal = @Amount - @Interest
			SET @Balance = @PrevBalance - @Principal
			
			INSERT INTO [dbo].[tblNRScheduleTransaction]
				   ([intNoteId]
				   ,[intPaymentNo]
				   ,[dtmExpectedPayDate]
				   ,[dblExpectedPayAmt]
				   ,[dblPrincipal]
				   ,[dblInterest]
				   ,[dblBalance]
				   ,[dtmPayGeneratedOn]
				   ,[dtmPaidOn]
				   ,[dblPayAmt]
				   ,[dtmLateFeeGeneratedOn]
				   ,[dblLateFeeGenerated]
				   ,[dtmLateFeePaidOn]
				   ,[dblLateFeePayAmt]
				   ,[intConcurrencyId])
			 VALUES
				   (@NoteId
				   ,@Cnt
				   ,@ExpectedPayDate
				   ,@Amount
				   ,@Principal
				   ,@Interest
				   ,@Balance
				   ,NULL
				   ,NULL
				   ,0
				   ,NULL
				   ,0
				   ,NULL
				   ,0
				   ,1)

			SET @ExpectedPayDate = DATEADD(M,@Schd_Months,@ExpectedPayDate)
			
			SET @PrevBalance = @Balance
			
			
			SET @Cnt = @Cnt + 1
		END
	
	END
	

END TRY      
      
BEGIN CATCH       
 --IF XACT_STATE() != 0 ROLLBACK TRANSACTION    
 SET @ErrMsg = ERROR_MESSAGE()      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH