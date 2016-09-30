CREATE PROCEDURE [dbo].[uspRKGetElectronicPricingURL]
	 @FutureMarketId INT
	,@FutureMonthId INT
	,@strFutSymbol Nvarchar(5) = NULL
	,@strSymbolPrefix Nvarchar(5) = NULL
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

	SET @strFutSymbol=ISNULL(@strFutSymbol,'')
	SET @strSymbolPrefix=ISNULL(@strSymbolPrefix,'')

	SELECT 
	 @Commoditycode = CASE WHEN @strFutSymbol='' THEN strFutSymbol ELSE @strFutSymbol END
	,@SymbolPrefix=   CASE WHEN @strSymbolPrefix='' THEN strSymbolPrefix ELSE @strSymbolPrefix END
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId

	SELECT @MarketExchangeCode = E.strExchangeInterfaceCode
	FROM tblRKMarketExchange E
	JOIN tblRKFutureMarket M ON M.intMarketExchangeId = E.intMarketExchangeId AND M.intFutureMarketId = @FutureMarketId
	
	IF ISNULL(@FutureMonthId,0)=0
	BEGIN
		SELECT TOP 1 @FutureMonthId =ISNULL(intFutureMonthId,0)	
		FROM tblRKFuturesMonth
		WHERE intFutureMarketId = @FutureMarketId AND ysnExpired=0
		AND ISNULL(dtmLastTradingDate, CONVERT(DATETIME, SUBSTRING(LTRIM(year(GETDATE())), 1, 2) + LTRIM(intYear) + '-' + SUBSTRING(strFutureMonth, 1, 3) + '-01')) >= DATEADD(d, 0, DATEDIFF(d, 0, GETDATE()))
		ORDER BY ISNULL(dtmLastTradingDate, CONVERT(DATETIME, SUBSTRING(LTRIM(year(GETDATE())), 1, 2) + LTRIM(intYear) + '-' + SUBSTRING(strFutureMonth, 1, 3) + '-01')) ASC
		
	END

	IF @FutureMonthId >0
	BEGIN
		SELECT @StrTradedMonthSymbol=strSymbol+RIGHT(intYear,1) from tblRKFuturesMonth Where  intFutureMonthId=@FutureMonthId
	END
	
	SELECT @URL = strInterfaceWebServicesURL FROM tblSMCompanyPreference

	SELECT @strUserName = strProviderUserId FROM tblGRUserPreference Where [intEntityUserSecurityId]= @intUserId 
	
	SELECT @strPassword = strProviderPassword FROM tblGRUserPreference Where [intEntityUserSecurityId]=@intUserId  

	SELECT @IntinterfaceSystem = intInterfaceSystemId FROM   tblSMCompanyPreference

	IF @IntinterfaceSystem = 1
	BEGIN
		IF @strPassword = ''
			SET @strPassword = '?&Type=F'
			
		IF ISNULL(@MarketExchangeCode,'')=''
		BEGIN
			SELECT @URL = @URL + 'UserID=' + @strUserName + '&Password=' + @strPassword + '&Symbol='+@SymbolPrefix + @Commoditycode + @StrTradedMonthSymbol
		END
		ELSE
		BEGIN
		SELECT @URL = @URL + 'UserID=' + @strUserName + '&Password=' + @strPassword +'&Market='+@MarketExchangeCode+'&Symbol='+@SymbolPrefix+ @Commoditycode + @StrTradedMonthSymbol			
		END
		
	END
	ELSE IF @IntinterfaceSystem = 2
	BEGIN
		IF ISNULL(@MarketExchangeCode,'')=''
		BEGIN
			SELECT @URL = @URL + 'username=' + @strUserName + '&password=' + @strPassword + '&symbols='+@SymbolPrefix+ @Commoditycode + @StrTradedMonthSymbol
		END
		ELSE
		BEGIN
			SELECT @URL = @URL + 'username=' + @strUserName + '&password=' + @strPassword +'&Market='+@MarketExchangeCode+ '&symbols='+@SymbolPrefix+ @Commoditycode + @StrTradedMonthSymbol
		END
		
	END

	SELECT @URL AS URL
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKGetElectronicPricingURL: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH