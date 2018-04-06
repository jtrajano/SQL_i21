CREATE PROCEDURE uspRKPnLBySalesContractSummary
  	    @intSContractDetailId	INT,
		@intCurrencyId			INT,-- currency
		@intUnitMeasureId		INT,--- Price uom	
		@intWeightUOMId			INT -- weight 
AS

DECLARE @PhysicalFuturesResult TABLE (
	intRowNum INT
	,strContractType NVARCHAR(50)
	,strNumber NVARCHAR(50)
	,strDescription NVARCHAR(50)
	,strConfirmed NVARCHAR(50)
	,dblAllocatedQty NUMERIC(18, 6)
	,dblPrice NUMERIC(18, 6)
	,strCurrency NVARCHAR(50)
	,dblFX NUMERIC(18, 6)
	,dblBooked NUMERIC(18, 6)
	,dblAccounting NUMERIC(18, 6)
	,dtmDate DATETIME
	,strType Nvarchar(100)
	,dblTranValue NUMERIC(18, 6)
	,intSort INT
	,dblTransactionValue NUMERIC(18, 6)
	,dblForecast NUMERIC(18, 6)
	,dblBasisUSD NUMERIC(18, 6)
	,dblCostUSD NUMERIC(18, 6)
	,strUnitMeasure nvarchar(200)
	,intContractDetailId int
	,ysnPosted Bit
	)

INSERT INTO @PhysicalFuturesResult (
	intRowNum
	,strContractType
	,strNumber
	,strDescription
	,strConfirmed
	,dblAllocatedQty
	,dblPrice
	,strCurrency
	,dblFX
	,dblBooked
	,dblAccounting
	,dtmDate
	,strType
	,dblTranValue
	,intSort
	,ysnPosted
	,dblTransactionValue
	,dblForecast
	,intContractDetailId
	)
EXEC uspRKPNLPhysicalFuturesResult @intSContractDetailId,@intCurrencyId, @intUnitMeasureId	,@intWeightUOMId

SELECT 1 as intRowNum,
(select sum(dblForecast) from @PhysicalFuturesResult where strDescription='Allocated') dblForecastGross,
(select sum(dblForecast) from @PhysicalFuturesResult where strDescription<>'Allocated') dblForecastCost,
(select sum(dblForecast) from @PhysicalFuturesResult) dblForecastTotalResult,
(select sum(dblAccounting) from @PhysicalFuturesResult where strDescription in('Invoice','Supp. Invoice')) dblAccountingGross,
(select sum(dblAccounting) from @PhysicalFuturesResult where strDescription not in('Invoice','Supp. Invoice')) dblAccountingCost,
(select sum(dblAccounting) from @PhysicalFuturesResult) dblAccountingTotalResult
,@intSContractDetailId as intContractDetailId