
CREATE TRIGGER trgRKAfterUpdateDerivativeEntry
   ON  tblRKFutOptTransaction
   AFTER  UPDATE
AS 

DECLARE @intFutOptTransactionId AS INT,
		@intBrokerageAccountId AS INT,
		@intFutureMarketId AS INT,
		@dtmTransactionDate AS DATETIME,
		@intInstrumentTypeId AS INT,
		@dblCommission AS NUMERIC(18,6),
		@intBrokerageCommissionId AS INT
BEGIN
	
	SET NOCOUNT ON;

    SELECT 
		 @intFutOptTransactionId = intFutOptTransactionId
		,@intBrokerageAccountId = intBrokerageAccountId
		,@intFutureMarketId = intFutureMarketId
		,@dtmTransactionDate = dtmTransactionDate
		,@intInstrumentTypeId = intInstrumentTypeId
	 FROM inserted

	 EXEC uspRKGetCommission @intBrokerageAccountId, @intFutureMarketId, @dtmTransactionDate, @intInstrumentTypeId, @dblCommission OUT, @intBrokerageCommissionId OUT

	 UPDATE tblRKFutOptTransaction SET 
		 dblCommission = @dblCommission
		,intBrokerageCommissionId = @intBrokerageCommissionId
	WHERE intFutOptTransactionId = @intFutOptTransactionId


END
GO