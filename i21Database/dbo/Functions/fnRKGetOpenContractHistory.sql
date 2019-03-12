CREATE FUNCTION [dbo].[fnRKGetOpenContractHistory] (
	@dtmDateAsOf DATETIME)

RETURNS @Result TABLE(
	intFutOptTransactionId INT
	, intOpenContract INT)

AS

BEGIN

	SET @dtmDateAsOf = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmDateAsOf, 110), 110)

	INSERT INTO @Result
	SELECT DISTINCT intFutOptTransactionId
		, (intNoOfContract - ISNULL(intOpenContract, 0)) intOpenContract
	FROM (
		SELECT ot.intFutOptTransactionId
			, SUM(ot.dblNoOfContract) intNoOfContract
			, (SELECT SUM(CONVERT(int, mf.dblMatchQty))
				FROM tblRKMatchDerivativesHistory mf
				WHERE ot.intFutOptTransactionId = mf.intLFutOptTransactionId
					AND mf.dtmMatchDate <= @dtmDateAsOf) intOpenContract
		FROM tblRKFutOptTransaction ot
		WHERE ot.strBuySell = 'Buy' AND intInstrumentTypeId = 1
		GROUP BY intFutOptTransactionId
	) t

	UNION ALL SELECT DISTINCT intFutOptTransactionId
		, - (intNoOfContract - ISNULL(intOpenContract, 0)) intOpenContract
	FROM (
		SELECT ot.intFutOptTransactionId
			, SUM(ot.dblNoOfContract) intNoOfContract
			, (SELECT SUM(CONVERT(int, mf.dblMatchQty))
				FROM tblRKMatchDerivativesHistory mf
				WHERE ot.intFutOptTransactionId = mf.intSFutOptTransactionId
					AND mf.dtmMatchDate <= @dtmDateAsOf) intOpenContract
		FROM tblRKFutOptTransaction ot
		WHERE ot.strBuySell = 'Sell' AND intInstrumentTypeId = 1
		GROUP BY intFutOptTransactionId
	) t

	UNION ALL SELECT DISTINCT intFutOptTransactionId
		, (ISNULL(intNoOfContract, 0) - ISNULL(intOpenContract, 0)) intOpenContract
	FROM (
		SELECT ot.intFutOptTransactionId
			, SUM(ISNULL(ot.dblNoOfContract, 0)) intNoOfContract
			, (SELECT SUM(CONVERT(int, mf.dblMatchQty))
				FROM tblRKMatchDerivativesHistoryForOption mf
				WHERE ot.intFutOptTransactionId = mf.intLFutOptTransactionId
					AND mf.dtmMatchDate <= @dtmDateAsOf) intOpenContract
		FROM tblRKFutOptTransaction ot
		WHERE ot.strBuySell = 'Buy' AND intInstrumentTypeId = 2
		GROUP BY intFutOptTransactionId
	) t

	UNION ALL SELECT DISTINCT intFutOptTransactionId
		, - (intNoOfContract - ISNULL(intOpenContract, 0)) intOpenContract
	FROM (
		SELECT ot.intFutOptTransactionId
			, SUM(ot.dblNoOfContract) intNoOfContract
			, (SELECT SUM(CONVERT(int, mf.dblMatchQty))
				FROM tblRKMatchDerivativesHistoryForOption mf
				WHERE ot.intFutOptTransactionId = mf.intSFutOptTransactionId
					AND mf.dtmMatchDate <= @dtmDateAsOf) intOpenContract
		FROM tblRKFutOptTransaction ot
		WHERE ot.strBuySell = 'Sell' AND intInstrumentTypeId = 2
		GROUP BY intFutOptTransactionId
	) t

RETURN
END