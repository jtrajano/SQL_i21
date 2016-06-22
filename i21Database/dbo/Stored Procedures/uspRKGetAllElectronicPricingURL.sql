CREATE PROCEDURE [dbo].[uspRKGetAllElectronicPricingURL] 
	 @FutureMarketId INT
	,@intUserId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @strPassword NVARCHAR(100)
	DECLARE @IntinterfaceSystem INT
	DECLARE @StrQuoteProvider NVARCHAR(100)
	DECLARE @StrTradedMonthSymbol NVARCHAR(1000)
	DECLARE @MarketExchangeCode NVARCHAR(10)
	DECLARE @Commoditycode NVARCHAR(10)
	DECLARE @URL NVARCHAR(1000)
	DECLARE @SymbolPrefix NVARCHAR(5)
	DECLARE @UserIdCaption nvarchar(50)
	
	SELECT @Commoditycode = strFutSymbol,@SymbolPrefix=strSymbolPrefix
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId		
		
	SELECT @URL = strInterfaceWebServicesURL FROM tblRKCompanyPreference
	
	SELECT @UserIdCaption = strUserName FROM tblRKCompanyPreference

	SELECT @strUserName = strProviderUserId FROM tblGRUserPreference Where [intEntityUserSecurityId]= @intUserId 
	
	SELECT @strPassword = strProviderPassword FROM tblGRUserPreference Where [intEntityUserSecurityId]=@intUserId  
	IF @strPassword = ''
			SET @strPassword = '?&Type=F'
	
    SELECT @URL + @UserIdCaption+'=' + @strUserName + '&Password=' + @strPassword + '&Symbol='+@SymbolPrefix + @Commoditycode + strSymbol+RIGHT(intYear,1) as URL,strFutureMonth strFutureMonthYearWOSymbol,intFutureMonthId as intFutureMonthId from tblRKFuturesMonth where intFutureMarketId=1 and dtmFutureMonthsDate >= getdate() and ysnExpired = 0 
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKGetAllElectronicPricingURL: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH