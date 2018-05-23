CREATE PROC uspRKMatchingLotAvailableQtyValidation
	@intLFutOptTransactionId int =null,
	@intSFutOptTransactionId int = null,	
	@dblMatchQty numeric(24,10),
	@strType nvarchar(30),
	@ErrMsg nvarchar output
AS

BEGIN TRY
DECLARE @ErrMsg1 nvarchar(Max)  
declare @strInternalTradeNo nvarchar(50)
declare @intOpenContract int
declare @msg nvarchar(max)   
IF(SELECT ABS(intOpenContract) FROM vyuRKGetMatchingLotAvailableQty where intFutOptTransactionId=@intLFutOptTransactionId and strType = @strType) < @dblMatchQty
BEGIN
	RAISERROR('Selected lots are no longer available for matching.',16,1)
END
ELSE IF(SELECT ABS(intOpenContract) FROM vyuRKGetMatchingLotAvailableQty where intFutOptTransactionId=@intSFutOptTransactionId and strType = @strType) < @dblMatchQty
BEGIN

	RAISERROR('Selected lots are no longer available for matching.',16,1)
END
END TRY

BEGIN CATCH  
   
 SET @ErrMsg1 = ERROR_MESSAGE()  
 If @ErrMsg1 != ''   
 BEGIN  
  RAISERROR(@ErrMsg1, 16, 1, 'WITH NOWAIT')  
 END  
   
END CATCH