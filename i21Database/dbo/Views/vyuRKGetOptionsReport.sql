CREATE VIEW vyuRKGetOptionsReport
	
AS
SELECT  
	'Futures Market'	= strFutMarketName
	,'Commodity'		= strCommodityCode
	,'Pricing Type'		= strPricingType
	,'Price Date/Time'	= dtmPriceDate
	,'Month'			= OM.strOptionMonth
	,'Strike'			= dblStrike
	,'Type'				= CASE WHEN intTypeId = 1 THEN 'Put' WHEN intTypeId = 2 THEN 'Call' ELSE '' END
	,'Settle'			= dblSettle
	,'Delta'			= dblDelta
	,'Comments'			= strComments
FROM vyuRKGetSettlementPriceHeader H
INNER JOIN tblRKOptSettlementPriceMarketMap D ON D.intFutureSettlementPriceId = H.intFutureSettlementPriceId
INNER JOIN tblRKOptionsMonth OM ON OM.intOptionMonthId = D.intOptionMonthId
