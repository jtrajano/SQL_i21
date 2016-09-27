CREATE PROCEDURE uspRKPnLBySalesContractResult
		@intUOMId int = null,
		@intPriceUOMId int = null,
		@intContractDetailId int = null
AS

--DECLARE @intContractDetailId INT = 298

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
  dblAllocatedQty NUMERIC(18, 6)
)

DECLARE @dblAllocatedQty  NUMERIC(18, 6)

SELECT @dblAllocatedQty=sum(isnull(sa.dblAllocatedQty,0))
FROM vyuCTContStsAllocation sa
JOIN tblLGAllocationDetail ad on ad.intPContractDetailId=sa.intContractDetailId
JOIN vyuCTContractDetailView dv on dv.intContractDetailId=ad.intPContractDetailId 
WHERE sa.strContractType='Sale' and sa.intContractDetailId=@intContractDetailId
GROUP BY dv.intContractHeaderId, dv.intContractDetailId,dv.strContractNumber,dv.strContractType

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblQty,dblUSD,dblBasis,dblAllocatedQty)
SELECT  dv.intContractHeaderId, dv.intContractDetailId,dv.strContractNumber,dv.strContractType,null,null,sum(dv.dblBasis),@dblAllocatedQty dblAllocatedQty
FROM vyuCTContStsAllocation sa
JOIN tblLGAllocationDetail ad on ad.intPContractDetailId=sa.intContractDetailId
JOIN vyuCTContractDetailView dv on dv.intContractDetailId=ad.intSContractDetailId 
WHERE  sa.strContractType='Sale'  and sa.intContractDetailId=@intContractDetailId
GROUP BY dv.intContractHeaderId, dv.intContractDetailId,dv.strContractNumber,dv.strContractType

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblQty,dblUSD,dblBasis,dblAllocatedQty)
SELECT  dv.intContractHeaderId, dv.intContractDetailId,dv.strContractNumber,dv.strContractType,@dblAllocatedQty,@dblAllocatedQty*dv.dblCashPrice ,sum(dv.dblBasis),@dblAllocatedQty dblAllocatedQty
FROM vyuCTContStsAllocation sa
JOIN tblLGAllocationDetail ad on ad.intPContractDetailId=sa.intContractDetailId
JOIN vyuCTContractDetailView dv on dv.intContractDetailId=ad.intPContractDetailId 
WHERE  sa.strContractType='Sale' and sa.intContractDetailId=@intContractDetailId
GROUP BY dv.intContractHeaderId, dv.intContractDetailId,dv.strContractNumber,dv.strContractType,dv.dblCashPrice

--RESULT
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Gross Profit - USD',(dblBasis-ISNULL((SELECT SUM(dblBasis) FROM @Result WHERE strContractType='Purchase' ) ,0))*@dblAllocatedQty,null	
FROM @Result WHERE strContractType='Sale' 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Gross Profit - Rate',(dblBasis-ISNULL((SELECT SUM(dblBasis) FROM @Result WHERE strContractType='Purchase' ) ,0)),null	
FROM @Result WHERE strContractType='Sale' 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)

SELECT  NULL,NULL,NULL,'SO Costs',
(SELECT dblCosts from
(SELECT sum(isnull(dc.dblRate,0)) dblCosts
        FROM vyuCTContractCostView dc 
        LEFT JOIN tblICCommodityUnitMeasure cu1 on dv.intCommodityId=cu1.intCommodityId and cu1.intUnitMeasureId=dc.intUnitMeasureId
        LEFT JOIN tblICCommodityUnitMeasure cu on dv.intCommodityId=cu.intCommodityId and cu.intUnitMeasureId=1
        WHERE  dc.intContractDetailId=dv.intContractDetailId
        GROUP BY cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId)t) dblCosts,NULL
FROM vyuCTContStsAllocation sa
JOIN tblLGAllocationDetail ad on ad.intPContractDetailId=sa.intContractDetailId
JOIN vyuCTContractDetailView dv on dv.intContractDetailId=ad.intPContractDetailId 
WHERE  sa.strContractType='Sale' and sa.intContractDetailId=@intContractDetailId
UNION
SELECT  null,null,null,'PO Costs',
(SELECT dblCosts from
(SELECT sum(isnull(dc.dblRate,0)) dblCosts
        FROM vyuCTContractCostView dc 
        LEFT JOIN tblICCommodityUnitMeasure cu1 on dv.intCommodityId=cu1.intCommodityId and cu1.intUnitMeasureId=dc.intUnitMeasureId
        LEFT JOIN tblICCommodityUnitMeasure cu on dv.intCommodityId=cu.intCommodityId and cu.intUnitMeasureId=1
        WHERE  dc.intContractDetailId=dv.intContractDetailId
        group by cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId)t) dblCosts,null
FROM vyuCTContStsAllocation sa
JOIN tblLGAllocationDetail ad on ad.intPContractDetailId=sa.intContractDetailId
JOIN vyuCTContractDetailView dv on dv.intContractDetailId=ad.intSContractDetailId 
WHERE  sa.strContractType='Sale'  and sa.intContractDetailId=@intContractDetailId

--Rate
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Total Costs USD',sum(dblBasis)*@dblAllocatedQty,null	
FROM @Result WHERE strContractType in('PO Costs','SO Costs') 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Total Costs - Rate',sum(dblBasis),null	
FROM @Result WHERE strContractType in('PO Costs','SO Costs') 

-- Profit
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Physical Profit - USD',(dblBasis-ISNULL((SELECT SUM(dblBasis) FROM @Result WHERE strContractType='Total Costs USD' ) ,0)),NULL	
FROM @Result WHERE strContractType='Gross Profit - USD' 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Physical Profit - Rate',(dblBasis-ISNULL((SELECT SUM(dblBasis) FROM @Result WHERE strContractType='Total Costs - Rate' ) ,0)),NULL	
FROM @Result WHERE strContractType='Gross Profit - Rate' 

-- Net

-- Profit
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Net SO Profit - USD',isnull(dblBasis,0),NULL from @Result WHERE strContractType='Physical Profit - USD' 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Net SO Profit - Rate',isnull(dblBasis,0),null from @Result WHERE strContractType='Physical Profit - Rate' 

SELECT * FROM @Result ORDER BY intResultId