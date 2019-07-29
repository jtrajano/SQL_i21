CREATE PROCEDURE [dbo].[uspRKGetAllElectronicPricingURL]
	@FutureMarketId INT
	, @intUserId INT

AS

BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @strPassword NVARCHAR(100)
	DECLARE @strAPIKey NVARCHAR(MAX)
	DECLARE @IntinterfaceSystem INT
	DECLARE @StrQuoteProvider NVARCHAR(100)
	DECLARE @StrTradedMonthSymbol NVARCHAR(1000)
	DECLARE @MarketExchangeCode NVARCHAR(10)
	DECLARE @Commoditycode NVARCHAR(10)
	DECLARE @URL NVARCHAR(1000)
	DECLARE @SymbolPrefix NVARCHAR(5)
	DECLARE @intInterfaceSystem int
	declare @dblConversionRate numeric(16,10)

	SELECT @Commoditycode = strFutSymbol
		, @SymbolPrefix = strSymbolPrefix
		, @dblConversionRate = isnull(dblConversionRate,1)
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId		

	select 
		@intInterfaceSystem = intInterfaceSystemId  --1 = DTN, 2 = AgriCharts
		,@strUserName = strQuotingSystemBatchUserID
		,@strPassword = strQuotingSystemBatchUserPassword
		,@strAPIKey = strAPIKey
		,@URL = strInterfaceWebServicesURL
	from tblSMCompanyPreference 

	
	IF ISNULL(@URL,'') <> '' AND @intInterfaceSystem = 1 --DTN
	BEGIN
		SELECT (@URL + 'UserID=' + @strUserName + '&Password=' + @strPassword + '&Type=F' + '&Symbol=@'+@SymbolPrefix+@Commoditycode + strSymbol+RIGHT(intYear,1)) COLLATE Latin1_General_CI_AS as URL
			, strFutureMonth strFutureMonthYearWOSymbol
			, intFutureMonthId as intFutureMonthId
			, 'Open' as strOpen
			, 'High' as strHigh
			, 'Low' as strLow
			, 'Last' as strLastSettle
			, '' as strLastElement
			, @dblConversionRate as dblConversionRate
			, 'DTN' as strInterfaceSystem
		FROM tblRKFuturesMonth 
		WHERE intFutureMarketId=@FutureMarketId 
			AND ysnExpired = 0 
			AND dtmLastTradingDate > GETDATE()
	END
	ELSE IF ISNULL(@URL,'') <> '' AND @intInterfaceSystem = 2 --AgriCharts
	BEGIN

		SELECT (@URL + 'apikey=' + @strAPIKey + '&symbols='+@SymbolPrefix+@Commoditycode + strSymbol+RIGHT(intYear,1)) COLLATE Latin1_General_CI_AS as URL
			, strFutureMonth strFutureMonthYearWOSymbol
			, intFutureMonthId as intFutureMonthId
			, 'open' as strOpen
			, 'high' as strHigh
			, 'low' as strLow
			, 'lastPrice' as strLastSettle
			, '' as strLastElement
			, @dblConversionRate as dblConversionRate
			, 'AgriCharts' as strInterfaceSystem
		FROM tblRKFuturesMonth 
		WHERE intFutureMarketId=@FutureMarketId 
			AND ysnExpired = 0 
			AND dtmLastTradingDate > GETDATE()
	END
	ELSE
	BEGIN
		RAISERROR ('Interface Web Services URL is not properly setup. <br/> Please check the Electronic Pricing Options in Company Configuration/System Manager.',16,1,'WITH NOWAIT')	
	END
END TRY	
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')	
END CATCH