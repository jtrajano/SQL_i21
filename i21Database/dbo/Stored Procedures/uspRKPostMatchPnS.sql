CREATE PROC [dbo].[uspRKPostMatchPnS]
		@intMatchNo int,
		@dblGrossPL numeric(24,10),
		@dblNetPnL numeric(24,10),
		@strUserName nvarchar(100) = null

AS
BEGIN TRY
	DECLARE @ErrMsg nvarchar(Max) 	
	DECLARE @intCurrencyId int 
	DECLARE @strCurrency nvarchar(50),
		    @BrokerName nvarchar(100),
			@BrokerAccount nvarchar(100),
			@strBook nvarchar(100),
			@strSubBook nvarchar(100),
			@strLocationName nvarchar(100),
			@strFutMarketName nvarchar(100)

	SELECT TOP 1 @strUserName=strExternalERPId from tblEMEntity where strName=@strUserName

	SELECT @intCurrencyId = intCurrencyId,@BrokerAccount=strClearingAccountNumber,@BrokerName=strName,@strBook=strBook, @strSubBook=strSubBook ,@strFutMarketName=strFutMarketName
				,@strLocationName=strLocationName
	FROM tblRKMatchFuturesPSHeader h
	JOIN tblRKFutureMarket fm on h.intFutureMarketId=fm.intFutureMarketId 
	JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=h.intBrokerageAccountId
	join tblEMEntity e on h.intEntityId=e.intEntityId
	JOIN tblSMCompanyLocation l on l.intCompanyLocationId=h.intCompanyLocationId
	left join tblCTBook b on b.intBookId=h.intBookId
	LEFT JOIN tblCTSubBook sb on sb.intSubBookId=h.intSubBookId
	
	WHERE intMatchNo=@intMatchNo

	IF EXISTS (SELECT * FROM tblSMCurrency where intCurrencyID=@intCurrencyId)
	BEGIN
		IF EXISTS(SELECT * FROM tblSMCurrency where intCurrencyID=@intCurrencyId and ysnSubCurrency=1)
		BEGIN
			SELECT @intCurrencyId=intMainCurrencyId FROM tblSMCurrency where intCurrencyID=@intCurrencyId and ysnSubCurrency=1
		END
	END

	SELECT @strCurrency=strCurrency FROM tblSMCurrency where intCurrencyID=@intCurrencyId


 BEGIN TRANSACTION    
	INSERT INTO tblRKStgMatchPnS (intConcurrencyId,intMatchFuturesPSHeaderId,intMatchNo,dtmMatchDate,strCurrency,intCompanyLocationId,intCommodityId,intFutureMarketId,intFutureMonthId,
									intEntityId,intBrokerageAccountId,dblMatchQty,dblNetPnL,dblGrossPnL,strStatus,strBrokerName,strBrokerAccount,dtmPostingDate,strUserName,strBook,strSubBook,strLocationName,strFutMarketName)

	SELECT 0,intMatchFuturesPSHeaderId,intMatchNo,dtmMatchDate,@strCurrency,intCompanyLocationId,intCommodityId,intFutureMarketId,intFutureMonthId,intEntityId,intBrokerageAccountId,
	ISNULL((SELECT SUM(ISNULL(dblMatchQty,0)) FROM tblRKMatchFuturesPSDetail m WHERE intMatchFuturesPSHeaderId=h.intMatchFuturesPSHeaderId),0) dblMatchQty
	,@dblNetPnL,@dblGrossPL,'',@BrokerName,@BrokerAccount,getdate(),@strUserName,@strBook,@strSubBook,@strFutMarketName,@strLocationName  FROM tblRKMatchFuturesPSHeader h WHERE intMatchNo=@intMatchNo

	UPDATE tblRKMatchFuturesPSHeader SET ysnPosted = 1 WHERE intMatchNo=@intMatchNo

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