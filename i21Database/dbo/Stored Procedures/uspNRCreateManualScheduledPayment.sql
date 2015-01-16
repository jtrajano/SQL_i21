CREATE PROCEDURE [dbo].[uspNRCreateManualScheduledPayment]
@intNoteId int,
@dblPayment numeric(18,6),
@dblLateFee numeric(18,6)
AS  
BEGIN  
	DECLARE @intPaymentNo int, @dblExpectedPayAmt numeric(10,2), 
	@dblPayAmt numeric(18,6), @strSchdLateAppliedOn Nvarchar(30), @strSchdLateFeeUnit Nvarchar(10) ,
	@intSchdGracePeriod Nvarchar(10), @latefee numeric(18,6), @dblSchdLateFee numeric(18,6) , @dblPrincipal numeric(18,6)
	, @dblInterest numeric(18,6), @dblBalance numeric(18,6),@dtmExpectedPayDate datetime ,@SchdHst_PayDate datetime  
	, @decdiffFeeAmt numeric(18,6) = 0.0 , @decdiffAmt numeric(18,6) = 0.0 , @alreadyPaidAmount numeric(10,2) , @alreadyPaidFeeAmount numeric(10,2)    

	SELECT @intSchdGracePeriod = intSchdGracePeriod, @strSchdLateFeeUnit = strSchdLateFeeUnit
	, @strSchdLateAppliedOn = strSchdLateAppliedOn, @dblSchdLateFee = dblSchdLateFee  
	FROM dbo.tblNRNote WHERE intNoteId = @intNoteId  

	DECLARE curCalcInt CURSOR FOR  
	SELECT intPaymentNo   
	, dtmExpectedPayDate   
	, dblExpectedPayAmt
	, dblPayAmt
	, dtmPaidOn
	,[dblPrincipal]
	,[dblInterest]
	,[dblBalance]
	FROM dbo.tblNRScheduleTransaction   
	WHERE intNoteId = @intNoteId and dtmExpectedPayDate <= GETDATE() 
	--and dblExpectedPayAmt <> dblPayAmt 
	order By intPaymentNo

	OPEN curCalcInt  
	FETCH NEXT FROM curCalcInt INTO @intPaymentNo, @dtmExpectedPayDate, @dblExpectedPayAmt ,  @dblPayAmt , @SchdHst_PayDate ,@dblPrincipal,@dblInterest,@dblBalance
	WHILE(@@FETCH_STATUS = 0)   
   
	BEGIN 
	 set @alreadyPaidAmount  = 0.0
	 set @alreadyPaidFeeAmount = 0.0
		IF @strSchdLateFeeUnit = '$'
		BEGIN
			IF @dblPayAmt = 0.0
			BEGIN
				IF DATEDIFF(day, @dtmExpectedPayDate,GETDATE()) > @intSchdGracePeriod
					SET @latefee = @dblSchdLateFee
			END
			 ELSE
    BEGIN
     IF DATEDIFF(day, @dtmExpectedPayDate,@SchdHst_PayDate) > @intSchdGracePeriod    
      SET @latefee = @dblSchdLateFee    
    END   
		END
		ELSE
	   BEGIN    
    IF @strSchdLateAppliedOn = 'Outstanding Balance'    
    BEGIN    
     IF @dblPayAmt = 0.0    
     BEGIN    
      IF DATEDIFF(day, @dtmExpectedPayDate,GETDATE()) > @intSchdGracePeriod    
       SET @latefee = @dblSchdLateFee * @dblBalance / 100    
     END 
    ELSE
    BEGIN
     IF DATEDIFF(day, @dtmExpectedPayDate,@SchdHst_PayDate) > @intSchdGracePeriod    
       SET @latefee = @dblSchdLateFee * @dblBalance / 100  
    END     
    END    
    IF @strSchdLateAppliedOn = 'Principal'    
    BEGIN    
     IF @dblPayAmt = 0.0    
     BEGIN   
      IF DATEDIFF(day, @dtmExpectedPayDate,GETDATE()) > @intSchdGracePeriod     
       SET @latefee = @dblSchdLateFee * @dblPrincipal / 100    
     END 
    ELSE
    BEGIN
    IF DATEDIFF(day, @dtmExpectedPayDate,@SchdHst_PayDate) > @intSchdGracePeriod    
         SET @latefee = @dblSchdLateFee * @dblPrincipal / 100   
    END     
    END    
    IF @strSchdLateAppliedOn = 'Interest'    
    BEGIN    
     IF @dblPayAmt = 0.0    
     BEGIN   
      IF DATEDIFF(day, @dtmExpectedPayDate,GETDATE()) > @intSchdGracePeriod     
       SET @latefee = @dblSchdLateFee * @dblInterest / 100    
     END 
    ELSE
    BEGIN
    IF DATEDIFF(day, @dtmExpectedPayDate,@SchdHst_PayDate) > @intSchdGracePeriod    
          SET @latefee = @dblSchdLateFee * @dblInterest / 100      
    END         
    END    
   END    

		IF @dblPayment > 0
		BEGIN
	
		 select @alreadyPaidAmount = isnull(dblPayAmt,0.0) from dbo.tblNRScheduleTransaction WHERE intNoteId = @intNoteId and  intPaymentNo = @intPaymentNo
			SET @decdiffAmt =  @dblPayment - @dblExpectedPayAmt + @alreadyPaidAmount 
			--
			IF @decdiffAmt > 0
			BEGIN
			SET @dblPayment = @decdiffAmt
				UPDATE dbo.tblNRScheduleTransaction
				SET dtmPaidOn = GETDATE(), dblPayAmt = @dblExpectedPayAmt  
				WHERE intNoteId = @intNoteId and  intPaymentNo = @intPaymentNo
			END
			ELSE
			BEGIN
				UPDATE dbo.tblNRScheduleTransaction
				SET dtmPaidOn = GETDATE(), dblPayAmt = @dblPayment + @alreadyPaidAmount
				WHERE intNoteId = @intNoteId and  intPaymentNo = @intPaymentNo
				SET @dblPayment = 0
			END
		END
		
	 select @alreadyPaidFeeAmount = isnull(dblLateFeePayAmt,0.0) from dbo.tblNRScheduleTransaction WHERE intNoteId = @intNoteId and  intPaymentNo = @intPaymentNo
		IF @dblLateFee > 0
		BEGIN
			SET @decdiffFeeAmt = @dblLateFee - isnull(@latefee,0) + @alreadyPaidFeeAmount
			IF @decdiffFeeAmt > 0
			BEGIN
				SET @dblLateFee = @decdiffFeeAmt
				UPDATE dbo.tblNRScheduleTransaction
				SET  dblLateFeePayAmt = @latefee, dtmLateFeePaidOn = getdate() 
				WHERE intNoteId = @intNoteId and  intPaymentNo = @intPaymentNo
			END
			ELSE
			BEGIN
				UPDATE dbo.tblNRScheduleTransaction
				SET  dblLateFeePayAmt = @dblLateFee + @alreadyPaidFeeAmount, dtmLateFeePaidOn = getdate() 
				WHERE intNoteId = @intNoteId and  intPaymentNo = @intPaymentNo
				SET @dblLateFee = 0
			END
		END
		SET @latefee = 0.0
		SET @decdiffFeeAmt = 0.0
		SET @decdiffAmt = 0.0
		
	FETCH NEXT FROM curCalcInt INTO @intPaymentNo, @dtmExpectedPayDate, @dblExpectedPayAmt ,  @dblPayAmt , @SchdHst_PayDate, @dblPrincipal,@dblInterest,@dblBalance
	END
	CLOSE curCalcInt            
	DEALLOCATE curCalcInt 
	
	IF @dblPayment > 0
	BEGIN
		
		DECLARE @TempCreditLimit numeric(18,6), @TempStartDate DateTime
		, @ToSetCreditLimit numeric(18,6), @ToSetStartDate DateTime
		, @intScheduleTransId Int
		
		Select @TempCreditLimit = dblCreditLimit from dbo.tblNRNote WHERE intNoteId = @intNoteId
		Select @TempStartDate = dtmSchdStartDate from dbo.tblNRNote WHERE intNoteId = @intNoteId
		
		
		SELECT top 1 @intScheduleTransId = intScheduleTransId, @ToSetCreditLimit = (dblBalance + [dblPrincipal]), @ToSetStartDate = dtmExpectedPayDate
		FROM dbo.tblNRScheduleTransaction  
		WHERE intNoteId = @intNoteId and dtmExpectedPayDate > GETDATE() and dblExpectedPayAmt <> dblPayAmt 
		ORDER BY intPaymentNo
		DELETE FROM dbo.tblNRScheduleTransaction WHERE intScheduleTransId >= @intScheduleTransId
		IF (@ToSetCreditLimit-@dblPayment) >= 0
		BEGIN
			Update dbo.tblNRNote SET dblCreditLimit = @ToSetCreditLimit-@dblPayment WHERE intNoteId = @intNoteId
			Update dbo.tblNRNote SET dtmSchdStartDate = @ToSetStartDate WHERE intNoteId = @intNoteId
			EXEC dbo.uspNRGenerateAmortization @intNoteId
			Update dbo.tblNRNote SET dblCreditLimit = @TempCreditLimit WHERE intNoteId = @intNoteId
		Update dbo.tblNRNote SET dtmSchdStartDate = @TempStartDate WHERE intNoteId = @intNoteId
		END
	End
	
END
