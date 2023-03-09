CREATE PROCEDURE [dbo].[uspRKLOptionPSTransaction]
	@intTypeId INT 
	, @intEntityId INT
	, @intFutureMarketId INT
	, @intCommodityId INT
	, @intOptionMonthId INT
	, @dblStrike NUMERIC(18,6)
	, @dtmPositionAsOf DATETIME 

AS  

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	SELECT AD.intLFutOptTransactionId
		, dblSelectedLot = SUM(AD.dblMatchQty)
	INTO #SelectedLots
	FROM tblRKOptionsMatchPnS AD
	WHERE CAST(FLOOR(CAST(dtmMatchDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmPositionAsOf AS FLOAT)) AS DATETIME)
	GROUP BY AD.intLFutOptTransactionId

	SELECT ope.intFutOptTransactionId
		, intExpiredLots = SUM(dblLots)
	INTO #ExpiredLots
	FROM tblRKOptionsPnSExpired ope
	WHERE CAST(FLOOR(CAST(dtmExpiredDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmPositionAsOf AS FLOAT)) AS DATETIME)
	GROUP BY ope.intFutOptTransactionId

	SELECT opa.intFutOptTransactionId
		, intAssignedLots = SUM(dblLots)
	INTO #AssignedLots
	FROM tblRKOptionsPnSExercisedAssigned opa
	WHERE CAST(FLOOR(CAST(dtmTranDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmPositionAsOf AS FLOAT)) AS DATETIME)
	GROUP BY opa.intFutOptTransactionId

	SELECT dblStrike
		, strInternalTradeNo
		, dtmTransactionDate
		, dtmFilledDate
		, strFutMarketName
		, strOptionMonth
		, strName
		, strAccountNumber
		, dblTotalLot = ISNULL(dblTotalLot, 0)
		, dblOpenLots = CAST(ISNULL(dblOpenLots, 0) AS NUMERIC(18, 6))
		, strOptionType
		, dblPremium = - dblPremiumInBucks
		, dblPremiumValue = - dblPremiumValue
		, dblCommission
		, intFutOptTransactionId
		, dblNetPremium = (dblPremiumValue) + (dblCommission)
		, dblMarketPremium
		, dblMarketValue
		, dblMTM = (CASE WHEN strBuySell = 'B' THEN dblMarketValue - dblPremiumValue ELSE dblPremiumValue - dblMarketValue END)
		, strStatus
		, strCommodityCode
		, strLocationName
		, strBook
		, strSubBook
		, dblDelta
		, dblDeltaHedge = - (dblOpenLots * dblDelta * dblContractSize)
		, strHedgeUOM
		, strBuySell
		, dblContractSize
		, intFutOptTransactionHeaderId
		, intCurrencyId
		, strCurrency
		, intMainCurrencyId
		, strMainCurrency
		, intCent
		, ysnSubCurrency
		, dtmExpirationDate
		, ysnExpired
		, intTypeId
		, intEntityId
		, intFutureMarketId
		, intCommodityId
		, intOptionMonthId
	FROM (
		SELECT dblOpenLots = (dblTotalLot - dblSelectedLot1 - intExpiredLots - intAssignedLots)
			, dblSelectedLot = ''
			, dblPremiumValue = ((dblTotalLot - dblSelectedLot1) * dblContractSize * dblPremium) 
			, dblMarketValue = ((dblTotalLot - dblSelectedLot1) * dblContractSize * dblMarketPremium) / (CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END)
			, dblCommission = (- dblOptCommission * (dblTotalLot - dblSelectedLot1)) / (CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END)
			, *
		FROM (
			SELECT DISTINCT strInternalTradeNo
				, dtmTransactionDate
				, ot.dtmFilledDate
				, fm.strFutMarketName
				, om.strOptionMonth
				, e.strName
				, ba.strAccountNumber
				, dblTotalLot = ot.dblNoOfContract
				, dblSelectedLot1 = ISNULL(sl.dblSelectedLot, 0)
				, ot.strOptionType
				, ot.dblStrike
				, dblPremiumInBucks = ot.dblPrice
				, dblPremium = ot.dblPrice / (CASE WHEN c.ysnSubCurrency = 1 THEN c.intCent ELSE 1 END)
				, fm.dblContractSize
				, dblOptCommission = ISNULL((select TOP 1 (case when bc.intOptionsRateType = 2 then 0
															else  isnull(bc.dblOptCommission,0) end) as dblOptCommission
										from tblRKBrokerageCommission bc
										where bc.intFutureMarketId = ot.intFutureMarketId and bc.intBrokerageAccountId = ot.intBrokerageAccountId
											and  getdate() between bc.dtmEffectiveDate and isnull(bc.dtmEndDate,getdate())),0) 
				, om.dtmExpirationDate
				, ot.strStatus
				, ic.strCommodityCode
				, cl.strLocationName
				, strBook
				, strSubBook
				, dblMarketPremium = ISNULL((SELECT TOP 1 dblSettle
											FROM tblRKFuturesSettlementPrice sp
											JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId = spm.intFutureSettlementPriceId
											WHERE 
												sp.intFutureMarketId  = ot.intFutureMarketId
												AND spm.intOptionMonthId = ot.intOptionMonthId
												AND spm.dblStrike = ot.dblStrike  
												AND spm.intTypeId = (CASE WHEN ot.strOptionType = 'Put' THEN 1 ELSE 2 END)
												AND CAST(FLOOR(CAST(sp.dtmPriceDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmPositionAsOf AS FLOAT)) AS DATETIME)
											ORDER BY sp.dtmPriceDate DESC), 0)
				, MarketValue = ''
				, MTM = ''
				, ot.intOptionMonthId
				, ot.intFutureMarketId
				, dblDelta = ISNULL((SELECT TOP 1 dblDelta
											FROM tblRKFuturesSettlementPrice sp
											JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId = spm.intFutureSettlementPriceId
											WHERE 
												sp.intFutureMarketId  = ot.intFutureMarketId
												AND spm.intOptionMonthId = ot.intOptionMonthId
												AND spm.dblStrike = ot.dblStrike
												AND spm.intTypeId = (CASE WHEN ot.strOptionType = 'Put' THEN 1 ELSE 2 END)
												AND CAST(FLOOR(CAST(sp.dtmPriceDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmPositionAsOf AS FLOAT)) AS DATETIME)
											ORDER BY sp.dtmPriceDate DESC), 0)
				, DeltaHedge = ''
				, strHedgeUOM = um.strUnitMeasure
				, strBuySell = CASE WHEN strBuySell = 'Buy' THEN 'B' ELSE 'S' END
				, ot.intFutOptTransactionId
				, intExpiredLots = ISNULL(el.intExpiredLots, 0)
				, intAssignedLots = ISNULL(al.intAssignedLots, 0)
				, intCurrencyId = c.intCurrencyID
				, c.strCurrency
				, intMainCurrencyId = CASE WHEN c.ysnSubCurrency = 1 THEN c.intMainCurrencyId ELSE c.intCurrencyID END
				, strMainCurrency = CASE WHEN c.ysnSubCurrency = 0 THEN c.strCurrency ELSE MainCurrency.strCurrency END
				, c.intCent
				, c.ysnSubCurrency
				, intFutOptTransactionHeaderId
				, ysnExpired = (CASE WHEN CAST(FLOOR(CAST(dtmExpirationDate AS FLOAT)) AS DATETIME) < CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END)
				, intTypeId = (CASE WHEN ot.strOptionType = 'Put' THEN 1 ELSE 2 END)
				, ot.intEntityId
				, ot.intCommodityId
			FROM tblRKFutOptTransaction ot
			JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = ot.intFutureMarketId AND ot.strStatus = 'Filled'
			JOIN tblICUnitMeasure um ON fm.intUnitMeasureId = um.intUnitMeasureId
			JOIN tblICCommodity ic ON ic.intCommodityId = ot.intCommodityId
			JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = ot.intLocationId
			JOIN tblRKOptionsMonth om ON ot.intOptionMonthId = om.intOptionMonthId
			JOIN tblRKBrokerageAccount ba ON ot.intBrokerageAccountId = ba.intBrokerageAccountId
			JOIN tblEMEntity e ON e.intEntityId = ot.intEntityId
			LEFT JOIN tblRKBrokerageCommission bc ON bc.intFutureMarketId = ot.intFutureMarketId AND ba.intBrokerageAccountId = bc.intBrokerageAccountId
			LEFT JOIN tblSMCurrency c ON c.intCurrencyID = fm.intCurrencyId
			LEFT JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = c.intMainCurrencyId
			LEFT JOIN tblCTBook b ON b.intBookId = ot.intBookId
			LEFT JOIN tblCTSubBook sb ON sb.intSubBookId = ot.intSubBookId
			LEFT JOIN #SelectedLots sl ON sl.intLFutOptTransactionId = ot.intFutOptTransactionId
			LEFT JOIN #ExpiredLots el ON el.intFutOptTransactionId = ot.intFutOptTransactionId
			LEFT JOIN #AssignedLots al ON al.intFutOptTransactionId = ot.intFutOptTransactionId
			--LEFT JOIN #MarketPremium mp ON mp.intFutureMarketId = ot.intFutureMarketId
			--	AND mp.intOptionMonthId = ot.intOptionMonthId
			--	AND ot.dblStrike = mp.dblStrike
			--	AND mp.intTypeId = (CASE WHEN ot.strOptionType = 'Put' THEN 1 ELSE 2 END)
			WHERE ot.intInstrumentTypeId = 2 AND strBuySell = 'Buy'
			) t
		) t1
	WHERE dblOpenLots > 0
	AND ISNULL(intTypeId, 0) = CASE WHEN ISNULL(@intTypeId, 0) = 0 THEN ISNULL(intTypeId, 0) ELSE @intTypeId END
	AND ISNULL(intEntityId, 0) = CASE WHEN ISNULL(@intEntityId, 0) = 0 THEN ISNULL(intEntityId, 0) ELSE @intEntityId END
	AND ISNULL(intFutureMarketId, 0) = CASE WHEN ISNULL(@intFutureMarketId, 0) = 0 THEN ISNULL(intFutureMarketId, 0) ELSE @intFutureMarketId END
	AND ISNULL(intCommodityId, 0) = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN ISNULL(intCommodityId, 0) ELSE @intCommodityId END
	AND ISNULL(intOptionMonthId, 0) = CASE WHEN ISNULL(@intOptionMonthId, 0) = 0 THEN ISNULL(intOptionMonthId, 0) ELSE @intOptionMonthId END
	AND ISNULL(dblStrike, 0) = CASE WHEN ISNULL(@dblStrike, 0) = 0 THEN ISNULL(dblStrike, 0) ELSE @dblStrike END 
	AND CAST(FLOOR(CAST(dtmFilledDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmPositionAsOf AS FLOAT)) AS DATETIME)

	DROP TABLE #SelectedLots
	--DROP TABLE #MarketPremium
	DROP TABLE #ExpiredLots
	DROP TABLE #AssignedLots

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH