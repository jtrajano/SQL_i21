CREATE PROCEDURE uspRKPnLBySalesContract
		@intCurrencyId int ,			
		@intUnitMeasureId		INT,--- Price uom	
		@intWeightUOMId			INT -- weight 
AS

DECLARE @ysnPnLWithOutAllocation bit
DECLARE @strAllocationType nvarchar(100)
SELECT TOP 1 @ysnPnLWithOutAllocation =ysnPnLWithOutAllocation from tblRKCompanyPreference 
if isnull(@ysnPnLWithOutAllocation,0)=0
SET @strAllocationType='With Allocation'
ELSE
SET @strAllocationType = 'Without Allocation'
	
DECLARE @Result TABLE (intContractDetailId int,dblInvoiceQty numeric(24,10))
INSERT INTO @Result(dblInvoiceQty,intContractDetailId)
SELECT	DISTINCT 
			SUM(dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intUnitMeasureId, ID.dblQtyShipped)) AS dblInvoiceQty
			,ID.intContractDetailId
	FROM	tblARInvoiceDetail		ID 
	JOIN	tblICItemUOM			QU	ON	QU.intItemUOMId			=	ID.intItemUOMId	
	WHERE ID.intContractDetailId IS NOT NULL
	GROUP BY ID.intContractDetailId


SELECT  CONVERT(INT,ROW_NUMBER() OVER (ORDER BY strSequenceNumber)) AS intRow,strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,sum(dblAllocatedQty) dblAllocatedQty,dblActualProfit
,ISNULL(sum(dblAllocatedQty),0) - isnull(sum(dblInvoiceQty),0) dblBalanceToInvoice,intContractDetailId,sum(dblInvoiceQty) dblInvoiceQty,
0.0 as dblEstimatedProfit,strSalespersonName into #temp
FROM(
SELECT Distinct strSequenceNumber,strItemNo,
		strEntityName,dblDetailQuantity,--isnull(dblAllocatedQty,0)*(isnull(dblSaleBasis,0)-isnull(dblPurchaseBasis,0)-(isnull(dblPurchaseCost,0)- isnull(dblSaleCost,0))) as dblEstimatedProfit,
		0.0 as dblActualProfit, 
		sum(dbo.fnCTConvertQuantityToTargetItemUOM(intItemId,intUnitMeasureId,@intUnitMeasureId, ISNULL(dblAllocatedQty,0))) over (Partition by intContractDetailId)  dblAllocatedQty,
		dblInvoiceQty  as dblInvoiceQty,		
		intContractDetailId,strSalespersonName
FROM(
	SELECT strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,dblPurchaseBasis,dblSaleBasis,dblAllocatedQty,						
		   dblPurchaseCost,dblSaleCost,0.0 as dblActualProfit,d.intContractDetailId,intPContractDetailId, d.intItemId,u.intUnitMeasureId,
		   r.dblInvoiceQty dblInvoiceQty,strSalespersonName
	FROM vyuRKPnLGetAllocationDetail d 
	JOIN tblICItemUOM u on u.intItemUOMId=d.intPItemUOMId
	LEFT JOIN @Result r on d.intContractDetailId=r.intContractDetailId
	WHERE strAllocationType=@strAllocationType  and intContractTypeId=2
) t
 )t1 GROUP BY strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,intContractDetailId,dblActualProfit,strSalespersonName


 DECLARE @PhysicalFuturesResult TABLE (
	intRowNum INT
	,strContractType NVARCHAR(50)
	,strNumber NVARCHAR(50)
	,strDescription NVARCHAR(50)
	,strConfirmed NVARCHAR(50)
	,dblAllocatedQty NUMERIC(24, 10)
	,dblPrice NUMERIC(24, 10)
	,strCurrency NVARCHAR(50)
	,dblFX NUMERIC(24, 10)
	,dblBooked NUMERIC(24, 10)
	,dblAccounting NUMERIC(24, 10)
	,dtmDate DATETIME
	,strType Nvarchar(100)
	,dblTranValue NUMERIC(24, 10)
	,intSort INT
	,dblTransactionValue NUMERIC(24, 10)
	,dblForecast NUMERIC(24, 10)
	,dblBasisUSD NUMERIC(24, 10)
	,dblCostUSD NUMERIC(24, 10)
	,strUnitMeasure nvarchar(200)
	,intContractDetailId int
	,ysnPosted Bit
	)
		
	 DECLARE @Detail AS TABLE 
	 (
		intId int IDENTITY(1,1) PRIMARY KEY , 
		intContractDetailId  INT
	 )
INSERT INTO @Detail
SELECT intContractDetailId FROM #temp 


DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)
declare @intCommodityUnitMeasureId int

SELECT @mRowNumber = MIN(intId) FROM @Detail

WHILE @mRowNumber > 0
	BEGIN
	 DECLARE @intContractDetailId INT = NULL
	 SELECT @intContractDetailId =intContractDetailId FROM @Detail WHERE intId=@mRowNumber

	 INSERT INTO @PhysicalFuturesResult (
			intRowNum,strContractType,strNumber,strDescription,strConfirmed,dblAllocatedQty,dblPrice,strCurrency,dblFX
			,dblBooked,dblAccounting,dtmDate,strType,dblTranValue,intSort,ysnPosted,dblTransactionValue,dblForecast,intContractDetailId)
EXEC uspRKPNLPhysicalFuturesResult @intContractDetailId,@intCurrencyId, @intUnitMeasureId	,@intWeightUOMId 
	
	SELECT @mRowNumber = MIN(intId)	FROM @Detail	WHERE intId > @mRowNumber
END  

SELECT intRow,strSequenceNumber,strItemNo,strEntityName,dblDetailQuantity,
dblAllocatedQty,dblBalanceToInvoice,intContractDetailId,dblInvoiceQty,
isnull((select sum(dblAccounting) from @PhysicalFuturesResult a where a.intContractDetailId=t.intContractDetailId),0.0) dblActualProfit,
isnull((select sum(dblForecast) from @PhysicalFuturesResult a where a.intContractDetailId=t.intContractDetailId),0.0) dblEstimatedProfit, 
strSalespersonName FROM #temp t