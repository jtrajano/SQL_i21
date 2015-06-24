CREATE PROCEDURE [dbo].[uspRKGetMarketSymbolSuffix]

	@FutureMarketId INT	

AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @StrTradedMonthSymbol NVARCHAR(2)	
	
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
		
	IF ISNULL(@StrTradedMonthSymbol,'')=''
	BEGIN
	
		SET @StrTradedMonthSymbol=
		(
			SELECT TOP 1 StrTradedMonthSymbol
			FROM @FutureTradedMonths
			WHERE IsTraded = 1
			ORDER BY IntMonthNumber ASC
	   )
	   SELECT @StrTradedMonthSymbol+Convert(nvarchar,RIGHT(YEAR(GetDate()), 1)+1)
	END
	ELSE
	BEGIN
		SELECT @StrTradedMonthSymbol+RIGHT(YEAR(GetDate()), 1)
	END	
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKGetMarketSymbolSuffix: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
		
END CATCH