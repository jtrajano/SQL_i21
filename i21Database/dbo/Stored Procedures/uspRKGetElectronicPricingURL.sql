CREATE PROCEDURE [dbo].[uspRKGetElectronicPricingURL]
	 @FutureMarketId INT
	,@FutureMonthId INT
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

	SELECT @Commoditycode = strFutSymbol,@SymbolPrefix=strSymbolPrefix
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId

	SELECT @MarketExchangeCode = E.strExchangeInterfaceCode
	FROM tblRKMarketExchange E
	JOIN tblRKFutureMarket M ON M.intMarketExchangeId = E.intMarketExchangeId AND M.intFutureMarketId = @FutureMarketId

	IF @FutureMonthId >0
	BEGIN
		SELECT @StrTradedMonthSymbol=strSymbol+RIGHT(intYear,1) from tblRKFuturesMonth Where  intFutureMonthId=@FutureMonthId
	END
	ELSE
	BEGIN

		DECLARE @FutureTradedMonths AS TABLE 
		(
			 IntMonthNumber INT
			,StrMonthName NVARCHAR(20)
			,IsTraded BIT
			,StrTradedMonthSymbol NVARCHAR(2)
		 )
	 	 
		INSERT INTO @FutureTradedMonths (IntMonthNumber,StrMonthName,IsTraded,StrTradedMonthSymbol)

		SELECT 1,'JAN',ysnFutJan,'F' FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId
		UNION
		SELECT 2,'FEB',ysnFutFeb,'G' FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId	
		UNION
		SELECT 3,'MAR',ysnFutMar,'H' FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId
		UNION
		SELECT 4,'APR',ysnFutApr,'J' FROM tblRKFutureMarket	WHERE intFutureMarketId = @FutureMarketId
		UNION
		SELECT 5,'MAY',ysnFutMay,'K' FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId
		UNION 
		SELECT 6,'JUN',ysnFutJun,'M' FROM tblRKFutureMarket	WHERE intFutureMarketId = @FutureMarketId
		UNION
		SELECT 7,'JUL',ysnFutJul,'N' FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId
		UNION
		SELECT 8,'AUG',ysnFutAug,'Q' FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId
		UNION
		SELECT 9,'SEP',ysnFutSep,'U' FROM tblRKFutureMarket	WHERE intFutureMarketId = @FutureMarketId
		UNION
		SELECT 10,'OCT',ysnFutOct,'V' FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId
		UNION
		SELECT 11,'NOV',ysnFutNov,'X' FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId
		UNION
		SELECT 12,'DEC',ysnFutDec,'Z' FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId

		SELECT TOP 1 @StrTradedMonthSymbol = StrTradedMonthSymbol
		FROM @FutureTradedMonths
		WHERE IntMonthNumber >= MONTH(Getdate()) AND IsTraded = 1
		ORDER BY IntMonthNumber ASC

		IF ISNULL(@StrTradedMonthSymbol, '') = ''
		BEGIN
				SET @StrTradedMonthSymbol = (
												SELECT TOP 1 StrTradedMonthSymbol
												FROM @FutureTradedMonths
												WHERE IsTraded = 1
												ORDER BY IntMonthNumber ASC
											)
				SET @StrTradedMonthSymbol = @StrTradedMonthSymbol + Convert(NVARCHAR, RIGHT(YEAR(GetDate()), 1) + 1)
		END
		ELSE
		BEGIN
			SET @StrTradedMonthSymbol = @StrTradedMonthSymbol + RIGHT(YEAR(GetDate()), 1)
		END
		
	END

	SELECT @URL = strInterfaceWebServicesURL FROM tblSMCompanyPreference

	SELECT @strUserName = strProviderUserId FROM tblGRUserPreference Where [intEntityUserSecurityId]= @intUserId  

	 --IF NOT EXISTS (SELECT 1 FROM tblGRUserPreference Where strQuoteProvider='DTN/Agricharts' AND [intEntityUserSecurityId]=@intUserId) OR (@strUserName = '')  
	 --BEGIN
	 -- RAISERROR ('The User cannot access Electronic Pricing',16,1)  
	 --END


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