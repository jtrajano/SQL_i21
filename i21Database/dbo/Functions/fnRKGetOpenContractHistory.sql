CREATE FUNCTION [dbo].[fnRKGetOpenContractHistory] (
	@dtmDateAsOf DATETIME)

RETURNS @Result TABLE(
	intFutOptTransactionId INT
	, dblOpenContract NUMERIC(18, 6))

AS

BEGIN

	SET @dtmDateAsOf = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmDateAsOf, 110), 110)

	INSERT INTO @Result
	SELECT DISTINCT intFutOptTransactionId
		, (dblNoOfContract - ISNULL(dblOpenContract, 0)) dblOpenContract
	FROM (
		SELECT ot.intFutOptTransactionId
			, SUM(ot.dblNoOfContract) dblNoOfContract
			, (SELECT SUM(mf.dblMatchQty)
				FROM tblRKMatchDerivativesHistory mf
				WHERE ot.intFutOptTransactionId = mf.intLFutOptTransactionId
					AND mf.dtmMatchDate <= @dtmDateAsOf) dblOpenContract
		FROM tblRKFutOptTransaction ot
		WHERE ot.strBuySell = 'Buy' AND intInstrumentTypeId = 1
		GROUP BY intFutOptTransactionId
	) t

	UNION ALL SELECT DISTINCT intFutOptTransactionId
		, - (dblNoOfContract - ISNULL(dblOpenContract, 0)) dblOpenContract
	FROM (
		SELECT ot.intFutOptTransactionId
			, SUM(ot.dblNoOfContract) dblNoOfContract
			, (SELECT SUM(mf.dblMatchQty)
				FROM tblRKMatchDerivativesHistory mf
				WHERE ot.intFutOptTransactionId = mf.intSFutOptTransactionId
					AND mf.dtmMatchDate <= @dtmDateAsOf) dblOpenContract
		FROM tblRKFutOptTransaction ot
		WHERE ot.strBuySell = 'Sell' AND intInstrumentTypeId = 1
		GROUP BY intFutOptTransactionId
	) t

	UNION ALL SELECT DISTINCT intFutOptTransactionId
		, (ISNULL(dblNoOfContract, 0) - ISNULL(dblOpenContract, 0)) dblOpenContract
	FROM (
		SELECT ot.intFutOptTransactionId
			, SUM(ISNULL(ot.dblNoOfContract, 0)) dblNoOfContract
			, (SELECT SUM(mf.dblMatchQty)
				FROM tblRKMatchDerivativesHistoryForOption mf
				WHERE ot.intFutOptTransactionId = mf.intLFutOptTransactionId
					AND mf.dtmMatchDate <= @dtmDateAsOf) dblOpenContract
		FROM tblRKFutOptTransaction ot
		WHERE ot.strBuySell = 'Buy' AND intInstrumentTypeId = 2
		GROUP BY intFutOptTransactionId
	) t

	UNION ALL SELECT DISTINCT intFutOptTransactionId
		, - (dblNoOfContract - ISNULL(dblOpenContract, 0)) dblOpenContract
	FROM (
		SELECT ot.intFutOptTransactionId
			, SUM(ot.dblNoOfContract) dblNoOfContract
			, (SELECT SUM(mf.dblMatchQty)
				FROM tblRKMatchDerivativesHistoryForOption mf
				WHERE ot.intFutOptTransactionId = mf.intSFutOptTransactionId
					AND mf.dtmMatchDate <= @dtmDateAsOf) dblOpenContract
		FROM tblRKFutOptTransaction ot
		WHERE ot.strBuySell = 'Sell' AND intInstrumentTypeId = 2
		GROUP BY intFutOptTransactionId
	) t

RETURN
END