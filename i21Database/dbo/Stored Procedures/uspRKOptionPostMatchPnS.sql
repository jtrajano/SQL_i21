CREATE PROC [dbo].[uspRKOptionPostMatchPnS]
		@strMatchedRecId nvarchar(Max)

AS

BEGIN TRY
	DECLARE @ErrMsg nvarchar(Max) 	
	DECLARE @intMatchNo int	
    DECLARE @strUserName nvarchar(Max) 	

SELECT TOP 1 @strUserName=strExternalERPId from tblEMEntity where strName=@strUserName

SELECT @intMatchNo=isnull(max(intMatchNo),0)  from tblRKStgOptionMatchPnS 

 BEGIN TRANSACTION    

SELECT ROW_NUMBER() OVER (ORDER BY strFutMarketName) + @intMatchNo intMatchNo,dtmMatchDate,strCurrency,strLocationName,
	strFutMarketName,strOptionMonth,strBook,strSubBook,strBrokerName,strAccountNumber,dblGrossPnL,getdate() dtmPostingDate,@strUserName strUserName into #temp
 FROM (
SELECT 
dtmMatchDate,
	strCurrency,
strLocationName,strAccountNumber,strFutMarketName,strOptionMonth,strMLBook strBook,strMLSubBook strSubBook,
strName strBrokerName ,sum(dblImpact) dblGrossPnL
FROM vyuRKSOptionMatchedTransaction ft
JOIN tblSMCurrency c on c.intCurrencyID=CASE WHEN ft.ysnSubCurrency=1 then (select intMainCurrencyId from tblSMCurrency where ysnSubCurrency=1) else intCurrencyId end
WHERE intMatchOptionsPnSId in(
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@strMatchedRecId, ',')) 
GROUP BY dtmMatchDate,strCurrency,strLocationName,strFutMarketName,strOptionMonth,strMLBook,strMLSubBook,strName,strAccountNumber)t

INSERT INTO [tblRKStgOptionMatchPnS] (intConcurrencyId,intMatchNo,dtmMatchDate,strCurrency,strLocationName,
	strFutMarketName,strOptionMonth,strBook,strSubBook,strBrokerName,strAccountNumber,dblGrossPnL,dtmPostingDate,strUserName)
select 1,intMatchNo,dtmMatchDate,strCurrency,strLocationName,
	strFutMarketName,strOptionMonth,strBook,strSubBook,strBrokerName,strAccountNumber,dblGrossPnL,dtmPostingDate,strUserName from #temp

UPDATE tblRKOptionsMatchPnS
SET intMatchNo = t2.intMatchNo, ysnPost = 1, dtmPostDate=GetDATE()

FROM tblRKOptionsMatchPnS t1
join vyuRKSOptionMatchedTransaction mt on t1.intMatchOptionsPnSId=mt.intMatchOptionsPnSId
INNER JOIN #temp t2 ON t1.dtmMatchDate = t2.dtmMatchDate and
mt.strLocationName = t2.strLocationName and 
mt.strFutMarketName = t2.strFutMarketName and 
mt.strOptionMonth = t2.strOptionMonth and 
isnull(mt.strMLBook,'') = isnull(t2.strBook,'') and 
isnull(mt.strMLSubBook,'') = isnull(t2.strSubBook,'') and 
mt.strName = t2.strBrokerName and 
mt.strAccountNumber = t2.strAccountNumber 
WHERE  t1.intMatchOptionsPnSId in(
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@strMatchedRecId, ','))



COMMIT TRAN    
      
    
END TRY      
      
BEGIN CATCH  
   
 SET @ErrMsg = ERROR_MESSAGE()  
 IF XACT_STATE() != 0 ROLLBACK TRANSACTION  
 If @ErrMsg != ''   
 BEGIN  
  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
 END  
   
END CATCH  