CREATE PROCEDURE [dbo].[uspRKGetInventoryView]
	@intCommodityId INT
	, @intFutureMarketId INT 
	, @strFutureMonth NVARCHAR(100)

AS

BEGIN


SELECT *
FROM vyuRKInventoryView
WHERE intCommodityId = @intCommodityId
AND intFutureMarketId = @intFutureMarketId
AND CONVERT(DATETIME, '01 ' + strFutureMonth)  <=  CONVERT(DATETIME, '01 ' + @strFutureMonth) 


END