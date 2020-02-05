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
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblContractSize NUMERIC(24,10)
	, intOrigUOMId INT
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intOptionMonthId INT
	, strOptionMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblStrike NUMERIC(24,10)
	, strOptionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strBrokerAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strBroker NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strBuySell NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnPreCrush BIT
	, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN

	INSERT @returntable	
	SELECT 
		intFutOptTransactionId 
		,dblOpenContract
		,intCommodityId
		,strCommodityCode
		,strInternalTradeNo
		,strLocationName
		,dblContractSize
		,intOrigUOMId
		,strFutureMarket
		,strFutureMonth
		,intOptionMonthId
		,strOptionMonth
		,dblStrike 
		,strOptionType
		,strInstrumentType 
		,strBrokerAccount 
		,strBroker
		,strBuySell
		,ysnPreCrush
		,strNotes
		,strBrokerTradeNo
	FROM (
		SELECT 
			intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intTransactionRecordId ORDER BY c.intSummaryLogId DESC)
			,intFutOptTransactionId = intTransactionRecordId
			,dblOpenContract = dblOrigNoOfLots
			,intCommodityId
			,strCommodityCode
			,strInternalTradeNo = strTransactionNumber
			,strLocationName
			,dblContractSize = CAST(ISNULL(mf.dblContractSize, 0.00) AS NUMERIC(24, 10))
			,intOrigUOMId
			,strFutureMarket
			,strFutureMonth
			,intOptionMonthId = mf.intOptionMonthId
			,strOptionMonth = mf.strOptionMonth
			,dblStrike = CAST(ISNULL(mf.dblStrike, 0.00) AS NUMERIC(24, 10))
			,strOptionType = mf.strOptionType
			,strInstrumentType = mf.strInstrumentType
			,strBrokerAccount = mf.strBrokerAccount
			,strBroker = mf.strBroker
			,strBuySell = mf.strBuySell
			,ysnPreCrush = CAST(ISNULL(mf.ysnPreCrush, 0) AS BIT)
			,strNotes
			,strBrokerTradeNo = mf.strBrokerTradeNo
		FROM vyuRKGetSummaryLog c
		CROSS APPLY dbo.fnRKGetMiscFieldPivotDerivative(c.strMiscField) mf
		WHERE strTransactionType IN ('Derivatives', 'Match Derivatives')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))

		UNION ALL SELECT * FROM tb
	) t WHERE intRowNum = 1


RETURN

END