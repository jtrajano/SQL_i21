CREATE PROCEDURE [dbo].uspRKGetAllElectronicPricingURL 
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
	DECLARE @strOpen nvarchar(50)
	DECLARE @strHigh nvarchar(50)
	DECLARE @strLow nvarchar(50)
	DECLARE @strLastSettle nvarchar(50)
	DECLARE @strLastElement nvarchar(50)
	
	SELECT @Commoditycode = strFutSymbol,@SymbolPrefix=strSymbolPrefix
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId		

	SELECT @strUserName = strProviderUserId FROM tblGRUserPreference Where [intEntityUserSecurityId]= @intUserId 	
	SELECT @strPassword = strProviderPassword FROM tblGRUserPreference Where [intEntityUserSecurityId]=@intUserId 
		
	SELECT TOP 1 @URL= s.strInterfaceSystemURL,@strOpen=strOpen,@strHigh=strHigh,@strLow=strLow,@strLastSettle=strLastSettle,@strLastElement=strLastElement FROM tblRKCompanyPreference c
	JOIN tblRKInterfaceSystem s on c.intInterfaceSystemId=s.intInterfaceSystemId 

	if isnull(@URL,'') <> ''
	BEGIN
		SELECT  replace(replace(@URL+@SymbolPrefix+@Commoditycode + strSymbol+RIGHT(intYear,1),'¶¶',@strUserName),'¶¶¶¶',@strPassword) as URL,strFutureMonth strFutureMonthYearWOSymbol,intFutureMonthId as intFutureMonthId,
		@strOpen as strOpen,@strHigh as strHigh,@strLow as strLow,@strLastSettle as strLastSettle,@strLastElement as strLastElement
		FROM tblRKFuturesMonth where intFutureMarketId=@FutureMarketId and ysnExpired = 0 
	END
	
	END TRY
	
BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKGetAllElectronicPricingURL: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH
