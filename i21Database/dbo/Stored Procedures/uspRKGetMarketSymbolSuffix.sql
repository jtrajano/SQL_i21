CREATE PROCEDURE [dbo].[uspRKGetMarketSymbolSuffix]
	@FutureMarketId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @FutureMonthId INT	
	DECLARE @StrTradedMonthSymbol NVARCHAR(2)
	
	SELECT TOP 1 @FutureMonthId =ISNULL(intFutureMonthId,0)	
	FROM tblRKFuturesMonth
	WHERE intFutureMarketId = @FutureMarketId AND ysnExpired=0
	AND ISNULL(dtmLastTradingDate, CONVERT(DATETIME, SUBSTRING(LTRIM(year(GETDATE())), 1, 2) + LTRIM(intYear) + '-' + SUBSTRING(strFutureMonth, 1, 3) + '-01')) >= DATEADD(d, 0, DATEDIFF(d, 0, GETDATE()))
	ORDER BY ISNULL(dtmLastTradingDate, CONVERT(DATETIME, SUBSTRING(LTRIM(year(GETDATE())), 1, 2) + LTRIM(intYear) + '-' + SUBSTRING(strFutureMonth, 1, 3) + '-01')) ASC
	
	IF @FutureMonthId >0
	BEGIN
		SELECT @StrTradedMonthSymbol=strSymbol+RIGHT(intYear,1) from tblRKFuturesMonth Where  intFutureMonthId=@FutureMonthId
		SELECT @StrTradedMonthSymbol
	END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKGetMarketSymbolSuffix: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
		
END CATCH