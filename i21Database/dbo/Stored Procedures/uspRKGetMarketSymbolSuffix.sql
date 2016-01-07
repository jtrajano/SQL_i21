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

	INSERT INTO @FutureTradedMonths (IntMonthNumber,StrMonthName,IsTraded,StrTradedMonthSymbol)
	
	SELECT 1,'JAN',ysnFutJan,'F' FROM tblRKFutureMarket  WHERE intFutureMarketId = @FutureMarketId
	UNION
	SELECT 2,'FEB',ysnFutFeb,'G' FROM tblRKFutureMarket  WHERE intFutureMarketId = @FutureMarketId	
	UNION
	SELECT 3,'MAR',ysnFutMar,'H' FROM tblRKFutureMarket  WHERE intFutureMarketId = @FutureMarketId
	UNION
	SELECT 4,'APR',ysnFutApr,'J' FROM tblRKFutureMarket	 WHERE intFutureMarketId = @FutureMarketId
	UNION
	SELECT 5,'MAY',ysnFutMay,'K' FROM tblRKFutureMarket  WHERE intFutureMarketId = @FutureMarketId
	UNION 
	SELECT 6,'JUN',ysnFutJun,'M' FROM tblRKFutureMarket	 WHERE intFutureMarketId = @FutureMarketId
	UNION
	SELECT 7,'JUL',ysnFutJul,'N' FROM tblRKFutureMarket  WHERE intFutureMarketId = @FutureMarketId
	UNION
	SELECT 8,'AUG',ysnFutAug,'Q' FROM tblRKFutureMarket  WHERE intFutureMarketId = @FutureMarketId
	UNION
	SELECT 9,'SEP',ysnFutSep,'U' FROM tblRKFutureMarket	 WHERE intFutureMarketId = @FutureMarketId
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
		
	IF ISNULL(@StrTradedMonthSymbol,'')=''
	BEGIN
		SET @StrTradedMonthSymbol=(SELECT TOP 1 StrTradedMonthSymbol FROM @FutureTradedMonths WHERE IsTraded = 1 ORDER BY IntMonthNumber ASC)	   
	    SELECT @StrTradedMonthSymbol+RIGHT(YEAR(GetDate())+1,1),@StrTradedMonthSymbol+SUBSTRING(CONVERT(Nvarchar,YEAR(GetDate())+1),3,2)  
	END
	ELSE
	BEGIN
		SELECT @StrTradedMonthSymbol+RIGHT(YEAR(GetDate()), 1),@StrTradedMonthSymbol+SUBSTRING(CONVERT(nvarchar,YEAR(GetDate())),3,2)    
	END	
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKGetMarketSymbolSuffix: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
		
END CATCH