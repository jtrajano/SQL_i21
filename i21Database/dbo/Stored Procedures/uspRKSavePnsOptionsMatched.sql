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
  
IF EXISTS(select * from @tblExpiredDelete)  
BEGIN  
DELETE FROM tblRKOptionsPnSExpired  
  WHERE convert(int,strTranNo) in( SELECT convert(int,strTranNo) from @tblExpiredDelete)  
END  
 ------------------------- END Delete Expired ---------------------------  
   
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

SELECT intFutOptTransactionHeaderId into #temp FROM tblRKFutOptTransaction   
WHERE intFutOptTransactionId in(SELECT intFutTransactionId   
        FROM tblRKOptionsPnSExercisedAssigned  
        WHERE convert(int,strTranNo) in(SELECT convert(int,strTranNo) from @tblExercisedAssignedDelete))  
		 

DELETE FROM tblRKFutOptTransaction   
WHERE intFutOptTransactionId in(SELECT intFutTransactionId   
        FROM tblRKOptionsPnSExercisedAssigned  
        WHERE convert(int,strTranNo) in( SELECT convert(int,strTranNo) from @tblExercisedAssignedDelete))  

--delete from tblRKFutOptTransactionHeader where intFutOptTransactionHeaderId in(SELECT f.intFutOptTransactionHeaderId FROM tblRKFutOptTransaction f
--																				JOIN #temp t on f.intFutOptTransactionHeaderId=t.intFutOptTransactionHeaderId 
--																				group by f.intFutOptTransactionHeaderId having count(f.intFutOptTransactionHeaderId)<= 0)

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
 SELECT @strExpiredTranNo=isnull(max(convert(int,strTranNo)),0) from tblRKOptionsPnSExpired     
   
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
   

   
  
SELECT @mRowNumber=MIN(RowNumber) FROM @tblExercisedAssignedDetail    
WHILE @mRowNumber IS NOT NULL    
BEGIN  
	
   DECLARE @intOptionsPnSExercisedAssignedId int  
   
   SELECT @strExercisedAssignedNo=isnull(max(convert(int,strTranNo)),0)+1 from tblRKOptionsPnSExercisedAssigned     
   SELECT @intFutOptTransactionId=intFutOptTransactionId,@intLots=intLots,@dtmTranDate=dtmTranDate,@ysnAssigned=ysnAssigned FROM @tblExercisedAssignedDetail WHERE RowNumber=@mRowNumber    

   	INSERT INTO tblRKFutOptTransactionHeader (intConcurrencyId,dtmTransactionDate,intSelectedInstrumentTypeId,strSelectedInstrumentType)  
	VALUES (1,@dtmTranDate,1,'Exchange Traded')  
	SELECT @NewFutOptTransactionHeaderId = SCOPE_IDENTITY();  

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
 
 DECLARE @intTransactionId nvarchar(50)  
 set @strTranNo=''  
 select @strTranNo=strTranNo from tblRKOptionsPnSExercisedAssigned where intOptionsPnSExercisedAssignedId=@intOptionsPnSExercisedAssignedId  
       
----------------- Created Future Transaction Based on the Option Transaction ----------------------------------  

 SELECT @intInternalTradeNo = intNumber
							  from tblSMStartingNumber  where strModule='Risk Management' and strTransactionType='FutOpt Transaction'
 INSERT INTO tblRKFutOptTransaction (intFutOptTransactionHeaderId,intConcurrencyId,intSelectedInstrumentTypeId,  
         dtmTransactionDate,intEntityId, intBrokerageAccountId,  
         intFutureMarketId,intInstrumentTypeId,intCommodityId,  
         intLocationId,intTraderId,intCurrencyId,strInternalTradeNo,  
         strBrokerTradeNo,strBuySell,intNoOfContract,intFutureMonthId,intOptionMonthId,  
         strOptionType,dblPrice,strReference,strStatus,  
         dtmFilledDate,strReserveForFix,intBookId,intSubBookId,ysnOffset,dtmCreateDateTime)  
           
SELECT @NewFutOptTransactionHeaderId,1,1,@dtmTranDate,  
  t.intEntityId,t.intBrokerageAccountId,t.intFutureMarketId, 1,t.intCommodityId,  
  t.intLocationId,t.intTraderId,t.intCurrencyId,'O-'+CONVERT(nvarchar(50),@intInternalTradeNo)as strInternalTradeNo,  
  t.strBrokerTradeNo,t.strBuySell,@intLots as intLots,om.intFutureMonthId as intFutureMonthId,t.intOptionMonthId,  
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

	SELECT @intInternalTradeNo1 = Max(convert(int,REPLACE(REPLACE(REPLACE(strInternalTradeNo,'-S' ,''),'O-' ,''),'-H',''))) + 1  from tblRKFutOptTransaction
	UPDATE tblSMStartingNumber set intNumber = @intInternalTradeNo1 where strModule='Risk Management' and strTransactionType='FutOpt Transaction'
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