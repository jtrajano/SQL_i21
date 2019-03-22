CREATE FUNCTION [dbo].[fnRKGetFutureAndBasisPriceForDate]
(
	@intCommodityId int ,
	@intCompanyLocationId int,
	@dtmTicketDate datetime,
	@intSequenceTypeId int, -- 1.	‘1’ Basis($) ,‘2’ Futures($), ‘3’ Futures and Basis 
	@dblBasisCost NUMERIC(18, 6)
)
RETURNS NUMERIC(18, 6)
AS
BEGIN

	DECLARE @strSeqMonth nvarchar(20)=''
	DECLARE @intFutureMarketId int
	DECLARE @intFutureMonthId int

	SELECT @strSeqMonth=RIGHT(CONVERT(VARCHAR(11),DATEADD(dd, 0, DATEADD(month,  + DATEDIFF(month, 0, @dtmTicketDate),0)),6),6) 

DECLARE @dblScaleBasisValue AS NUMERIC(18, 6)
DECLARE @dblClosingPrice AS NUMERIC(18, 6)
DECLARE @calculatedValue AS NUMERIC(18, 6)
---Scale Basis
SELECT TOP 1 @dblScaleBasisValue= isnull(dblBasis,0),@intFutureMonthId=bd.intFutureMonthId,@intFutureMarketId=bd.intFutureMarketId  FROM tblRKM2MBasis b
JOIN tblRKM2MGrainBasis bd on b.intM2MBasisId=bd.intM2MBasisId 
WHERE  intCommodityId = @intCommodityId and strDeliveryMonth = @strSeqMonth	AND ISNULL(dblBasis,0) <> 0 
	AND  intCompanyLocationId=@intCompanyLocationId 
ORDER BY dtmM2MBasisDate Desc

--FutureSettlemnt Price
SELECT @dblClosingPrice=dbo.fnRKGetLatestClosingPrice(@intFutureMarketId,@intFutureMonthId,@dtmTicketDate)

If @intSequenceTypeId = 1
	SET @calculatedValue = isnull(@dblScaleBasisValue,0)
ELSE IF @intSequenceTypeId = 2
	SET @calculatedValue = isnull(@dblClosingPrice,0)+@dblBasisCost
ELSE
	SET @calculatedValue = isnull(@dblClosingPrice,0)+isnull(@dblScaleBasisValue,0)

	RETURN @calculatedValue
END