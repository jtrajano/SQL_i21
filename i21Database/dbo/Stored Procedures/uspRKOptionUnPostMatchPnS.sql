CREATE PROC [dbo].uspRKOptionUnPostMatchPnS
		@strMatchedRecId nvarchar(Max)
		,@strUserName nvarchar(max)= null

AS

BEGIN TRY
	DECLARE @ErrMsg nvarchar(Max) 	
	DECLARE @intMatchNo int	


 BEGIN TRANSACTION    


INSERT INTO [tblRKStgOptionMatchPnS] (intConcurrencyId,intMatchNo,dtmMatchDate,strCurrency,strLocationName,
	strFutMarketName,strOptionMonth,strBook,strSubBook,strBrokerName,strAccountNumber,dblGrossPnL,dtmPostingDate,strUserName,ysnPost,intCommodityId)

SELECT 1,intMatchNo,dtmMatchDate,strCurrency,strLocationName,
	strFutMarketName,strOptionMonth,strBook,strSubBook,strBrokerName,strAccountNumber,dblGrossPnL ,dtmPostingDate,strUserName,0,intCommodityId  from (
select ROW_NUMBER() OVER (
			PARTITION BY intMatchNo ORDER BY dtmPostingDate DESC
			) intRowNum,intMatchNo,dtmMatchDate,strCurrency,strLocationName,
	strFutMarketName,strOptionMonth,strBook,strSubBook,strBrokerName,strAccountNumber,
	case when dblGrossPnL < 0 then abs(dblGrossPnL) else -dblGrossPnL end dblGrossPnL ,dtmPostingDate,strUserName,intCommodityId 
FROM [tblRKStgOptionMatchPnS]  WHERE intMatchNo in(
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@strMatchedRecId, ','))
	) a WHERE a.intRowNum = 1

update tblRKOptionsMatchPnS set  ysnPost = 0, dtmPostDate=null ,intMatchNo=null
WHERE intMatchNo in(
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