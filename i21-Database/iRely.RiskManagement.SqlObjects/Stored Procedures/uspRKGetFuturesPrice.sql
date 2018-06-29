CREATE PROCEDURE [dbo].[uspRKGetFuturesPrice]
	@FutureMarketId   INT	
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)			
	DECLARE @FutureMonthId INT

	SELECT TOP 1 @FutureMonthId =ISNULL(intFutureMonthId,0)	
	FROM tblRKFuturesMonth
	WHERE intFutureMarketId = @FutureMarketId AND ysnExpired=0
	AND ISNULL(dtmLastTradingDate, CONVERT(DATETIME, SUBSTRING(LTRIM(year(GETDATE())), 1, 2) + LTRIM(intYear) + '-' + SUBSTRING(strFutureMonth, 1, 3) + '-01')) >= DATEADD(d, 0, DATEDIFF(d, 0, GETDATE()))
	ORDER BY ISNULL(dtmLastTradingDate, CONVERT(DATETIME, SUBSTRING(LTRIM(year(GETDATE())), 1, 2) + LTRIM(intYear) + '-' + SUBSTRING(strFutureMonth, 1, 3) + '-01')) ASC			

	IF @FutureMarketId >0 AND  @FutureMonthId>0
	BEGIN
		SELECT TOP 1 
		 a.intFutSettlementPriceMonthId AS intElectronicPricingValueId
		,ISNULL(dblHigh,0)       AS High  
		,ISNULL(dblLow,0)        AS  Low  
		,ISNULL(dblOpen,0)       AS [Open]  
		,ISNULL(dblLastSettle,0) AS [Last]
		,'Success'               AS strMessage 
		FROM tblRKFutSettlementPriceMarketMap a
		JOIN tblRKFuturesSettlementPrice b ON b.intFutureSettlementPriceId=a.intFutureSettlementPriceId
		WHERE b.intFutureMarketId=@FutureMarketId AND a.intFutureMonthId=@FutureMonthId
		ORDER BY b.dtmPriceDate DESC
	END 

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKGetFuturesPrice: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH