CREATE PROC uspRKFreezeFutOptTransaction
	@dtmFilledDate datetime,
	@intFutureMarketId	int,
	@intCommodityId	int ,
	@intBrokerId	int ,
	@intBorkerageAccountId	int=null

AS

IF EXISTS(SELECT * FROM tblRKFutOptTransaction WHERE intFutureMarketId=@intFutureMarketId and intCommodityId=@intCommodityId AND intEntityId = @intBrokerId 
	AND dtmFilledDate <= @dtmFilledDate AND intBrokerageAccountId=CASE WHEN ISNULL(@intBorkerageAccountId,0)=0 THEN intBrokerageAccountId ELSE @intBorkerageAccountId END 
	AND isnull(ysnFreezed,0) = 0 AND intInstrumentTypeId=1 AND intSelectedInstrumentTypeId=1)
BEGIN
	UPDATE tblRKFutOptTransaction SET ysnFreezed=1 WHERE intFutureMarketId=@intFutureMarketId and intCommodityId=@intCommodityId and intEntityId = @intBrokerId 
	AND dtmFilledDate <= @dtmFilledDate AND intBrokerageAccountId = CASE WHEN ISNULL(@intBorkerageAccountId,0)=0 THEN intBrokerageAccountId ELSE @intBorkerageAccountId END 
	AND ISNULL(ysnFreezed,0) = 0
	AND intInstrumentTypeId=1 AND intSelectedInstrumentTypeId=1
END