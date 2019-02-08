CREATE PROC [dbo].[uspRKRealizedPnL]
	@dtmFromDate DATETIME
	, @dtmToDate DATETIME
	, @intCommodityId INT = NULL
	, @ysnExpired BIT
	, @intFutureMarketId INT = NULL
	, @intEntityId INT = NULL
	, @intBrokerageAccountId INT = NULL
	, @intFutureMonthId INT = NULL
	, @strBuySell nvarchar(10)=NULL
	, @intBookId int=NULL
	, @intSubBookId int=NULL

AS

SET @dtmFromDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(@dtmToDate, GETDATE()), 110), 110)

SELECT CONVERT(INT, DENSE_RANK() OVER(ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth))) RowNum
	, strFutMarketName + ' - ' + strFutureMonth + ' - ' + strName strMonthOrder
	, dblGrossPL + -abs(dblFutCommission) AS dblNetPL
	, dblGrossPL
	, intMatchFuturesPSHeaderId
	, intMatchFuturesPSDetailId
	, intFutOptTransactionId
	, intLFutOptTransactionId
	, intSFutOptTransactionId
	, dblMatchQty
	, dtmLTransDate
	, dtmSTransDate
	, dblLPrice
	, dblSPrice
	, strLBrokerTradeNo
	, strSBrokerTradeNo
	, dblContractSize
	, -abs(dblFutCommission) as dblFutCommission
	, strFutMarketName
	, strFutureMonth
	, intMatchNo
	, dtmMatchDate
	, strName
	, strAccountNumber
	, strCommodityCode
	, strLocationName
	, intFutureMarketId
	, intCommodityId
	, ysnExpired
	, intFutureMonthId
	, strLInternalTradeNo
	, strSInternalTradeNo
	, strLRollingMonth
	, strSRollingMonth
	, intLFutOptTransactionHeaderId
	, intSFutOptTransactionHeaderId
	, strBook
	, strSubBook
FROM (
	SELECT * FROM (
		SELECT ((dblSPrice - dblLPrice) * dblMatchQty * dblContractSize) as dblGrossPL1
			, ((dblSPrice - dblLPrice) * dblMatchQty * dblContractSize) / case when ysnSubCurrency = 1 then intCent else 1 end as dblGrossPL
			, *
		FROM (
			SELECT psh.intMatchFuturesPSHeaderId
				, psd.intMatchFuturesPSDetailId
				, ot.intFutOptTransactionId
				, psd.intLFutOptTransactionId
				, psd.intSFutOptTransactionId
				, ISNULL(psd.dblMatchQty,0) as dblMatchQty
				, convert(datetime,CONVERT(VARCHAR(10),ot.dtmTransactionDate,110),110) dtmLTransDate
				, convert(datetime,CONVERT(VARCHAR(10),ot1.dtmTransactionDate,110),110) dtmSTransDate
				, ISNULL(ot.dblPrice,0) dblLPrice
				, ISNULL(ot1.dblPrice,0) dblSPrice
				, ot.strInternalTradeNo strLBrokerTradeNo
				, ot1.strInternalTradeNo strSBrokerTradeNo
				, fm.dblContractSize dblContractSize
				, 0 as intConcurrencyId
				, psd.dblFutCommission
				, fm.strFutMarketName
				, om.strFutureMonth
				, psh.intMatchNo
				, CONVERT(DATETIME,CONVERT(VARCHAR(10),psh.dtmMatchDate,110),110) dtmMatchDate
				, e.strName
				, acc.strAccountNumber
				, icc.strCommodityCode
				, sl.strLocationName
				, ot.intFutureMonthId
				, ot.intCommodityId
				, ot.intFutureMarketId
				, c.intCurrencyID as intCurrencyId
				, c.intCent
				, c.ysnSubCurrency
				, ysnExpired
				, c.intCent ComCent
				, c.ysnSubCurrency ComSubCurrency
				, ot.strInternalTradeNo strLInternalTradeNo
				, ot1.strInternalTradeNo strSInternalTradeNo
				, (select strFutureMonth from tblRKFuturesMonth fm where fm.intFutureMonthId=ot.intRollingMonthId) strLRollingMonth
				, (select strFutureMonth from tblRKFuturesMonth fm where fm.intFutureMonthId=ot1.intRollingMonthId) strSRollingMonth
				, ot.intFutOptTransactionHeaderId intLFutOptTransactionHeaderId
				, ot1.intFutOptTransactionHeaderId intSFutOptTransactionHeaderId
				, cb.strBook
				, sb.strSubBook
			FROM tblRKMatchFuturesPSHeader psh
			JOIN tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId
			JOIN tblRKFutOptTransaction ot on psd.intLFutOptTransactionId= ot.intFutOptTransactionId
			JOIN tblRKFuturesMonth om on om.intFutureMonthId=ot.intFutureMonthId
			JOIN tblRKBrokerageAccount acc on acc.intBrokerageAccountId=ot.intBrokerageAccountId
			JOIN tblICCommodity icc on icc.intCommodityId=ot.intCommodityId
			JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=ot.intLocationId
			JOIN tblEMEntity e on e.intEntityId=ot.intEntityId
			JOIN tblRKFutureMarket fm on ot.intFutureMarketId=fm.intFutureMarketId
			JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
			JOIN tblRKFutOptTransaction ot1 on psd.intSFutOptTransactionId= ot1.intFutOptTransactionId
			LEFT JOIN tblCTBook cb on ot.intBookId=cb.intBookId
			LEFT JOIN tblCTSubBook sb on ot.intSubBookId=sb.intSubBookId
			WHERE ISNULL(ot.intCommodityId,0)= CASE WHEN ISNULL(@intCommodityId,0)=0 then ISNULL(ot.intCommodityId,0) else @intCommodityId end
				AND ISNULL(ot.intFutureMarketId,0)= CASE WHEN ISNULL(@intFutureMarketId,0)=0 then ISNULL(ot.intFutureMarketId,0) else @intFutureMarketId end
				AND ISNULL(ot.intBookId,0)= CASE WHEN ISNULL(@intBookId,0)=0 then ISNULL(ot.intBookId,0) else @intBookId end
				AND ISNULL(ot.intSubBookId,0)= CASE WHEN ISNULL(@intSubBookId,0)=0 then ISNULL(ot.intSubBookId,0) else @intSubBookId end
				AND ISNULL(ot.intEntityId,0)= CASE WHEN ISNULL(@intEntityId,0)=0 then ot.intEntityId else @intEntityId end
				AND ISNULL(ot.intBrokerageAccountId,0)= CASE WHEN ISNULL(@intBrokerageAccountId,0)=0 then ot.intBrokerageAccountId else @intBrokerageAccountId end
				AND ISNULL(ot.intFutureMonthId,0)= CASE WHEN ISNULL(@intFutureMonthId,0)=0 then ot.intFutureMonthId else @intFutureMonthId end
				AND ot.strBuySell= CASE WHEN ISNULL(@strBuySell,'0')= '0' then ot.strBuySell else @strBuySell end
				AND CONVERT(DATETIME,CONVERT(VARCHAR(10),psh.dtmMatchDate,110),110) BETWEEN @dtmFromDate AND @dtmToDate
				AND psh.strType = 'Realize'
				AND ISNULL(ysnExpired,0) = case when ISNULL(@ysnExpired,0)= 1 then ISNULL(ysnExpired,0) else @ysnExpired end
				AND ot.intInstrumentTypeId =1
		)t
	)t1
)t ORDER BY RowNum ASC