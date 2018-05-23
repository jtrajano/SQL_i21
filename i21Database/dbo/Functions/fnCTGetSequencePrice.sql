CREATE FUNCTION [dbo].[fnCTGetSequencePrice]
(
	@intContractDetailId		INT
)
RETURNS NUMERIC(24,6)
AS 
BEGIN 
    DECLARE --@intContractDetailId	  INT = 5712,
		  @intPriceFixationId	  INT,
		  @intPricingTypeId	  INT,
		  @dblWtdAvg			  NUMERIC(18,6),
		  @dblLotsFixed		  NUMERIC(18,6),
		  @dbldblNoOfLots	   NUMERIC(18,6),
		  @intFutureMarketId	  INT, 
		  @intFutureMonthId	  INT,
		  @dblSeqPrice		  NUMERIC(18,6)

    SELECT  @intPricingTypeId = intPricingTypeId,@dbldblNoOfLots = dblNoOfLots, @intFutureMarketId = intFutureMarketId, @intFutureMonthId = intFutureMonthId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
    SELECT  @intPriceFixationId = intPriceFixationId,@dblLotsFixed = dblLotsFixed from tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId

    IF @intPricingTypeId IN (1,6)
    BEGIN
	   SELECT	 @dblSeqPrice = dblSeqPrice FROM dbo.fnCTGetAdditionalColumnForDetailView(@intContractDetailId)
    END
    ELSE IF @intPricingTypeId = 2 
    BEGIN
	   IF @intPriceFixationId IS NOT NULL
	   BEGIN
		  SELECT @dblWtdAvg =  SUM(dblNoOfLots * dblFutures) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId
		  SELECT @dblSeqPrice = ((@dbldblNoOfLots - @dblLotsFixed) * dbo.fnRKGetLatestClosingPrice(@intFutureMarketId, @intFutureMonthId, GETDATE()) + @dblWtdAvg)/@dbldblNoOfLots
	   END
	   ELSE
	   BEGIN
		  SELECT @dblSeqPrice = NULL
	   END
    END

    RETURN @dblSeqPrice
END