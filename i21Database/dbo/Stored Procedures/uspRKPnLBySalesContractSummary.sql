CREATE PROCEDURE uspRKPnLBySalesContractSummary
		@intContractDetailId int = null,
		@intUnitMeasureId int = null
AS

DECLARE @PhysicalFuturesResult TABLE (
	intRowNum INT
	,strContractType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strConfirmed NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblAllocatedQty NUMERIC(18, 6)
	,dblPrice NUMERIC(18, 6)
	,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblFX NUMERIC(18, 6)
	,dblBooked NUMERIC(18, 6)
	,dblAccounting NUMERIC(18, 6)
	,dtmDate DATETIME
	,strType Nvarchar(100) COLLATE Latin1_General_CI_AS
	,dblTranValue NUMERIC(18, 6)
	,intSort INT
	,dblTransactionValue NUMERIC(18, 6)
	,dblForecast NUMERIC(18, 6)
	,dblBasisUSD NUMERIC(18, 6)
	,dblCostUSD NUMERIC(18, 6)
	,strUnitMeasure nvarchar(200) COLLATE Latin1_General_CI_AS
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
	,dblTransactionValue
	,dblForecast
	,intContractDetailId,
	ysnPosted
	)
EXEC uspRKPNLPhysicalFuturesResult @intContractDetailId, @intUnitMeasureId

SELECT 1 as intRowNum,
(select sum(dblForecast) from @PhysicalFuturesResult where strDescription='Allocated') dblForecastGross,
(select sum(dblForecast) from @PhysicalFuturesResult where strDescription<>'Allocated') dblForecastCost,
(select sum(dblForecast) from @PhysicalFuturesResult) dblForecastTotalResult,
(select sum(dblAccounting) from @PhysicalFuturesResult where strDescription in('Invoice','Supp. Invoice')) dblAccountingGross,
(select sum(dblAccounting) from @PhysicalFuturesResult where strDescription not in('Invoice','Supp. Invoice')) dblAccountingCost,
(select sum(dblAccounting) from @PhysicalFuturesResult) dblAccountingTotalResult
,@intContractDetailId as intContractDetailId