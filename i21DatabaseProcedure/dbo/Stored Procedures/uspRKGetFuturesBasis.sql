CREATE PROCEDURE [dbo].[uspRKGetFuturesBasis]
	 @intItemId   INT
	,@intUserId INT
	,@dblFuturesPurchaseBasis NUMERIC(18,6) OUT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strProviderAccessType NVARCHAR(30)
	DECLARE @FutureMarketId INT
	DECLARE @intCommodityId INT
	DECLARE @FutureMonthId INT
	DECLARE @strFutureMonth NVARCHAR(30)

	SELECT @strProviderAccessType=ISNULL(strProviderAccessType,'') FROM tblGRUserPreference WHERE intEntityUserSecurityId=@intUserId

	SELECT @FutureMarketId=Com.intFutureMarketId,@intCommodityId=Com.intCommodityId
	FROM
	tblICItem Item
	JOIN tblICCommodity Com ON Com.intCommodityId=Item.intCommodityId
	Where intItemId=@intItemId AND Com.ysnExchangeTraded=1 AND ISNULL(intFutureMarketId,0)>0

	IF ISNULL(@FutureMarketId,0) >0
	BEGIN
		SELECT TOP 1 @FutureMonthId =ISNULL(intFutureMonthId,0)	
		FROM tblRKFuturesMonth
		WHERE intFutureMarketId = @FutureMarketId AND ysnExpired=0
		AND ISNULL(dtmLastTradingDate, CONVERT(DATETIME, SUBSTRING(LTRIM(year(GETDATE())), 1, 2) + LTRIM(intYear) + '-' + SUBSTRING(strFutureMonth, 1, 3) + '-01')) >= DATEADD(d, 0, DATEDIFF(d, 0, GETDATE()))
		ORDER BY ISNULL(dtmLastTradingDate, CONVERT(DATETIME, SUBSTRING(LTRIM(year(GETDATE())), 1, 2) + LTRIM(intYear) + '-' + SUBSTRING(strFutureMonth, 1, 3) + '-01')) ASC			

		IF @FutureMonthId >0
		SELECT @strFutureMonth=LEFT(strFutureMonth,3)+' 20'+RIGHT(strFutureMonth,2) FROM tblRKFuturesMonth WHERE intFutureMonthId=@FutureMonthId

		SELECT @dblFuturesPurchaseBasis=isnull(dblBasis,0) from dbo.fnRKGetFutureAndBasisPrice(1,@intCommodityId,@strFutureMonth,1,@FutureMarketId,null,null,null,0,null,null)		
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKGetFuturesBasis: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH