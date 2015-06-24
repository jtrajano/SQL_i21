CREATE PROCEDURE [dbo].[uspRKSavePnsOptionsMatched]  
	 @strXml nVarchar(Max)
AS  

BEGIN TRY  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
DECLARE @idoc int   
Declare @intOptionsMatchPnSHeaderId int  
Declare @strTranNo nVarchar(50)  
Declare @dtmMatchDate  datetime  
Declare @intMatchQty int  
Declare @intLFutOptTransactionId int  
Declare @intSFutOptTransactionId int 
Declare @strExpiredTranNo nVarchar(50)   
Declare @strExercisedAssignedNo nVarchar(50)   
Declare @ErrMsg nvarchar(Max)

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml    
  
 BEGIN TRANSACTION		
 
 ------------------------- Delete Matched ---------------------
DECLARE @tblMatchedDelete table        
		(   
	    strTranNo nvarchar(max),
		ysnDeleted Bit	
		)  

INSERT INTO @tblMatchedDelete
SELECT  
	strTranNo,
	ysnDeleted
  FROM OPENXML(@idoc,'root/DeleteMatched', 2)      
 WITH    
 ( 	
	[strTranNo] INT,
	[ysnDeleted] Bit
 )

IF EXISTS(select * from @tblMatchedDelete)
BEGIN
DELETE FROM tblRKOptionsMatchPnS
		WHERE convert(int,strTranNo) in( SELECT convert(int,strTranNo) from @tblMatchedDelete)
END
  ------------------------- END Delete Matched ---------------------
 
 ------------------------- Delete Matched ---------------------
DECLARE @tblExpiredDelete table        
		(   
	    strTranNo nvarchar(max),
		ysnDeleted Bit	
		)  

INSERT INTO @tblExpiredDelete
SELECT  
	strTranNo,
	ysnDeleted
  FROM OPENXML(@idoc,'root/DeleteExpired', 2)      
 WITH    
 ( 	
	[strTranNo] INT,
	[ysnDeleted] Bit
 )

IF EXISTS(select * from @tblExpiredDelete)
BEGIN
DELETE FROM tblRKOptionsPnSExpired
		WHERE convert(int,strTranNo) in( SELECT convert(int,strTranNo) from @tblExpiredDelete)
END
 ------------------------- END Delete Matched ---------------------------
 
 ------------------------- Delete ExercisedAssigned ---------------------
DECLARE @tblExercisedAssignedDelete table        
		(   
	    strTranNo nvarchar(max),
		ysnDeleted Bit	
		)  

INSERT INTO @tblExercisedAssignedDelete
SELECT  
	strTranNo,
	ysnDeleted
  FROM OPENXML(@idoc,'root/DeleteExercisedAssigned', 2)      
 WITH    
 ( 	
	[strTranNo] INT,
	[ysnDeleted] Bit
 )

IF EXISTS(select * from @tblExercisedAssignedDelete)
BEGIN

DELETE FROM tblRKFutOptTransaction 
WHERE intFutOptTransactionId in(SELECT intFutTransactionId 
								FROM tblRKOptionsPnSExercisedAssigned
								WHERE convert(int,strTranNo) in( SELECT convert(int,strTranNo) from @tblExercisedAssignedDelete))

DELETE FROM tblRKOptionsPnSExercisedAssigned
		WHERE convert(int,strTranNo) in( SELECT convert(int,strTranNo) from @tblExercisedAssignedDelete)
END
  ------------------------- END Delete ExercisedAssigned ---------------------
 
 ---------------Header Record Insert ----------------
 INSERT INTO tblRKOptionsMatchPnSHeader 
		(
			intConcurrencyId
		)
 VALUES
		(
		   1		
		 )

SELECT @intOptionsMatchPnSHeaderId = SCOPE_IDENTITY();  
---------------Matched Record Insert ----------------
SELECT @strTranNo=isnull(max(strTranNo),0) from tblRKOptionsMatchPnS   
 
   INSERT INTO tblRKOptionsMatchPnS
		(	
		intOptionsMatchPnSHeaderId,
		strTranNo,	
		dtmMatchDate,
		intMatchQty,
		intLFutOptTransactionId,
		intSFutOptTransactionId,
		intConcurrencyId		
		)  

 SELECT  
	@intOptionsMatchPnSHeaderId as intOptionsMatchPnSHeaderId,
	@strTranNo + ROW_NUMBER()over(order by intLFutOptTransactionId)strTranNo,
	dtmMatchDate,
	intMatchQty,
	intLFutOptTransactionId,
	intSFutOptTransactionId,
	1 as intConcurrencyId		
  FROM OPENXML(@idoc,'root/Transaction', 2)      
 WITH    
 ( 
	[intOptionsMatchPnSHeaderId] int ,
	[dtmMatchDate]  DATETIME  , 
    [intMatchQty] int , 
	[intLFutOptTransactionId] INT,
	[intSFutOptTransactionId] INT
 )   
   ---------------Expired Record Insert ----------------
 SELECT @strExpiredTranNo=isnull(max(strTranNo),0) from tblRKOptionsPnSExpired   
 
   INSERT INTO tblRKOptionsPnSExpired
		(	
		intOptionsMatchPnSHeaderId,
		strTranNo,	
		dtmExpiredDate,
		intLots,
		intFutOptTransactionId,
		intConcurrencyId		
		)  
 SELECT  
	@intOptionsMatchPnSHeaderId as intOptionsMatchPnSHeaderId,
	@strExpiredTranNo + ROW_NUMBER()over(order by intFutOptTransactionId)strTranNo,
	dtmExpiredDate,
	intLots,
	intFutOptTransactionId,	
	1 as intConcurrencyId		
  FROM OPENXML(@idoc,'root/Expired', 2)      
 WITH    
 ( 
	[dtmExpiredDate]  DATETIME  , 
    [intLots] int , 
	[intFutOptTransactionId] INT
 )   
   
   ---------------Exercised/Assigned Record Insert ----------------
DECLARE @tblExercisedAssignedDetail table        
		(   
		RowNumber int IDENTITY(1,1), 
		intFutOptTransactionId int,
		intLots int,
		dtmTranDate datetime,
		ysnAssigned Bit	
		)  
		
INSERT INTO @tblExercisedAssignedDetail
SELECT  
	intFutOptTransactionId,
	intLots,
	dtmTranDate,
	ysnAssigned	
  FROM OPENXML(@idoc,'root/ExercisedAssigned', 2)      
 WITH    
 ( 	
	[intFutOptTransactionId] INT,
	[intLots] int,
	[dtmTranDate] datetime,
	[ysnAssigned] Bit
 )
 
DECLARE @mRowNumber int,
	 @intFutOptTransactionId int,
	 @NewFutOptTransactionId int,
	 @NewFutOptTransactionHeaderId int,
	 @intLots int,
	 @dtmTranDate datetime,
	 @intInternalTradeNo int,
	 @ysnAssigned bit
 
INSERT INTO tblRKFutOptTransactionHeader
VALUES (1)
SELECT @NewFutOptTransactionHeaderId = SCOPE_IDENTITY();
 

SELECT @mRowNumber=MIN(RowNumber) FROM @tblExercisedAssignedDetail  
WHILE @mRowNumber IS NOT NULL  
BEGIN

   DECLARE @intOptionsPnSExercisedAssignedId int
   SELECT @strExercisedAssignedNo=isnull(max(strTranNo),0)+1 from tblRKOptionsPnSExercisedAssigned 
   
   SELECT @intFutOptTransactionId=intFutOptTransactionId,@intLots=intLots,@dtmTranDate=dtmTranDate,@ysnAssigned=ysnAssigned FROM @tblExercisedAssignedDetail WHERE RowNumber=@mRowNumber  
  
   INSERT INTO tblRKOptionsPnSExercisedAssigned
		(	
		intOptionsMatchPnSHeaderId,
		strTranNo,	
		dtmTranDate,
		intLots,
		intFutOptTransactionId,
		ysnAssigned,
		intConcurrencyId		
		)  
 Values(@intOptionsMatchPnSHeaderId,@strExercisedAssignedNo,@dtmTranDate,@intLots,@intFutOptTransactionId,@ysnAssigned,1)
 SELECT @intOptionsPnSExercisedAssignedId= Scope_Identity() 
 
----------------- Created Future Transaction Based on the Option Transaction ----------------------------------
 SELECT @intInternalTradeNo=Max(replace(strInternalTradeNo,'O-','')+1)  from tblRKFutOptTransaction 

 INSERT INTO tblRKFutOptTransaction (intFutOptTransactionHeaderId,intConcurrencyId,
									dtmTransactionDate,intEntityId,	intBrokerageAccountId,
									intFutureMarketId,intInstrumentTypeId,intCommodityId,
									intLocationId,intTraderId,intCurrencyId,strInternalTradeNo,
									strBrokerTradeNo,strBuySell,intNoOfContract,intFutureMonthId,intOptionMonthId,
									strOptionType,dblPrice,strReference,strStatus,
									dtmFilledDate,strReserveForFix,intBookId,intSubBookId,ysnOffset)
									
SELECT @NewFutOptTransactionHeaderId,1,@dtmTranDate,
		intEntityId,intBrokerageAccountId,intFutureMarketId, 1,intCommodityId,
		intLocationId,intTraderId,intCurrencyId,'O-'+CONVERT(nvarchar(50),@intInternalTradeNo)as strInternalTradeNo,
		strBrokerTradeNo,strBuySell,@intLots as intLots,161 as intFutureMonthId,intOptionMonthId,
		strOptionType,isnull(dblStrike,0.0) as dblStrike,
		Case when @ysnAssigned=1 THEN 'This futures transaction was the result of Option No. (Options Transaction number) being exercised on (date)' 
			else 'This futures transaction was the result of Option No. (Options Transaction number) being assigned on (date)' end strReference,
		strStatus,@dtmTranDate as dtmFilledDate,strReserveForFix,intBookId,intSubBookId,ysnOffset
		FROM tblRKFutOptTransaction WHERE intFutOptTransactionId =@intFutOptTransactionId						
   
SELECT @NewFutOptTransactionId = SCOPE_IDENTITY();  

	UPDATE tblRKOptionsPnSExercisedAssigned  set intFutTransactionId = @NewFutOptTransactionId Where intOptionsPnSExercisedAssignedId=@intOptionsPnSExercisedAssignedId
  
SELECT @mRowNumber=MIN(RowNumber) FROM @tblExercisedAssignedDetail WHERE RowNumber>@mRowNumber  
END  
   
COMMIT TRAN  
  
EXEC sp_xml_removedocument @idoc   
  
END TRY    
    
BEGIN CATCH    
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION        
 SET @ErrMsg = ERROR_MESSAGE()    
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc    
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
    
END CATCH

