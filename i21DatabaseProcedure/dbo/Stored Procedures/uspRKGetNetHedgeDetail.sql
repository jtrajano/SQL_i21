CREATE PROC uspRKGetNetHedgeDetail 
	@intCommodityId int,
	@intLocationId int = NULL
AS

DECLARE @tblTemp TABLE (strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmFilledDate DATETIME
	, strInternalTradeNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strBroker NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strAccountNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intFutOptTransactionId INT
	, strFutMarketName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblNoOfContract NUMERIC(24,10)
	, dblMatchQty NUMERIC(24,10)
	, dblContractSize NUMERIC(24,10)
	, intFutureMarketId INT
	, BuySell NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, OpenLots NUMERIC(24,10)
	, HedgedQty NUMERIC(24,10)
	, intCommodityId int)

IF ISNULL(@intLocationId, 0) <> 0
BEGIN
	INSERT INTO @tblTemp (strLocationName
		, dtmFilledDate
		, strInternalTradeNo
		, strFutureMonth
		, strInstrumentType
		, strBroker
		, strAccountNumber
		, intFutOptTransactionId
		, strFutMarketName
		, dblNoOfContract
		, dblMatchQty
		, dblContractSize
		, intFutureMarketId
		, BuySell
		, OpenLots
		, HedgedQty
		, intCommodityId)
	SELECT l.strLocationName
		, ft.dtmFilledDate
		, ft.strInternalTradeNo
		, fm.strFutureMonth
		, CASE WHEN ft.intInstrumentTypeId=1 THEN 'Future' ELSE 'Option' END COLLATE Latin1_General_CI_AS strInstrumentType
		, e.strName strBroker
		, ba.strAccountNumber
		, t.*
	FROM (
		SELECT f.intFutOptTransactionId
			, m.strFutMarketName
			, isnull(dblNoOfContract,0) dblNoOfContract
			, ISNULL(dblMatchQty,0) dblMatchQty
			, m.dblContractSize
			, m.intFutureMarketId
			, 'Buy' COLLATE Latin1_General_CI_AS as [BuySell]
			, (ISNULL(dblNoOfContract,0)-isnull(dblMatchQty,0)) OpenLots
			, (ISNULL(dblNoOfContract,0)-isnull(dblMatchQty,0)) * m.dblContractSize as HedgedQty
			, intCommodityId
		FROM tblRKFutOptTransaction f
		JOIN tblRKFutureMarket m on f.intFutureMarketId=m.intFutureMarketId
		LEFT JOIN tblRKMatchFuturesPSDetail psd on f.intFutOptTransactionId=psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Buy' and intCommodityId=@intCommodityId and f.intLocationId=@intLocationId
		
		UNION ALL SELECT f.intFutOptTransactionId
			,m.strFutMarketName
			,isnull(dblNoOfContract,0) dblNoOfContract
			,isnull(dblMatchQty,0) dblMatchQty
			,m.dblContractSize
			,m.intFutureMarketId
			,'Sell' COLLATE Latin1_General_CI_AS as [BuySell]
			,(ISNULL(dblNoOfContract,0)-isnull(dblMatchQty,0)) OpenLots
			,-(isnull(dblNoOfContract,0)-isnull(dblMatchQty,0)) * m.dblContractSize as HedgedQty
			,intCommodityId
		FROM tblRKFutOptTransaction f
		JOIN tblRKFutureMarket m on f.intFutureMarketId=m.intFutureMarketId
		LEFT JOIN tblRKMatchFuturesPSDetail psd on f.intFutOptTransactionId=psd.intSFutOptTransactionId
		WHERE f.strBuySell = 'Sell' And intCommodityId=@intCommodityId and f.intLocationId=@intLocationId
	) t
	JOIN tblRKFutOptTransaction ft on t.intFutOptTransactionId=ft.intFutOptTransactionId
	JOIN tblSMCompanyLocation l on l.intCompanyLocationId=ft.intLocationId
	JOIN tblRKFuturesMonth fm on ft.intFutureMonthId=fm.intFutureMonthId
	JOIN tblEMEntity e on e.intEntityId=ft.intEntityId
	JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=ft.intBrokerageAccountId
END
ELSE
BEGIN
	INSERT INTO @tblTemp (strLocationName
		, dtmFilledDate
		, strInternalTradeNo
		, strFutureMonth
		, strInstrumentType
		, strBroker
		, strAccountNumber
		, intFutOptTransactionId
		, strFutMarketName
		, dblNoOfContract
		, dblMatchQty
		, dblContractSize
		, intFutureMarketId
		, BuySell
		, OpenLots
		, HedgedQty
		, intCommodityId)
	SELECT l.strLocationName
		, ft.dtmFilledDate
		, ft.strInternalTradeNo
		, fm.strFutureMonth
		, CASE WHEN ft.intInstrumentTypeId=1 THEN 'Future' ELSE 'Option' END COLLATE Latin1_General_CI_AS strInstrumentType
		, e.strName strBroker
		, ba.strAccountNumber
		, t.*
	FROM (
		SELECT f.intFutOptTransactionId
			, m.strFutMarketName
			, isnull(dblNoOfContract,0) dblNoOfContract
			, ISNULL(dblMatchQty,0) dblMatchQty
			, m.dblContractSize
			, m.intFutureMarketId
			, 'Buy' COLLATE Latin1_General_CI_AS as [BuySell]
			, (ISNULL(dblNoOfContract,0)-isnull(dblMatchQty,0)) OpenLots
			, (ISNULL(dblNoOfContract,0)-isnull(dblMatchQty,0)) * m.dblContractSize as HedgedQty
			, intCommodityId
		FROM tblRKFutOptTransaction f
		JOIN tblRKFutureMarket m on f.intFutureMarketId=m.intFutureMarketId
		LEFT JOIN tblRKMatchFuturesPSDetail psd on f.intFutOptTransactionId=psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Buy' and intCommodityId=@intCommodityId 

		UNION ALL SELECT f.intFutOptTransactionId
			, m.strFutMarketName
			, isnull(dblNoOfContract,0) dblNoOfContract
			, isnull(dblMatchQty,0) dblMatchQty
			, m.dblContractSize
			, m.intFutureMarketId
			, 'Sell' COLLATE Latin1_General_CI_AS as [BuySell]
			, (ISNULL(dblNoOfContract,0)-isnull(dblMatchQty,0)) OpenLots
			, -(isnull(dblNoOfContract,0)-isnull(dblMatchQty,0)) * m.dblContractSize as HedgedQty
			, intCommodityId
		FROM tblRKFutOptTransaction f
		JOIN tblRKFutureMarket m on f.intFutureMarketId=m.intFutureMarketId
		LEFT JOIN tblRKMatchFuturesPSDetail psd on f.intFutOptTransactionId=psd.intSFutOptTransactionId 
		WHERE f.strBuySell = 'Sell' And intCommodityId=@intCommodityId
	) t
	JOIN tblRKFutOptTransaction ft on t.intFutOptTransactionId=ft.intFutOptTransactionId
	JOIN tblSMCompanyLocation l on l.intCompanyLocationId=ft.intLocationId
	JOIN tblRKFuturesMonth fm on ft.intFutureMonthId=fm.intFutureMonthId
	JOIN tblEMEntity e on e.intEntityId=ft.intEntityId
	JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=ft.intBrokerageAccountId
END

DECLARE @intUnitMeasureId int

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

if isnull(@intUnitMeasureId, '') <> ''
BEGIN
	SELECT strLocationName
		,dtmFilledDate
		,strInternalTradeNo
		,strFutureMonth
		,strInstrumentType
		,strBroker
		,strAccountNumber
		,intFutOptTransactionId
		,strFutMarketName
		,dblNoOfContract
		,dblMatchQty
		,dblContractSize
		,intFutureMarketId
		,BuySell
		,OpenLots
		,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,round(HedgedQty,4)),0) HedgedQty
	FROM @tblTemp t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
	JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
END
ELSE
BEGIN
	SELECT strLocationName
		,dtmFilledDate
		,strInternalTradeNo
		,strFutureMonth
		,strInstrumentType
		,strBroker
		,strAccountNumber
		,intFutOptTransactionId
		,strFutMarketName
		,dblNoOfContract
		,dblMatchQty
		,dblContractSize
		,intFutureMarketId
		,BuySell
		,OpenLots
		,HedgedQty
	FROM @tblTemp
END