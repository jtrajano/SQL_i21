CREATE PROCEDURE [dbo].[uspRKFixDerivativeCommonIssues]
AS
BEGIN
	BEGIN TRAN

	-----------------------------------------------------------------------
	--				FIX INCORRECT DERIVATIVE FUTURE MONTH				 --
	-----------------------------------------------------------------------
	SELECT intFutOptTransactionId
		, strInternalTradeNo
		, futMonth.strFutureMonth
		, intFutureMarketId = der.intFutureMarketId
		, intFutureMonthMarketId = marketByFutureMonth.intFutureMarketId
		, intDerivativeFutureMonthId = der.intFutureMonthId
		, [Derivative Future Market] = marketActual.strFutMarketName
		, [Future Month's Future Market] = marketByFutureMonth.strFutMarketName
	INTO #tmpIncorrectFutureMonthIdByFutureMarket
	FROM tblRKFutOptTransaction der
	INNER JOIN tblRKFuturesMonth futMonth
		ON futMonth.intFutureMonthId = der.intFutureMonthId
		AND futMonth.intFutureMarketId <> der.intFutureMarketId
	LEFT JOIN tblRKFutureMarket marketActual
		ON marketActual.intFutureMarketId = der.intFutureMarketId
	LEFT JOIN tblRKFutureMarket marketByFutureMonth
		ON marketByFutureMonth.intFutureMarketId = futMonth.intFutureMarketId
	
	SELECT intFutOptTransactionId
		, strInternalTradeNo
		, [Old Future Month Id] = der.intDerivativeFutureMonthId
		, [Old Future Month] = der.strFutureMonth
		, [Correct Future Month Id] = fmonth.intFutureMonthId
		, [Correct Future Month] = fmonth.strFutureMonth
	INTO #tmpDerivativesToBeFixed
	FROM #tmpIncorrectFutureMonthIdByFutureMarket der
	INNER JOIN tblRKFuturesMonth fmonth
		ON fmonth.intFutureMarketId = der.intFutureMarketId
		AND fmonth.strFutureMonth = der.strFutureMonth

	
	IF EXISTS (SELECT TOP 1 1 FROM #tmpDerivativesToBeFixed)
	BEGIN 
		UPDATE der 
		SET der.intFutureMonthId = dtbf.[Correct Future Month Id]
		FROM tblRKFutOptTransaction der
		INNER JOIN #tmpDerivativesToBeFixed dtbf
		ON dtbf.intFutOptTransactionId = der.intFutOptTransactionId

		UPDATE der
		SET der.intFutureMonthId = dtbf.[Correct Future Month Id]
		FROM tblRKSummaryLog der
		INNER JOIN #tmpDerivativesToBeFixed dtbf
		ON dtbf.intFutOptTransactionId = der.intFutOptTransactionId
		AND dtbf.intFutOptTransactionId = der.intTransactionRecordId
		WHERE der.strTransactionType = 'Derivative Entry'
	END

	DROP TABLE #tmpIncorrectFutureMonthIdByFutureMarket
	DROP TABLE #tmpDerivativesToBeFixed
	


	-----------------------------------------------------------------------
	--				FIX DERIVATIVE WITH MISSING CURRENCY				 --
	-----------------------------------------------------------------------
	IF EXISTS (SELECT TOP 1 1 FROM tblRKFutOptTransaction der
				LEFT JOIN tblRKFutureMarket market
					ON market.intFutureMarketId = der.intFutureMarketId
				WHERE der.intCurrencyId IS NULL)
	BEGIN
		UPDATE der
		SET intCurrencyId = market.intCurrencyId
		FROM tblRKFutOptTransaction der
		LEFT JOIN tblRKFutureMarket market
			ON market.intFutureMarketId = der.intFutureMarketId
		WHERE der.intCurrencyId IS NULL
	END

	
	-----------------------------------------------------------------------
	--	 FIX ON ACTUAL DERIVATIVE TABLE WITH MISSING PRE-CRUSH VALUE	 --
	-----------------------------------------------------------------------
	IF EXISTS (SELECT TOP 1 1 FROM tblRKFutOptTransaction 
				WHERE ysnPreCrush IS NULL)
	BEGIN
		UPDATE tblRKFutOptTransaction 
		SET ysnPreCrush = 0
		WHERE ysnPreCrush IS NULL
	END 

	COMMIT TRAN
END