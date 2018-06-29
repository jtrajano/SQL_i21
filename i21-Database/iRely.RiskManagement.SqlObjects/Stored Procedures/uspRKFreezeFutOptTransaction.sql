CREATE PROC uspRKFreezeFutOptTransaction
	@dtmFilledDate datetime,
	@intFutureMarketId	int,
	@intCommodityId	int ,
	@intBrokerId	int ,
	@intBorkerageAccountId	int=null,
	@intReconciliationBrokerStatementHeaderId int

AS

BEGIN
	UPDATE tblRKFutOptTransaction SET ysnFreezed=1 
	WHERE intFutureMarketId=@intFutureMarketId and intCommodityId=@intCommodityId and intEntityId = @intBrokerId 
	AND CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmFilledDate,110),101) = convert(datetime,CONVERT(VARCHAR(10),@dtmFilledDate,110),101) 
	AND intBrokerageAccountId = CASE WHEN ISNULL(@intBorkerageAccountId,0)=0 THEN intBrokerageAccountId ELSE @intBorkerageAccountId END 
	AND ISNULL(ysnFreezed,0) = 0
	AND intInstrumentTypeId=1 AND intSelectedInstrumentTypeId=1

	update tblRKReconciliationBrokerStatementHeader set ysnFreezed = 1 where intReconciliationBrokerStatementHeaderId=@intReconciliationBrokerStatementHeaderId

END
