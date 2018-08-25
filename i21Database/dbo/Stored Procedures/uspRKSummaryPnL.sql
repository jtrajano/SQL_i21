﻿CREATE PROC [dbo].[uspRKSummaryPnL] @dtmFromDate DATETIME,
	@dtmToDate DATETIME,
	@intCommodityId INT = NULL,
	@ysnExpired BIT,
	@intFutureMarketId INT = NULL,
	@intEntityId INT = NULL,
	@intBrokerageAccountId INT = NULL,
	@intFutureMonthId INT = NULL,
	@strBuySell NVARCHAR(10) = NULL,
	@intBookId INT = NULL,
	@intSubBookId INT = NULL
AS

SET @dtmFromDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

DECLARE @UnRelaized AS TABLE (
	intFutOptTransactionId INT,
	GrossPnL NUMERIC(24, 10),
	dblLong NUMERIC(24, 10),
	dblShort NUMERIC(24, 10),
	dblFutCommission NUMERIC(24, 10),
	strFutMarketName NVARCHAR(100),
	strFutureMonth NVARCHAR(100),
	dtmTradeDate DATETIME,
	strInternalTradeNo NVARCHAR(100),
	strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strBook NVARCHAR(100),
	strSubBook NVARCHAR(100),
	strSalespersonId NVARCHAR(100),
	strCommodityCode NVARCHAR(100),
	strLocationName NVARCHAR(100),
	Long1 INT,
	Sell1 INT,
	intNet INT,
	dblActual NUMERIC(24, 10),
	dblClosing NUMERIC(24, 10),
	dblPrice NUMERIC(24, 10),
	dblContractSize NUMERIC(24, 10),
	dblFutCommission1 NUMERIC(24, 10),
	MatchLong NUMERIC(24, 10),
	MatchShort NUMERIC(24, 10),
	NetPnL NUMERIC(24, 10),
	intFutureMarketId INT,
	intFutureMonthId INT,
	intOriginalQty INT,
	intFutOptTransactionHeaderId INT,
	MonthOrder NVARCHAR(100),
	RowNum INT,
	intCommodityId INT,
	ysnExpired BIT,
	dblVariationMargin NUMERIC(24, 10),
	dblInitialMargin NUMERIC(24, 10),
	LongWaitedPrice NUMERIC(24, 10),
	ShortWaitedPrice NUMERIC(24, 10)
	)
DECLARE @Relaized AS TABLE (
	dblGrossPL NUMERIC(24, 10),
	intMatchFuturesPSHeaderId INT,
	intMatchFuturesPSDetailId INT,
	intFutOptTransactionId INT,
	intLFutOptTransactionId INT,
	intSFutOptTransactionId INT,
	dblMatchQty NUMERIC(24, 10),
	dtmLTransDate DATETIME,
	dtmSTransDate DATETIME,
	dblLPrice NUMERIC(24, 10),
	dblSPrice NUMERIC(24, 10),
	strLBrokerTradeNo NVARCHAR(100),
	strSBrokerTradeNo NVARCHAR(100),
	dblContractSize NUMERIC(24, 10),
	dblFutCommission NUMERIC(24, 10),
	strFutMarketName NVARCHAR(100),
	strFutureMonth NVARCHAR(100),
	intMatchNo INT,
	dtmMatchDate DATETIME,
	strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCommodityCode NVARCHAR(100),
	strLocationName NVARCHAR(100),
	dblNetPL NUMERIC(24, 10),
	intFutureMarketId INT,
	MonthOrder NVARCHAR(100),
	RowNum INT,
	intCommodityId INT,
	ysnExpired BIT,
	intFutureMonthId INT
	)

INSERT INTO @UnRelaized (
	RowNum,
	MonthOrder,
	intFutOptTransactionId,
	GrossPnL,
	dblLong,
	dblShort,
	dblFutCommission,
	strFutMarketName,
	strFutureMonth,
	dtmTradeDate,
	strInternalTradeNo,
	strName,
	strAccountNumber,
	strBook,
	strSubBook,
	strSalespersonId,
	strCommodityCode,
	strLocationName,
	Long1,
	Sell1,
	intNet,
	dblActual,
	dblClosing,
	dblPrice,
	dblContractSize,
	dblFutCommission1,
	MatchLong,
	MatchShort,
	NetPnL,
	intFutureMarketId,
	intFutureMonthId,
	intOriginalQty,
	intFutOptTransactionHeaderId,
	intCommodityId,
	ysnExpired,
	dblVariationMargin,
	dblInitialMargin,
	LongWaitedPrice,
	ShortWaitedPrice
	)
EXEC uspRKUnrealizedPnL @dtmFromDate = @dtmFromDate,
	@dtmToDate = @dtmToDate,
	@intCommodityId = @intCommodityId,
	@ysnExpired = @ysnExpired,
	@intFutureMarketId = @intFutureMarketId,
	@intEntityId = @intEntityId,
	@intBrokerageAccountId = @intBrokerageAccountId,
	@intFutureMonthId = @intFutureMonthId,
	@strBuySell = @strBuySell,
	@intBookId = @intBookId,
	@intSubBookId = @intSubBookId

INSERT INTO @Relaized (
	RowNum,
	MonthOrder,
	dblNetPL,
	dblGrossPL,
	intMatchFuturesPSHeaderId,
	intMatchFuturesPSDetailId,
	intFutOptTransactionId,
	intLFutOptTransactionId,
	intSFutOptTransactionId,
	dblMatchQty,
	dtmLTransDate,
	dtmSTransDate,
	dblLPrice,
	dblSPrice,
	strLBrokerTradeNo,
	strSBrokerTradeNo,
	dblContractSize,
	dblFutCommission,
	strFutMarketName,
	strFutureMonth,
	intMatchNo,
	dtmMatchDate,
	strName,
	strAccountNumber,
	strCommodityCode,
	strLocationName,
	intFutureMarketId,
	intCommodityId,
	ysnExpired,
	intFutureMonthId
	)
EXEC uspRKRealizedPnL @dtmFromDate = @dtmFromDate,
	@dtmToDate = @dtmToDate,
	@intCommodityId = @intCommodityId,
	@ysnExpired = @ysnExpired,
	@intFutureMarketId = @intFutureMarketId,
	@intEntityId = @intEntityId,
	@intBrokerageAccountId = @intBrokerageAccountId,
	@intFutureMonthId = @intFutureMonthId,
	@strBuySell = @strBuySell,
	@intBookId = @intBookId,
	@intSubBookId = @intSubBookId

BEGIN


DECLARE @Summary AS TABLE (
			intFutureMarketId int,
			intFutureMonthId int,
			strFutMarketName nvarchar(100),
			strFutureMonth nvarchar(100),
			intLongContracts NUMERIC(24, 10),
			dblLongAvgPrice NUMERIC(24, 10),
			intShortContracts NUMERIC(24, 10),
			dblShortAvgPrice NUMERIC(24, 10),
			intNet NUMERIC(24, 10),
			dblUnrealized NUMERIC(24, 10),
			dblClosing NUMERIC(24, 10),
			dblFutCommission NUMERIC(24, 10),
			dblPrice NUMERIC(24, 10),
			dblRealized NUMERIC(24, 10),
			dblVariationMargin NUMERIC(24, 10),
			strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
			strAccountNumber VARCHAR(100) COLLATE Latin1_General_CI_AS,
			dblTotal NUMERIC(24, 10)	
	)
	insert into @Summary (intFutureMarketId ,intFutureMonthId,strFutMarketName,strFutureMonth ,intLongContracts,dblLongAvgPrice ,intShortContracts ,dblShortAvgPrice ,intNet,
					dblUnrealized ,dblClosing ,dblFutCommission ,dblPrice ,dblRealized ,dblVariationMargin,strName ,strAccountNumber,dblTotal)
	SELECT intFutureMarketId ,intFutureMonthId,strFutMarketName,strFutureMonth ,isnull(intLongContracts,0.0) intLongContracts,dblLongAvgPrice ,isnull(intShortContracts,0.0) intShortContracts  ,dblShortAvgPrice ,isnull(intNet,0.0) intNet,
					dblUnrealized ,dblClosing ,dblFutCommission ,dblPrice ,dblRealized ,dblVariationMargin,strName ,strAccountNumber,
		dblUnrealized + dblRealized AS dblTotal
	FROM (
		SELECT intFutureMarketId,
			intFutureMonthId,
			strFutMarketName,
			strFutureMonth,
			SUM(ISNULL(dblLong, 0)) intLongContracts,
			isnull(CASE WHEN SUM(LongWaitedPrice) = 0 THEN NULL ELSE SUM(LongWaitedPrice) / isnull(SUM(ISNULL(dblLong, 0)), NULL) END, 0) dblLongAvgPrice,
			SUM(ISNULL(dblShort, 0)) intShortContracts,
			isnull(CASE WHEN SUM(ShortWaitedPrice) = 0 THEN NULL ELSE SUM(ShortWaitedPrice) / isnull(SUM(ISNULL(dblShort, 0)), NULL) END, 0) dblShortAvgPrice,
			SUM(ISNULL(dblLong, 0)) - SUM(ISNULL(dblShort, 0)) AS intNet,
			isnull(SUM(NetPnL), 0) dblUnrealized,
			isnull(max(dblClosing), 0) dblClosing,
			isnull(SUM(dblFutCommission), 0) dblFutCommission,
			isnull(SUM(dblPrice), 0) AS dblPrice,
			isnull((
					SELECT SUM(dblGrossPL)
					FROM vyuRKRealizedPnL r
					WHERE t.intFutureMarketId = r.intFutureMarketId AND t.intFutureMonthId = r.intFutureMonthId
					), 0) AS dblRealized,
			isnull(SUM(dblVariationMargin), 0) AS dblVariationMargin,
			strName,
			strAccountNumber
		FROM (
			SELECT GrossPnL,
				LongWaitedPrice,
				dblLong,
				dblShort,
				ShortWaitedPrice,
				dblFutCommission,
				intNet,
				intFutOptTransactionId,
				strFutMarketName,
				strFutureMonth,
				intFutureMonthId,
				intCommodityId,
				intFutureMarketId,
				dtmTradeDate,
				dblClosing AS dblClosing,
				dblPrice,
				NetPnL,
				dblVariationMargin,				
				strName,
				strAccountNumber
			FROM @UnRelaized
			
			UNION
			
			SELECT DISTINCT GrossPnL,
				LongWaitedPrice,
				dblLong,
				dblShort,
				ShortWaitedPrice,
				t.dblFutCommission,
				intNet,
				t.intFutOptTransactionId,
				t.strFutMarketName,
				t.strFutureMonth,
				t.intFutureMonthId,
				t.intCommodityId,
				t.intFutureMarketId,
				p.dtmTradeDate,
				dblClosing AS dblClosing,
				dblPrice,
				NetPnL,
				dblVariationMargin,				
				t.strName,
				t.strAccountNumber
			FROM @Relaized t
			LEFT JOIN @UnRelaized p ON t.intFutureMarketId = p.intFutureMarketId AND t.intFutureMonthId = p.intFutureMonthId
			WHERE t.intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN t.intCommodityId ELSE @intCommodityId END AND t.intFutureMarketId = CASE WHEN isnull(@intFutureMarketId, 0) = 0 THEN t.intFutureMarketId ELSE @intFutureMarketId END AND t.intFutureMonthId NOT IN (
					SELECT intFutureMonthId
					FROM @UnRelaized
					)
			) t
		GROUP BY intFutureMonthId,
			intFutureMarketId,
			strFutMarketName,
			strFutureMonth,
			strName,
			strAccountNumber
		) t


		select intFutureMarketId,
			intFutureMonthId,
			strFutMarketName,
			strFutureMonth,
			sum(intLongContracts) intLongContracts,
			sum(dblLongAvgPrice) dblLongAvgPrice,
			sum(intShortContracts) intShortContracts,
			sum(dblShortAvgPrice) dblShortAvgPrice,
			sum(intNet) intNet,
			sum(dblUnrealized) dblUnrealized,
			sum(dblClosing) dblClosing,
			sum(dblFutCommission) dblFutCommission,
			sum(dblPrice) dblPrice,
			sum(dblRealized) dblRealized,
			sum(dblVariationMargin) dblVariationMargin,
			strName ,
			'' strAccountNumber,
			sum(dblTotal) dblTotal,
			sum(dblInitialMargin) dblInitialMargin,
			'' strBook,
			'' strSubBook
			 from(
	SELECT intFutureMarketId,
			intFutureMonthId,
			strFutMarketName,
			strFutureMonth,
			intLongContracts,
			dblLongAvgPrice,
			intShortContracts,
			dblShortAvgPrice,
			intNet,
			dblUnrealized,
			dblClosing,
			dblFutCommission,
			dblPrice,
			dblRealized,
			dblVariationMargin,
			strName ,
			strAccountNumber,
			dblTotal, (case when isnull(dblPerFutureContract,0)>0 then dblPerFutureContract*intNet else 		
		CASE WHEN dblContractMargin <= dblMinAmount THEN dblMinAmount
					WHEN dblContractMargin >= dblMaxAmount THEN dblMaxAmount
					ELSE dblContractMargin END end) as dblInitialMargin
		FROM(
		SELECT t.*,dblMinAmount,dblMaxAmount,dblPercenatage,((intNet*isnull(dblPrice,0)*dblContractSize)*dblPercenatage)/100 as dblContractMargin,
		dblPerFutureContract from @Summary t 
		join tblRKBrokerageAccount ba on t.strAccountNumber=ba.strAccountNumber
		join tblEMEntity e on ba.intEntityId=e.intEntityId and e.strName=t.strName
		join tblRKFutureMarket fm on t.intFutureMarketId=fm.intFutureMarketId
		JOIN tblRKBrokerageCommission bc on bc.intBrokerageAccountId= ba.intBrokerageAccountId )t1)t2
		group by intFutureMarketId,	intFutureMonthId,strFutMarketName,strFutureMonth,strName
		END

	