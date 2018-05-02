CREATE PROCEDURE [dbo].[uspRKGetCommission]
  @intBrokerageAccountId INT,
  @intFutureMarketId INT,
  @dtmTransactionDate DATETIME,
  @intInstrymentTypeId INT,
  @dblCommission NUMERIC(18,6) OUTPUT,
  @intBrokerageCommissionId INT OUTPUT 
AS
BEGIN

	
SELECT @dblCommission = ISNULL(dblFutCommission,0) * -1,@intBrokerageCommissionId= intBrokerageCommissionId FROM (
(SELECT 
		CASE WHEN @intInstrymentTypeId = 1 THEN
			isnull(bc.dblFutCommission,0) / case when cur.ysnSubCurrency = 'true' then cur.intCent else 1 end
		WHEN @intInstrymentTypeId = 2 THEN
			 isnull(bc.dblOptCommission,0) / case when cur.ysnSubCurrency = 'true' then cur.intCent else 1 end
		END AS dblFutCommission
		,intBrokerageCommissionId
		FROM tblRKBrokerageCommission bc
		LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=bc.intFutCurrencyId
		WHERE 
			bc.intFutureMarketId = @intFutureMarketId 
			AND bc.intBrokerageAccountId = @intBrokerageAccountId
			AND  @dtmTransactionDate BETWEEN bc.dtmEffectiveDate and bc.dtmEndDate)
) tbl

SET @dblCommission = ISNULL(@dblCommission,0)

END