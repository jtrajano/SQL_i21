﻿CREATE FUNCTION [dbo].[fnRKGetBucketDerivatives]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	intFutOptTransactionId INT
	, dblOpenContract NUMERIC(18,6)
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblContractSize NUMERIC(24,10)
	, intOrigUOMId INT
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
		,strCommodityCode
		,strInternalTradeNo
		,strLocationName
		,dblContractSize
		,intOrigUOMId
		,strFutureMarket
		,strFutureMonth
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
			,strCommodityCode
			,strInternalTradeNo = strTransactionNumber
			,strLocationName
			,dblContractSize
			,intOrigUOMId
			,strFutureMarket
			,strFutureMonth
			,strOptionMonth = ''
			,dblStrike = NULL
			,strOptionType = ''
			,strInstrumentType = ''
			,strBrokerAccount = ''
			,strBroker = ''
			,strBuySell = ''
			,ysnPreCrush = NULL
			,strNotes
			,strBrokerTradeNo = ''
		FROM vyuRKGetSummaryLog c
		WHERE strTransactionType IN ('Derivatives', 'Match Derivatives')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND c.intCommodityId = @intCommodityId
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	) t WHERE intRowNum = 1


RETURN

END