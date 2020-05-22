CREATE FUNCTION [dbo].[fnRKGetBucketDerivatives]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	intFutOptTransactionId INT
	, dblOpenContract NUMERIC(18,6)
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intLocationId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblContractSize NUMERIC(24,10)
	, intOrigUOMId INT
	, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intFutureMarketId INT
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmFutureMonthsDate DATETIME
	, intOptionMonthId INT
	, strOptionMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblStrike NUMERIC(24,10)
	, strOptionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intBrokerageAccountId INT
	, strBrokerAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intEntityId INT
	, strBroker NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strBuySell NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnPreCrush BIT
	, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutOptTransactionHeaderId INT
	, intCurrencyId INT
	, strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmCreatedDate DATETIME
	, dtmTransactionDate DATETIME
	, intUserId INT
	, strUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN
	; WITH MatchDerivatives (
		intTransactionRecordId
		, intOrigUOMId
		, dblOrigNoOfLots
		, dblOrigQty
	) AS (
		SELECT intFutOptTransactionId
			, intOrigUOMId
			, dblOrigNoOfLots = SUM(ISNULL(dblOrigNoOfLots, 0))
			, dblOrigQty = SUM(ISNULL(dblOrigQty, 0))
		FROM vyuRKGetSummaryLog sl
		WHERE strTransactionType = 'Match Derivatives'
			AND CAST(FLOOR(CAST(dtmCreatedDate AS FLOAT)) AS DATETIME) <= @dtmDate
			AND CAST(FLOOR(CAST(dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmDate
		GROUP BY intFutOptTransactionId
			, intOrigUOMId
	),
	OptionsLifecycle (
		intTransactionRecordId
		, intOrigUOMId
		, dblOrigNoOfLots
		, dblOrigQty
	) AS (
		SELECT intFutOptTransactionId
			, intOrigUOMId
			, dblOrigNoOfLots = SUM(ISNULL(dblOrigNoOfLots, 0))
			, dblOrigQty = SUM(ISNULL(dblOrigQty, 0))
		FROM vyuRKGetSummaryLog sl
		WHERE strTransactionType = 'Options Lifecycle'
			AND CAST(FLOOR(CAST(dtmCreatedDate AS FLOAT)) AS DATETIME) <= @dtmDate
			AND CAST(FLOOR(CAST(dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmDate
		GROUP BY intFutOptTransactionId
			, intOrigUOMId
		HAVING SUM(ISNULL(dblOrigNoOfLots, 0)) > 0
	)
	
	INSERT @returntable	
	SELECT intFutOptTransactionId 
		, dblOpenContract
		, intCommodityId
		, strCommodityCode
		, strInternalTradeNo
		, intLocationId
		, strLocationName
		, dblContractSize
		, intOrigUOMId
		, strUnitMeasure
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth
		, dtmFutureMonthsDate
		, intOptionMonthId
		, strOptionMonth
		, dblStrike 
		, strOptionType
		, strInstrumentType 
		, intBrokerageAccountId
		, strBrokerAccount 
		, intEntityId
		, strBroker
		, strBuySell
		, ysnPreCrush
		, strNotes
		, strBrokerTradeNo
		, intFutOptTransactionHeaderId
		, intCurrencyId
		, strCurrency
		, dtmCreatedDate
		, dtmTransactionDate
		, intUserId
		, strUserName
		, strAction
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intTransactionRecordId ORDER BY c.intSummaryLogId DESC)
			, c.intFutOptTransactionId
			, dblOpenContract = ISNULL(c.dblOrigNoOfLots, 0) - ISNULL(md.dblOrigNoOfLots, 0)
			, intCommodityId
			, strCommodityCode
			, strInternalTradeNo = strTransactionNumber
			, intLocationId
			, strLocationName
			, dblContractSize = CAST(ISNULL(c.dblContractSize, 0.00) AS NUMERIC(24, 10))
			, c.intOrigUOMId
			, strUnitMeasure
			, intFutureMarketId
			, strFutureMarket
			, intFutureMonthId
			, strFutureMonth
			, dtmFutureMonthsDate
			, intOptionMonthId = mf.intOptionMonthId
			, strOptionMonth = mf.strOptionMonth
			, dblStrike = CAST(ISNULL(mf.dblStrike, 0.00) AS NUMERIC(24, 10))
			, strOptionType = mf.strOptionType
			, strInstrumentType = mf.strInstrumentType
			, mf.intBrokerageAccountId
			, strBrokerAccount = mf.strBrokerAccount
			, intEntityId
			, strBroker = mf.strBroker
			, strBuySell = mf.strBuySell
			, ysnPreCrush = CAST(ISNULL(mf.ysnPreCrush, 0) AS BIT)
			, strNotes
			, strBrokerTradeNo = mf.strBrokerTradeNo			
			, mf.intFutOptTransactionHeaderId
			, c.intCurrencyId
			, c.strCurrency
			, dtmCreatedDate
			, dtmTransactionDate
			, intUserId
			, strUserName
			, strAction
		FROM vyuRKGetSummaryLog c
		CROSS APPLY dbo.fnRKGetMiscFieldPivotDerivative(c.strMiscField) mf
		LEFT JOIN MatchDerivatives md ON md.intTransactionRecordId = c.intTransactionRecordId
		WHERE strTransactionType IN ('Derivative Entry')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
			AND intFutOptTransactionId NOT IN (SELECT intTransactionRecordId FROM OptionsLifecycle)

	) t WHERE intRowNum = 1

RETURN

END