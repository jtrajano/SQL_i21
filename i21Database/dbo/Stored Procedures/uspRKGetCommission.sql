CREATE PROCEDURE [dbo].[uspRKGetCommission]
	@intBrokerageAccountId INT
	, @intFutureMarketId INT
	, @dtmTransactionDate DATETIME
	, @intInstrymentTypeId INT
	, @dblCommission NUMERIC(18,6) OUTPUT
	, @intBrokerageCommissionId INT OUTPUT

AS

BEGIN
	SELECT @dblCommission = ISNULL(dblFutCommission, 0) * -1
		, @intBrokerageCommissionId = intBrokerageCommissionId
	FROM (
		SELECT CASE WHEN @intInstrymentTypeId = 1 THEN ISNULL(bc.dblFutCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END
					WHEN @intInstrymentTypeId = 2 THEN ISNULL(bc.dblOptCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END END AS dblFutCommission
			, intBrokerageCommissionId
		FROM tblRKBrokerageCommission bc
		LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = bc.intFutCurrencyId
		WHERE bc.intFutureMarketId = @intFutureMarketId
			AND bc.intBrokerageAccountId = @intBrokerageAccountId
			AND @dtmTransactionDate BETWEEN bc.dtmEffectiveDate AND isnull(bc.dtmEndDate,getdate())
	) tbl
	
	SET @dblCommission = ISNULL(@dblCommission,0)
END