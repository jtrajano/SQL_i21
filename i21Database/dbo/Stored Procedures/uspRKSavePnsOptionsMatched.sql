CREATE PROCEDURE [dbo].[uspRKSavePnsOptionsMatched]    
  @strXml nVarchar(Max),
  @strTranNoPNS nVarchar(50) OUT
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
Declare @dblMatchQty numeric(18,6)    
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
  strTranNo nvarchar(max)  COLLATE Latin1_General_CI_AS NOT NULL,  
  userName nvarchar(50),
  ysnDeleted Bit   
  )    
  
INSERT INTO @tblMatchedDelete  
SELECT    
 strTranNo,
 userName,  
 ysnDeleted  
 FROM OPENXML(@idoc,'root/DeleteMatched', 2)        
 WITH      
 (    
 [strTranNo] INT,  
 [userName] nvarchar(100),
 [ysnDeleted] BIT  
 )  
  
IF EXISTS(SELECT * FROM @tblMatchedDelete)  
BEGIN  

INSERT INTO tblRKMatchDerivativesHistoryForOption (intOptionsMatchPnSHeaderId,intMatchOptionsPnSId,dblMatchQty,dtmMatchDate,intLFutOptTransactionId,intSFutOptTransactionId,dtmTransactionDate,strUserName)

SELECT intOptionsMatchPnSHeaderId,intMatchOptionsPnSId,-(dblMatchQty),dtmMatchDate,intLFutOptTransactionId,intSFutOptTransactionId,getdate(),userName
FROM tblRKOptionsMatchPnS  p
JOIN @tblMatchedDelete m on p.strTranNo=m.strTranNo

DELETE FROM tblRKOptionsMatchPnS  WHERE CONVERT(INT,strTranNo) in( SELECT CONVERT(INT,strTranNo) FROM @tblMatchedDelete)  
END  
------------------------- END Delete Matched ---------------------  
   
------------------------- Delete Expired ---------------------  
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
  
IF EXISTS(SELECT * FROM @tblExpiredDelete)  
BEGIN  
DELETE FROM tblRKOptionsPnSExpired  
  WHERE CONVERT(INT,strTranNo) in( SELECT CONVERT(INT,strTranNo) FROM @tblExpiredDelete)  
END  
 ------------------------- END Delete Expired ---------------------------  
   
 ------------------------- Delete ExercisedAssigned ---------------------  
DECLARE @tblExercisedAssignedDelete table          
  (     
     strTranNo NVARCHAR(MAX),  
	 ysnDeleted BIT   
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
 
  
IF EXISTS(SELECT * FROM @tblExercisedAssignedDelete)  
BEGIN  

SELECT intFutOptTransactionHeaderId into #temp FROM tblRKFutOptTransaction   
WHERE intFutOptTransactionId in(SELECT intFutTransactionId   
        FROM tblRKOptionsPnSExercisedAssigned  
        WHERE convert(int,strTranNo) in(SELECT convert(int,strTranNo) from @tblExercisedAssignedDelete))  
		 

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

SELECT @strTranNo=isnull(max(convert(int,strTranNo)),0) from tblRKOptionsMatchPnS   
   
   INSERT INTO tblRKOptionsMatchPnS  
  (   
  intOptionsMatchPnSHeaderId,  
  strTranNo,   
  dtmMatchDate,  
  dblMatchQty,  
  intLFutOptTransactionId,  
  intSFutOptTransactionId,  
  intConcurrencyId      
  )    
  
 SELECT    
 @intOptionsMatchPnSHeaderId as intOptionsMatchPnSHeaderId,  
 @strTranNo + ROW_NUMBER()over(order by intLFutOptTransactionId)strTranNo,  
 dtmMatchDate,  
 dblMatchQty,  
 intLFutOptTransactionId,  
 intSFutOptTransactionId,   
 1 as intConcurrencyId 
   
  FROM OPENXML(@idoc,'root/Transaction', 2)        
 WITH      
 (   
 [intOptionsMatchPnSHeaderId] int ,  
 [dtmMatchDate]  DATETIME  ,   
 [dblMatchQty] numeric(18,6) ,   
 [intLFutOptTransactionId] INT,  
 [intSFutOptTransactionId] INT 
 )     

declare @strName nvarchar(100) =''
  SELECT    
	@strName=[userName]
  FROM OPENXML(@idoc,'root/Transaction', 2)        
 WITH      
 (   
 [userName] nvarchar(max)  
 ) 

 declare @intOptMPNSId INT
 select @intOptMPNSId = scope_identity()
 SELECT TOP 1 @strTranNoPNS =strTranNo FROM tblRKOptionsMatchPnS WHERE intMatchOptionsPnSId = @intOptMPNSId
 
 INSERT INTO tblRKMatchDerivativesHistoryForOption (intOptionsMatchPnSHeaderId,intMatchOptionsPnSId,dblMatchQty,dtmMatchDate,intLFutOptTransactionId,intSFutOptTransactionId,dtmTransactionDate,strUserName)
 SELECT intOptionsMatchPnSHeaderId,intMatchOptionsPnSId,dblMatchQty,dtmMatchDate,intLFutOptTransactionId,intSFutOptTransactionId,getdate(),@strName
FROM tblRKOptionsMatchPnS where strTranNo=@strTranNoPNS

   ---------------Expired Record Insert ----------------  
 SELECT @strExpiredTranNo=isnull(max(convert(int,strTranNo)),0) from tblRKOptionsPnSExpired     
   
   INSERT INTO tblRKOptionsPnSExpired  
  (   
  intOptionsMatchPnSHeaderId,  
  strTranNo,   
  dtmExpiredDate,  
  dblLots,  
  intFutOptTransactionId,  
  intConcurrencyId    
  )    
 SELECT    
 @intOptionsMatchPnSHeaderId as intOptionsMatchPnSHeaderId,  
 @strExpiredTranNo + ROW_NUMBER()over(order by intFutOptTransactionId)strTranNo,  
 dtmExpiredDate,  
 dblLots,  
 intFutOptTransactionId,   
 1 as intConcurrencyId    
  FROM OPENXML(@idoc,'root/Expired', 2)        
 WITH      
 (   
 [dtmExpiredDate]  DATETIME  ,   
    [dblLots] numeric(18,6) ,   
 [intFutOptTransactionId] INT  
 )     
 
   ---------------Exercised/Assigned Record Insert ----------------  
DECLARE @tblExercisedAssignedDetail table          
  (     
  RowNumber int IDENTITY(1,1),   
  intFutOptTransactionId int,  
  dblLots numeric(18,6),  
  dtmTranDate datetime,  
  ysnAssigned Bit   
  )    
    
INSERT INTO @tblExercisedAssignedDetail  
SELECT    
 intFutOptTransactionId,  
 dblLots,  
 dtmTranDate,  
 ysnAssigned   
  FROM OPENXML(@idoc,'root/ExercisedAssigned', 2)        
 WITH      
 (    
 [intFutOptTransactionId] INT,  
 [dblLots] numeric(18,6),  
 [dtmTranDate] datetime,  
 [ysnAssigned] Bit  
 )  
   
DECLARE @mRowNumber int,  
  @intFutOptTransactionId int,  
  @NewFutOptTransactionId int,  
  @NewFutOptTransactionHeaderId int,  
  @dblLots numeric(18,6),  
  @dtmTranDate datetime,  
  @intInternalTradeNo int,  
  @ysnAssigned bit  
   

   
  
SELECT @mRowNumber=MIN(RowNumber) FROM @tblExercisedAssignedDetail    
WHILE @mRowNumber IS NOT NULL    
BEGIN  
	
   DECLARE @intOptionsPnSExercisedAssignedId int  
   DECLARE @strSelectedInstrumentType nvarchar(100)
   DECLARE @intSelectedInstrumentTypeId int
   SELECT @strExercisedAssignedNo=isnull(max(convert(int,strTranNo)),0)+1 from tblRKOptionsPnSExercisedAssigned     
   SELECT @intFutOptTransactionId=intFutOptTransactionId,@dblLots=dblLots,@dtmTranDate=dtmTranDate,@ysnAssigned=ysnAssigned FROM @tblExercisedAssignedDetail WHERE RowNumber=@mRowNumber    
   SELECT @intSelectedInstrumentTypeId=intSelectedInstrumentTypeId 
		  ,@strSelectedInstrumentType =CASE WHEN ISNULL(intSelectedInstrumentTypeId, 1) = 1 then 'Exchange Traded'
										WHEN intSelectedInstrumentTypeId = 2 THEN 'OTC'
										ELSE 'OTC - Others' END
			FROM tblRKFutOptTransaction where intFutOptTransactionId=@intFutOptTransactionId

   	INSERT INTO tblRKFutOptTransactionHeader (intConcurrencyId,dtmTransactionDate,intSelectedInstrumentTypeId,strSelectedInstrumentType)  
	VALUES (1,@dtmTranDate,@intSelectedInstrumentTypeId,@strSelectedInstrumentType)  
	SELECT @NewFutOptTransactionHeaderId = SCOPE_IDENTITY();  

  INSERT INTO tblRKOptionsPnSExercisedAssigned  
  (   
  intOptionsMatchPnSHeaderId,  
  strTranNo,   
  dtmTranDate,  
  dblLots,  
  intFutOptTransactionId,  
  ysnAssigned,  
  intConcurrencyId    
  )    
 Values(@intOptionsMatchPnSHeaderId,@strExercisedAssignedNo,@dtmTranDate,@dblLots,@intFutOptTransactionId,@ysnAssigned,1)  
 SELECT @intOptionsPnSExercisedAssignedId= Scope_Identity()   
 
 DECLARE @intTransactionId nvarchar(50)  
 set @strTranNo=''  
 select @strTranNo=strTranNo from tblRKOptionsPnSExercisedAssigned where intOptionsPnSExercisedAssignedId=@intOptionsPnSExercisedAssignedId  
       
----------------- Created Future Transaction Based on the Option Transaction ----------------------------------  

 SELECT @intInternalTradeNo = intNumber
							  from tblSMStartingNumber  where  intStartingNumberId=45
 INSERT INTO tblRKFutOptTransaction (intFutOptTransactionHeaderId,intConcurrencyId,intSelectedInstrumentTypeId,  
         dtmTransactionDate,intEntityId, intBrokerageAccountId,  
         intFutureMarketId,intInstrumentTypeId,intCommodityId,  
         intLocationId,intTraderId,intCurrencyId,strInternalTradeNo,  
         strBrokerTradeNo,strBuySell,dblNoOfContract,intFutureMonthId,intOptionMonthId,  
         strOptionType,dblPrice,strReference,strStatus,  
         dtmFilledDate,strReserveForFix,intBookId,intSubBookId,ysnOffset,dtmCreateDateTime)  
           
SELECT @NewFutOptTransactionHeaderId,1,@intSelectedInstrumentTypeId,@dtmTranDate,  
  t.intEntityId,t.intBrokerageAccountId,t.intFutureMarketId, 1,t.intCommodityId,  
  t.intLocationId,t.intTraderId,t.intCurrencyId,'O-'+CONVERT(nvarchar(50),@intInternalTradeNo)as strInternalTradeNo,  
  t.strBrokerTradeNo,t.strBuySell,@dblLots as dblLots,om.intFutureMonthId as intFutureMonthId,t.intOptionMonthId,  
  t.strOptionType,isnull(t.dblStrike,0.0) as dblStrike,  
  Case when strBuySell = 'Buy'  THEN 'This futures transaction was the result of Option No. ('+@strTranNo+') being exercised on ('+ convert(nvarchar,@dtmTranDate,101) +')'   
   else 'This futures transaction was the result of Option No. ('+@strTranNo+') being assigned on ('+ convert(nvarchar,@dtmTranDate,101) +')' end strReference,  
  t.strStatus,@dtmTranDate as dtmFilledDate,t.strReserveForFix,t.intBookId,t.intSubBookId,t.ysnOffset,getdate()  
  FROM tblRKFutOptTransaction t  
  JOIN tblRKOptionsMonth om on t.intOptionMonthId=om.intOptionMonthId WHERE intFutOptTransactionId =@intFutOptTransactionId        
     
SELECT @NewFutOptTransactionId = SCOPE_IDENTITY();  

	DECLARE @NewBuySell nvarchar(15)=''
	DECLARE @intInternalTradeNo1 int  

	SELECT @NewBuySell= CASE WHEN (strBuySell = 'Buy' AND strOptionType= 'Call') THEN 'Buy'   
		   WHEN (strBuySell = 'Buy' AND strOptionType= 'Put') THEN 'Sell'   
		   WHEN (strBuySell = 'Sell' AND strOptionType= 'Call') THEN 'Sell'   
		   WHEN (strBuySell = 'Sell' AND strOptionType= 'Put') THEN 'Buy' End  
		   FROM tblRKFutOptTransaction Where intFutOptTransactionId=@NewFutOptTransactionId  

	--SELECT @intInternalTradeNo1 = Max(convert(numeric(24,10),REPLACE(REPLACE(REPLACE(strInternalTradeNo,'-S' ,''),'O-' ,''),'-H',''))) + 1  from tblRKFutOptTransaction
	UPDATE tblSMStartingNumber set intNumber = isnull(intNumber,0)+ 1 where intStartingNumberId=45
	UPDATE tblRKFutOptTransaction  set strBuySell=@NewBuySell,strOptionType=null,intOptionMonthId=null Where intFutOptTransactionId = @NewFutOptTransactionId   
	UPDATE tblRKOptionsPnSExercisedAssigned set intFutTransactionId= @NewFutOptTransactionId Where intOptionsPnSExercisedAssignedId=@intOptionsPnSExercisedAssignedId
	SELECT @mRowNumber = MIN(RowNumber) FROM @tblExercisedAssignedDetail WHERE RowNumber>@mRowNumber    
END    
     
COMMIT TRAN    
    
EXEC sp_xml_removedocument @idoc     
    
END TRY      
      
BEGIN CATCH  
   
 SET @ErrMsg = ERROR_MESSAGE()  
 IF XACT_STATE() != 0 ROLLBACK TRANSACTION  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 If @ErrMsg != ''   
 BEGIN  
  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
 END  
   
END CATCH  
GO