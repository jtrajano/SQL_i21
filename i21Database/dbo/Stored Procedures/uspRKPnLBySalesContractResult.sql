CREATE PROCEDURE uspRKPnLBySalesContractResult
		@intUOMId int = null,
		@intPriceUOMId int = null,
		@intContractDetailId int = null
AS

--DECLARE @intContractDetailId INT = 2690

DECLARE @Result TABLE
(
  intResultId int IDENTITY(1,1) PRIMARY KEY,
  intContractHeaderId INT,
  intContractDetailId INT,
  strContractNumber NVARCHAR(50),
  strContractType NVARCHAR(50),
  dblQty NUMERIC(18, 6),
  dblUSD NUMERIC(18, 6),
  dblBasis NUMERIC(18, 6),
  dblAllocatedQty NUMERIC(18, 6),
  intContractTypeId int,
  dblInvoicePrice NUMERIC(18, 6)
)

DECLARE @PhysicalFuturesResult TABLE
(
	intRowNum INT,
	strContractType NVARCHAR(50),
	strNumber NVARCHAR(50),
	strDescription NVARCHAR(50),
	strConfirmed NVARCHAR(50),
	dblAllocatedQty NUMERIC(18, 6),
	dblPrice NUMERIC(18, 6),
	strCurrency NVARCHAR(50),
	dblFX NUMERIC(18, 6),
	dblBooked NUMERIC(18, 6),
	dblAccounting NUMERIC(18, 6),
	dtmDate datetime,
	dblTransactionValue NUMERIC(18, 6),
	dblForecast NUMERIC(18, 6)
)

INSERT INTO @PhysicalFuturesResult (intRowNum,strContractType,strNumber,strDescription,strConfirmed,dblAllocatedQty,dblPrice,strCurrency,dblFX,dblBooked,dblAccounting,dtmDate,dblTransactionValue,dblForecast)
EXEC uspRKPNLPhysicalFuturesResult @intContractDetailId,16--- Hard code

DECLARE @dblAllocatedQty  NUMERIC(18, 6)

SELECT @dblAllocatedQty=sum(isnull(sa.dblAllocatedQty,0))
FROM vyuRKPnLGetAllocationDetail sa
WHERE sa.intContractTypeId=2 and sa.intContractDetailId=@intContractDetailId


INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblQty,dblUSD,dblBasis,dblAllocatedQty,dblInvoicePrice)
SELECT distinct intContractHeaderId, intContractDetailId,strSequenceNumber,'Invoices',
(SELECT ISNULL(SUM(dblBooked),0) FROM @PhysicalFuturesResult WHERE strDescription='Invoice') dblQty,
sum(dblSaleBasis)/count(dblSaleBasis),@dblAllocatedQty dblAllocatedQty, null,
(SELECT ISNULL(SUM(dblPrice),0) FROM @PhysicalFuturesResult WHERE strDescription='Invoice')/(SELECT case when count(isnull(dblPrice,0))=0 then 1 else count(dblPrice) end  FROM @PhysicalFuturesResult WHERE strDescription='Invoice')
FROM vyuRKPnLGetAllocationDetail 
WHERE intContractTypeId=2 and intContractDetailId=@intContractDetailId
group by intContractHeaderId, intContractDetailId,strSequenceNumber

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblQty,dblUSD,dblBasis,dblAllocatedQty)
SELECT distinct intContractHeaderId, intContractDetailId,strSequenceNumber,'Purchase',null,null,sum(dblPurchaseBasis)/count(dblPurchaseBasis),@dblAllocatedQty dblAllocatedQty
FROM vyuRKPnLGetAllocationDetail 
WHERE intContractTypeId=2 and intContractDetailId=@intContractDetailId
GROUP BY intContractHeaderId, intContractDetailId,strSequenceNumber

DECLARE @dblSaleBasis NUMERIC(18,6)
DECLARE @dblPurchaseBasis NUMERIC(18,6)
SELECT @dblSaleBasis=sum(dblBasis) FROM @Result where strContractType='Invoices'
SELECT @dblPurchaseBasis=sum(dblBasis) FROM @Result where strContractType='Purchase'


--RESULT
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty,intContractTypeId)
SELECT DISTINCT NULL,NULL,NULL,'Gross Profit - USD',(@dblSaleBasis-@dblPurchaseBasis)*@dblAllocatedQty ,null,intContractTypeId	
FROM @Result

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty,intContractTypeId)
SELECT DISTINCT NULL,NULL,NULL,'Gross Profit - Rate',(@dblSaleBasis-@dblPurchaseBasis),null,intContractTypeId	FROM @Result 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT distinct  NULL,NULL,NULL,'PO Costs', sum(isnull(dblRate,0)),NULL
FROM vyuRKPnLGetAllocationDetail dv
JOIN vyuCTContractCostView cv on cv.intContractDetailId=dv.intPContractDetailId
WHERE intContractTypeId=2 and dv.intContractDetailId=2690

UNION

SELECT DISTINCT  NULL,NULL,NULL,'SO Costs',
(SELECT dblCosts from
(SELECT sum(isnull(dc.dblRate,0)) dblCosts
        FROM vyuCTContractCostView dc 
        WHERE  dc.intContractDetailId=dv.intContractDetailId)t) dblCosts,NULL
FROM vyuRKPnLGetAllocationDetail dv
WHERE intContractTypeId=2 and intContractDetailId=@intContractDetailId

----Rate
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Total Costs USD',sum(dblBasis)*@dblAllocatedQty,null	
FROM @Result WHERE strContractType in('PO Costs','SO Costs') 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Total Costs - Rate',sum(dblBasis),null	
FROM @Result WHERE strContractType in('PO Costs','SO Costs') 

---- Profit
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Physical Profit - USD',(dblBasis-ISNULL((SELECT SUM(dblBasis) FROM @Result WHERE strContractType='Total Costs USD' ) ,0)),NULL	
FROM @Result WHERE strContractType='Gross Profit - USD' 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Physical Profit - Rate',(dblBasis-ISNULL((SELECT SUM(dblBasis) FROM @Result WHERE strContractType='Total Costs - Rate' ) ,0)),NULL	
FROM @Result WHERE strContractType='Gross Profit - Rate' 

---- Net

---- Profit
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Net SO Profit - USD',isnull(dblBasis,0),NULL from @Result WHERE strContractType='Physical Profit - USD' 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Net SO Profit - Rate',isnull(dblBasis,0),null from @Result WHERE strContractType='Physical Profit - Rate' 

SELECT * FROM @Result ORDER BY intResultId