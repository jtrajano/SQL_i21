CREATE PROCEDURE [dbo].[uspNRGetDetailsForPayment]
@intNoteId Int       
AS        
BEGIN            
    
 DECLARE @intPaymentNo int, @dblExpectedPayAmt numeric(18,6),     
 @dblPayAmt numeric(18,6), @strSchdLateAppliedOn char(30), @strSchdLateFeeUnit char(10) ,    
 @intSchdGracePeriod int, @latefee numeric(18,6), @dblSchdLateFee numeric(18,6) , @dblPrincipal numeric(18,6)
 , @dblInterest numeric(18,6), @dblBalance numeric(18,6),@dtmExpectedPayDate datetime    
 ,@dtmPaidOn datetime ,@dtmLateFeePaidOn datetime , @dblLateFeePayAmt numeric(18,6)
 
 DECLARE @IntSum Decimal(18,5)  
 DECLARE @AmtAppInt decimal(18,5)    
 DECLARE @InterestAdjustment Decimal(18,2)
 
 Select Top 1 *  from dbo.tblNRNoteTransaction Where intNoteId=@intNoteId Order By intNoteTransId desc   
   
    
	SELECT @InterestAdjustment = SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId AND intNoteTransTypeId = 7 
	AND strAdjOnPrincOrInt = 'Interest'    
   
	SELECT @AmtAppInt=SUM(dblAmtAppToInterest) FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId   AND intNoteTransTypeId = 4

	SELECT @IntSum = SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId   
	
	SELECT (ISNULL(@IntSum ,0) + ISNULL(@InterestAdjustment,0)) as 'InterestSum' ,ISNULL (@AmtAppInt,0)AS 'AmtAppInt' 

       
 SELECT @intSchdGracePeriod = intSchdGracePeriod, @strSchdLateFeeUnit = strSchdLateFeeUnit
 , @strSchdLateAppliedOn = strSchdLateAppliedOn, @dblSchdLateFee = dblSchdLateFee    
 FROM dbo.tblNRNote WHERE intNoteId = @intNoteId      
   
 DECLARE @tbl AS TABLE (intPaymentNumber int, dtmExpectedPayDate Date, dblAmount numeric(18,6), dblLateCharge numeric(18,6) )    
    
 DECLARE curCalcInt CURSOR FOR      
 SELECT intPaymentNo       
   , dtmExpectedPayDate       
   , dblExpectedPayAmt    
   , dblPayAmt 
   , dtmPaidOn   
   ,[dblPrincipal]    
   ,[dblInterest]    
   ,[dblBalance]    
   ,[dblLateFeeGenerated]  
   ,dtmLateFeePaidOn
   ,dblLateFeePayAmt
FROM dbo.tblNRScheduleTransaction     
WHERE intNoteId = @intNoteId  and dtmExpectedPayDate <= GETDATE() 
--and dblExpectedPayAmt <> dblPayAmt    
     
 OPEN curCalcInt      
 FETCH NEXT FROM curCalcInt INTO @intPaymentNo, @dtmExpectedPayDate, @dblExpectedPayAmt   
 ,  @dblPayAmt ,@dtmPaidOn, @dblPrincipal,@dblInterest,@dblBalance, @latefee    , @dtmLateFeePaidOn, @dblLateFeePayAmt
 WHILE(@@FETCH_STATUS = 0)         
 BEGIN     
  IF @dtmLateFeePaidOn is null
  BEGIN  
   IF @strSchdLateFeeUnit = '$'    
   BEGIN    
    IF @dblPayAmt = 0.0    
    BEGIN    
     IF DATEDIFF(day, @dtmExpectedPayDate,GETDATE()) > @intSchdGracePeriod    
      SET @latefee = @dblSchdLateFee    
    END  
    ELSE
    BEGIN
     IF DATEDIFF(day, @dtmExpectedPayDate,@dtmPaidOn) > @intSchdGracePeriod    
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
     IF DATEDIFF(day, @dtmExpectedPayDate,@dtmPaidOn) > @intSchdGracePeriod    
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
    IF DATEDIFF(day, @dtmExpectedPayDate,@dtmPaidOn) > @intSchdGracePeriod    
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
    IF DATEDIFF(day, @dtmExpectedPayDate,@dtmPaidOn) > @intSchdGracePeriod    
          SET @latefee = @dblSchdLateFee * @dblInterest / 100      
    END         
    END    
   END    
  END  
  else
  begin
  set @latefee = 0
  end
    
  INSERT INTO @tbl VALUES (@intPaymentNo, CONVERT(varchar(10), @dtmExpectedPayDate, 101), @dblExpectedPayAmt - @dblPayAmt, @latefee)    
       
  SET @latefee = 0.0    
   
 FETCH NEXT FROM curCalcInt INTO @intPaymentNo, @dtmExpectedPayDate, @dblExpectedPayAmt   
 ,  @dblPayAmt ,@dtmPaidOn, @dblPrincipal,@dblInterest,@dblBalance, @latefee    , @dtmLateFeePaidOn, @dblLateFeePayAmt
     
 END    
   
 CLOSE curCalcInt                
 DEALLOCATE curCalcInt     
    
	Select * from @tbl   
	
	Select ISNULL(SUM(dblAmount),0) [ExpectedPayAmount], ISNULL(SUM(dblLateCharge),0) [LateCharges] from @tbl 
  
	--Get Pending NSF Charges  
	Select a.intNoteTransId, a.intNoteId, a.dtmNoteTranDate AS [dtmChargeAppliedOn]  
	, ISNULL(a.dblTransAmount,0) AS [dblNSFCharge]   
	, b.dtmNoteTranDate AS [dtmChargePaidOn]  
	, ISNULL(b.dblTransAmount,0) AS [dblChargePaid]  
	from dbo.tblNRNoteTransaction a  
	LEFT JOIN dbo.tblNRNoteTransaction b ON a.intNoteId = b.intNoteId AND b.intNoteTransTypeId = 4  
	AND a.intNoteTransId = b.strRefNo  
	LEFT JOIN dbo.tblNRAdjustmentType at on at.intAdjTypeId = a.intAdjTypeId
	WHERE at.strAdjShowAs = 'NSF Charges' AND a.intNoteTransTypeId = 7 AND a.intNoteId = @intNoteId  
  
	--Get Pending Balloon Payment  
	Select top 1 * from dbo.tblNRScheduleTransaction   
	WHERE intNoteId = @intNoteId AND dtmExpectedPayDate > GETDATE()   
	AND intScheduleTransId NOT IN (Select strRefNo from dbo.tblNRNoteTransaction nt
	JOIN dbo.tblNRAdjustmentType at ON at.intAdjTypeId = nt.intAdjTypeId
	WHERE nt.intNoteId = @intNoteId AND at.strAdjShowAs = 'Balloon Payment')  
	AND dblBalance > 0  
	ORDER BY intScheduleTransId DESC  

	--Get Max Payment Amount
	SELECT ISNULL(( SUM(isnull(dblExpectedPayAmt,0)) - SUM(isnull(dblPayAmt ,0)) ),0) [dblMaxPayment]
	FROM dbo.tblNRScheduleTransaction      
	WHERE intNoteId = @intNoteId
	
	--Get Interest Calculation Details
	declare @dtmCurrentDate Datetime
	SET @dtmCurrentDate =  GETDATE()
	EXEC [dbo].[uspNRCalculateInterest] @intNoteId,@dtmCurrentDate, 4, ''
	
	

End

