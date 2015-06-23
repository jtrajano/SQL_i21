CREATE PROCEDURE [dbo].[uspRKGetElectronicPricingURL]

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
	DECLARE @StrTradedMonthSymbol NVARCHAR(2)
	DECLARE @Commoditycode NVARCHAR(10)
	DECLARE @URL NVARCHAR(1000)
	
	SELECT @Commoditycode=strFutSymbol FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
	
	DECLARE @FutureTradedMonths AS TABLE 
	(
		 IntMonthNumber INT
		,StrMonthName NVARCHAR(20)
		,IsTraded BIT
		,StrTradedMonthSymbol NVARCHAR(2)
	 )

	--Jan    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 1
		,'JAN'
		,ysnFutJan
		,'F'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--Feb    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 2
		,'FEB'
		,ysnFutFeb
		,'G'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--March    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 3
		,'MAR'
		,ysnFutMar
		,'H'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--APR    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 4
		,'APR'
		,ysnFutApr
		,'J'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--May    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 5
		,'MAY'
		,ysnFutMay
		,'K'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--JUN    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 6
		,'JUN'
		,ysnFutJun
		,'M'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--JUly    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 7
		,'JUL'
		,ysnFutJul
		,'N'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--AUGUST    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 8
		,'AUG'
		,ysnFutAug
		,'Q'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--SEP    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 9
		,'SEP'
		,ysnFutSep
		,'U'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--OCT    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 10
		,'OCT'
		,ysnFutOct
		,'V'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--Nov    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 11
		,'NOV'
		,ysnFutNov
		,'X'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	--DEC    
	INSERT INTO @FutureTradedMonths 
	(
		 IntMonthNumber
		,StrMonthName
		,IsTraded
		,StrTradedMonthSymbol
	)
	SELECT 12
		,'DEC'
		,ysnFutDec
		,'Z'
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
		

	SELECT TOP 1 @StrTradedMonthSymbol = StrTradedMonthSymbol
	FROM @FutureTradedMonths
	WHERE IntMonthNumber >= MONTH(Getdate()) AND IsTraded = 1
	ORDER BY IntMonthNumber ASC

	SELECT @URL = strValue
	FROM tblSMPreferences
	WHERE strPreference = 'InterfaceWebServicesURL'

	SELECT @strUserName = strValue
	FROM tblSMPreferences a
	JOIN tblSMUserSecurity b ON b.intUserSecurityID = a.intUserID
	WHERE a.strPreference = 'ProviderUserId' AND b.intUserSecurityID = @intUserId

	IF NOT EXISTS (
			SELECT 1
			FROM tblSMPreferences a
			JOIN tblSMUserSecurity b ON b.intUserSecurityID = a.intUserID
			WHERE a.strPreference = 'QuoteProvider'
				AND b.intUserSecurityID = @intUserId
				AND strValue = 'DTN/Agricharts'
			)
		OR (@strUserName = '')
	BEGIN
	
		RAISERROR ('The User cannot access Electronic Pricing',16,1)
		
	END

	SELECT @strPassword = strValue
	FROM tblSMPreferences a
	JOIN tblSMUserSecurity b ON b.intUserSecurityID = a.intUserID
	WHERE a.strPreference = 'ProviderPassword' AND b.intUserSecurityID = @intUserId

	SELECT @IntinterfaceSystem = strValue
	FROM tblSMPreferences
	WHERE strPreference = 'InterfaceSystem'

	IF @IntinterfaceSystem = 1
	BEGIN
		IF @strPassword = ''
			SET @strPassword = '?&Type=F'

		SELECT @URL = @URL + 'UserID=' + @strUserName + '&Password=' + @strPassword + '&Symbol=@' + @Commoditycode + @StrTradedMonthSymbol + RIGHT(YEAR(GetDate()), 1)
		
	END
	ELSE IF @IntinterfaceSystem = 2
	BEGIN
	
		SELECT @URL = @URL + 'username=' + @strUserName + '&password=' + @strPassword + '&symbols=Z' + @Commoditycode + @StrTradedMonthSymbol + RIGHT(YEAR(GetDate()), 1)
		
	END

	SELECT @URL AS URL
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKGetElectronicPricingURL: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH