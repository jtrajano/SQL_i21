CREATE VIEW vyuRKGetFuturesReport
	
AS
SELECT  
	'Futures Market'		= strFutMarketName
	,'Commodity'			= strCommodityCode
	,'Type'					= strPricingType
	,'Price Date/Time'		= dtmPriceDate
	,'Month'				= strFutureMonthYearWOSymbol
	,'Last Settle'			= dblLastSettle
	,'Low'					= dblLow
	,'High'					= dblHigh
	,'Comments'				= strComments
	,'Imported from Market'	= ysnImported
	,'M2M Batch'			= strM2MBatch
	,'M2M Date'				= dtmM2MDate
FROM vyuRKGetSettlementPriceHeader H
INNER JOIN vyuRKFutSettlementPriceMarketMap D ON D.intFutureSettlementPriceId = H.intFutureSettlementPriceId





