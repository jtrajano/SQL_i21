CREATE VIEW vyuIPGetFutureMarket
AS
SELECT FM.intFutureMarketId
	,FM.strFutMarketName
	,FM.dblForecastPrice
FROM tblRKFutureMarket FM WITH (NOLOCK)
