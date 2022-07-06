CREATE PROCEDURE [dbo].[uspRKGetCommission]
	@intBrokerageAccountId INT
	, @intFutureMarketId INT
	, @dtmTransactionDate DATETIME
	, @intInstrumentTypeId INT

AS

BEGIN
	
	IF  @intInstrumentTypeId = 2 
	BEGIN

		SELECT TOP 1 dblCommissionRate = ISNULL(ISNULL(bc.dblOptCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END,0)
			,strCommissionRateType =  CASE WHEN bc.intOptionsRateType = 1 THEN 'Half-turn' ELSE '' END
			,intBrokerageCommissionId
		FROM tblRKBrokerageCommission bc
		LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = bc.intFutCurrencyId
		WHERE bc.intFutureMarketId = @intFutureMarketId
			AND bc.intBrokerageAccountId = @intBrokerageAccountId
			AND @dtmTransactionDate BETWEEN bc.dtmEffectiveDate AND isnull(bc.dtmEndDate,getdate())
	END
	ELSE
	BEGIN
		
		SELECT TOP 1 dblCommissionRate = CASE WHEN bc.intFuturesRateType = 1 THEN ISNULL((ISNULL(bc.dblFutCommission, 0) / 2) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END,0)
											ELSE ISNULL(ISNULL(bc.dblFutCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END,0) END 
			,strCommissionRateType = CASE WHEN bc.intFuturesRateType = 1 THEN 'Round-turn' ELSE 'Half-turn' END 
			,intBrokerageCommissionId
		FROM tblRKBrokerageCommission bc
		LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = bc.intFutCurrencyId
		WHERE bc.intFutureMarketId = @intFutureMarketId
			AND bc.intBrokerageAccountId = @intBrokerageAccountId
			AND @dtmTransactionDate BETWEEN bc.dtmEffectiveDate AND isnull(bc.dtmEndDate,getdate())
	END
	
END