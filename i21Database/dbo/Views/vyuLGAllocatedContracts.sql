CREATE VIEW vyuLGAllocatedContracts
AS
SELECT
	ALD.intAllocationDetailId
	,ALD.intAllocationHeaderId

-- Allocation Header details
	,ALH.[strAllocationNumber]
	,ALH.intCommodityId
	,Comm.strDescription as strCommodity
	,ALH.intCompanyLocationId
	,CompLoc.strLocationName
	,ALH.intWeightUnitMeasureId
	,WTUOM.strUnitMeasure
	,ALH.strComments as strHeaderComments

-- Allocation Details
	,ALD.dtmAllocatedDate
	,ALD.intUserSecurityId
	,UserId.strUserName
	,ALD.strComments

-- Purchase Contract Details
	,ALD.intPContractDetailId
	,ALD.dblPAllocatedQty
	,ALD.intPUnitMeasureId
	,PCT.strContractNumber as strPurchaseContractNumber
	,PCT.intContractSeq as intPContractSeq
	,strPContractNumber = Cast(PCT.strContractNumber as VarChar(100)) + '/' + Cast(PCT.intContractSeq as VarChar(100))
	,PCT.intItemId as intPItemId
	,PCT.strItemUOM as strPItemUOM
	,PCT.strItemNo as strPItemNo
	,PCT.strItemDescription as strPItemDescription
	,PCT.dblDetailQuantity as dblPDetailQuantity
	,PCT.dtmContractDate as dtmPContractDate
	,PCT.dblBalance as dblPBalance
	,PCT.dblBasis as dblPBasis
	,PCT.dblCashPrice as dblPCashPrice
	,PCT.dblFutures as dblPFutures
	,PCT.dtmStartDate as dtmPStartDate
	,PCT.dtmEndDate as dtmPEndDate
	,PCT.strContractBasis as strPContractBasis
	,PCT.strContractStatus as strPContractStatus
	,PCT.strEntityName as strSeller
	,PCT.strFixationBy as strPFixationBy
	,PCT.strFutMarketName as strPFutMarketName
	,PCT.strFutureMonth as strPFutureMonth
	,PCT.strPosition as strPPosition
	,PCT.strPriceUOM as strPPriceUOM
	,PCT.strPricingType as strPPricingType
	,PCT.strOriginDest as strPOriginDest
	,PCT.dblNoOfLots as dblPNoOfLots

-- Sales Contract Details
	,ALD.intSContractDetailId
	,ALD.dblSAllocatedQty
	,ALD.intSUnitMeasureId
	,SCT.strContractNumber as strSalesContractNumber
	,SCT.intContractSeq as intSContractSeq
	,strSContractNumber = Cast(SCT.strContractNumber as VarChar(100)) + '/' + Cast(SCT.intContractSeq as VarChar(100))
	,SCT.intItemId as intSItemId
	,SCT.strItemUOM as strSItemUOM
	,SCT.strItemNo as strSItemNo
	,SCT.strItemDescription as strSItemDescription
	,SCT.dblDetailQuantity as dblSDetailQuantity
	,SCT.dtmContractDate as dtmSContractDate
	,SCT.dblBalance as dblSBalance
	,SCT.dblBasis as dblSBasis
	,SCT.dblCashPrice as dblSCashPrice
	,SCT.dblFutures as dblSFutures
	,SCT.dtmStartDate as dtmSStartDate
	,SCT.dtmEndDate as dtmSEndDate
	,SCT.strContractBasis as strSContractBasis
	,SCT.strContractStatus as strSContractStatus
	,SCT.strEntityName as strBuyer
	,SCT.strFixationBy as strSFixationBy
	,SCT.strFutMarketName as strSFutMarketName
	,SCT.strFutureMonth as strSFutureMonth
	,SCT.strPosition as strSPosition
	,SCT.strPriceUOM as strSPriceUOM
	,SCT.strPricingType as strSPricingType
	,SCT.strOriginDest as strSOriginDest
	,SCT.dblNoOfLots as dblSNoOfLots
	,ysnDelivered = CONVERT(BIT,(CASE WHEN SCT.dblBalance <= 0 THEN 1 ELSE 0 END))

FROM tblLGAllocationDetail ALD
JOIN tblLGAllocationHeader ALH ON ALH.intAllocationHeaderId = ALD.intAllocationHeaderId
LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = ALH.intCommodityId
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = ALH.intCompanyLocationId
LEFT JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = ALH.intWeightUnitMeasureId
LEFT JOIN tblSMUserSecurity UserId ON UserId.[intEntityUserSecurityId] = ALD.intUserSecurityId
LEFT JOIN vyuCTContractDetailView PCT ON PCT.intContractDetailId = ALD.intPContractDetailId
LEFT JOIN vyuCTContractDetailView SCT ON SCT.intContractDetailId = ALD.intSContractDetailId
