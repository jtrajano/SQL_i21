CREATE PROCEDURE [dbo].[uspRKProcessReconciliationBrokerStatement]
	@intReconciliationBrokerStatementHeaderId INT
	, @strAction NVARCHAR(50)
	, @intUserId INT

AS

BEGIN
	IF (UPPER(@strAction) = 'HEADER DELETE')
	BEGIN
		
		UPDATE tblRKFutOptTransaction
		SET ysnFreezed = 0
		FROM (
			SELECT e.intEntityId
				, strBrokerName = e.strName
				, ba.intBrokerageAccountId
				, ba.strAccountNumber
				, fm.intFutureMarketId
				, fm.strFutMarketName
				, fmon.intFutureMonthId
				, fmon.strFutureMonth
				, c.intCommodityId
				, c.strCommodityCode
				, strBuySell
				, dblNoOfContract
				, dtmFilledDate
				, dblPrice
			FROM tblRKReconciliationBrokerStatement rbs
			JOIN tblEMEntity e ON e.strName = rbs.strName
			JOIN tblRKBrokerageAccount ba ON ba.strAccountNumber = rbs.strAccountNumber
			JOIN tblRKFutureMarket fm ON fm.strFutMarketName = rbs.strFutMarketName
			JOIN tblICCommodity c ON c.strCommodityCode = rbs.strCommodityCode
			JOIN tblRKFuturesMonth fmon ON fmon.strFutureMonth = rbs.strFutureMonth
			WHERE intReconciliationBrokerStatementHeaderId = @intReconciliationBrokerStatementHeaderId
		) t
		WHERE t.intFutureMarketId = tblRKFutOptTransaction.intFutureMarketId
			AND t.intCommodityId = tblRKFutOptTransaction.intCommodityId
			AND t.intEntityId = tblRKFutOptTransaction.intEntityId
			AND t.dtmFilledDate = tblRKFutOptTransaction.dtmFilledDate
			AND t.intBrokerageAccountId = tblRKFutOptTransaction.intBrokerageAccountId
			AND tblRKFutOptTransaction.intInstrumentTypeId = 1
			AND tblRKFutOptTransaction.intSelectedInstrumentTypeId = 1 AND ISNULL(ysnFreezed, 0) = 1

		--SELECT *
		--INTO #tmpDerivatives
		--FROM tblRKFutOptTransaction
		--WHERE intFutureMarketId = @intFutureMarketId
		--	AND intCommodityId = @intCommodityId
		--	AND intEntityId = @intBrokerId
		--	AND CONVERT(NVARCHAR, dtmFilledDate, @ConvertYear) = CONVERT(NVARCHAR, @dtmFilledDate, @ConvertYear)
		--	AND intBrokerageAccountId = CASE WHEN ISNULL(@intBorkerageAccountId, 0) = 0 THEN intBrokerageAccountId ELSE @intBorkerageAccountId END
		--	AND intInstrumentTypeId = 1
		--	AND intSelectedInstrumentTypeId = 1 AND ISNULL(ysnFreezed, 0) = 0


		--WHILE EXISTS (SELECT TOP 1 1 FROM #tmpDerivatives)
		--BEGIN
		--	SELECT TOP 1 @intDerivativeEntryId = intFutOptTransactionId FROM #tmpDerivatives

		--	EXEC uspSMAuditLog @keyValue = @intDerivativeEntryId
		--		,@screenName = 'RiskManagement.view.DerivativeEntry'
		--		,@entityId = @intUserId
		--		,@actionType = 'Reconciled'
		--		,@changeDescription = 'Freeze'
		--		,@fromValue = 'False'
		--		,@toValue = 'True'

		--	DELETE FROM #tmpDerivatives WHERE intFutOptTransactionId = @intDerivativeEntryId
		--END

		--DROP TABLE #tmpDerivatives
	END
END