CREATE VIEW vyuLGAllocatedContracts
AS
SELECT
	 ALD.intAllocationDetailId
	,ALD.intAllocationHeaderId

	-- Allocation Header details
	,ALH.[strAllocationNumber]
	,ALH.intCommodityId
	,Comm.strDescription AS strCommodity
	,ALH.intCompanyLocationId
	,CompLoc.strLocationName
	,ALH.intWeightUnitMeasureId
	,WTUOM.strUnitMeasure
	,ALH.strComments AS strHeaderComments
	
	-- Allocation Details
	,ALD.dtmAllocatedDate
	,ALD.intUserSecurityId
	,UserId.strUserName
	,ALD.strComments
	
	-- Purchase Contract Details
	,ALD.intPContractDetailId
	,ALD.dblPAllocatedQty
	,ALD.intPUnitMeasureId
	,PCH.strContractNumber AS strPurchaseContractNumber
	,PCT.intContractSeq AS intPContractSeq
	,strPContractNumber = Cast(PCH.strContractNumber AS VARCHAR(100)) + '/' + Cast(PCT.intContractSeq AS VARCHAR(100))
	,PCT.intItemId AS intPItemId
	,U1.strUnitMeasure AS strPItemUOM
	,IM.strItemNo AS strPItemNo
	,IM.strDescription AS strPItemDescription
	,PCT.dblQuantity AS dblPDetailQuantity
	,PCH.dtmContractDate AS dtmPContractDate
	,PCT.dblBalance AS dblPBalance
	,PCT.dblBasis AS dblPBasis
	,PCT.dblCashPrice AS dblPCashPrice
	,PCT.dblFutures AS dblPFutures
	,PCT.dtmStartDate AS dtmPStartDate
	,PCT.dtmEndDate AS dtmPEndDate
	,PCB.strContractBasis AS strPContractBasis
	,PCS.strContractStatus AS strPContractStatus
	,PEY.strEntityName AS strSeller
	,PCT.strFixationBy AS strPFixationBy
	,PFM.strFutMarketName AS strPFutMarketName
	,PMO.strFutureMonth AS strPFutureMonth
	,PPO.strPosition AS strPPosition
	,U2.strUnitMeasure AS strPPriceUOM
	,PPT.strPricingType AS strPPricingType
	,PFR.strOrigin + ' - ' + PFR.strDest AS strPOriginDest
	,PCT.dblNoOfLots AS dblPNoOfLots
	
	---- Sales Contract Details
	,ALD.intSContractDetailId
	,ALD.dblSAllocatedQty
	,ALD.intSUnitMeasureId
	,SCH.strContractNumber as strSalesContractNumber
	,SCT.intContractSeq as intSContractSeq
	,strSContractNumber = Cast(SCH.strContractNumber as VarChar(100)) + '/' + Cast(SCT.intContractSeq as VarChar(100))
	,SCT.intItemId as intSItemId
	,U3.strUnitMeasure as strSItemUOM
	,SIM.strItemNo as strSItemNo
	,SIM.strDescription as strSItemDescription
	,SCT.dblQuantity as dblSDetailQuantity
	,SCH.dtmContractDate as dtmSContractDate
	,SCT.dblBalance as dblSBalance
	,SCT.dblBasis as dblSBasis
	,SCT.dblCashPrice as dblSCashPrice
	,SCT.dblFutures as dblSFutures
	,SCT.dtmStartDate as dtmSStartDate
	,SCT.dtmEndDate as dtmSEndDate
	,SCB.strContractBasis as strSContractBasis
	,SCS.strContractStatus as strSContractStatus
	,SEY.strEntityName as strBuyer
	,SCT.strFixationBy as strSFixationBy
	,SFM.strFutMarketName as strSFutMarketName
	,SMO.strFutureMonth as strSFutureMonth
	,SPO.strPosition as strSPosition
	,U2.strUnitMeasure as strSPriceUOM
	,SPT.strPricingType as strSPricingType
	,SFR.strOrigin+' - '+SFR.strDest as strSOriginDest
	,SCT.dblNoOfLots as dblSNoOfLots
	,ysnDelivered = CONVERT(BIT, CASE 
								 WHEN SCT.dblBalance <= 0
									THEN 1
								 ELSE CASE 
										WHEN (
												ALD.dblSAllocatedQty > ISNULL((
														SELECT SUM(LD.dblQuantity)
														FROM tblLGLoadDetail LD
														WHERE LD.intAllocationDetailId = ALD.intAllocationDetailId
														), 0)
												)
											THEN 0
										ELSE 1
										END
								 END)
FROM tblLGAllocationDetail ALD
JOIN tblLGAllocationHeader ALH ON ALH.intAllocationHeaderId = ALD.intAllocationHeaderId
LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = ALH.intCommodityId
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = ALH.intCompanyLocationId
LEFT JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = ALH.intWeightUnitMeasureId
LEFT JOIN tblSMUserSecurity UserId ON UserId.[intEntityId] = ALD.intUserSecurityId
LEFT JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = ALD.intPContractDetailId
LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCT.intContractHeaderId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = PCT.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItem IM ON IM.intItemId = PCT.intItemId
LEFT JOIN tblCTContractBasis PCB ON PCB.intContractBasisId = PCH.intContractBasisId
LEFT JOIN tblCTContractStatus PCS ON PCS.intContractStatusId = PCT.intContractStatusId
LEFT JOIN vyuCTEntity PEY ON PEY.intEntityId = PCH.intEntityId AND PEY.strEntityType = 'Vendor'
LEFT JOIN tblRKFutureMarket PFM ON PFM.intFutureMarketId = PCT.intFutureMarketId
LEFT JOIN tblRKFuturesMonth PMO ON PMO.intFutureMonthId = PCT.intFutureMonthId
LEFT JOIN tblCTPosition PPO ON PPO.intPositionId = PCH.intPositionId
LEFT JOIN tblICItemUOM PPU ON PPU.intItemUOMId = PCT.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PPU.intUnitMeasureId
LEFT JOIN tblCTPricingType PPT ON PPT.intPricingTypeId = PCT.intPricingTypeId
LEFT JOIN tblCTFreightRate PFR ON PFR.intFreightRateId = PCT.intFreightRateId
LEFT JOIN tblCTContractDetail SCT ON SCT.intContractDetailId = ALD.intSContractDetailId
LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCT.intContractHeaderId
LEFT JOIN tblICItemUOM SIU ON SIU.intItemUOMId = SCT.intItemUOMId
LEFT JOIN tblICUnitMeasure U3 ON U3.intUnitMeasureId = SIU.intUnitMeasureId
LEFT JOIN tblICItem SIM ON SIM.intItemId = SCT.intItemId
LEFT JOIN tblCTContractBasis SCB ON SCB.intContractBasisId = SCH.intContractBasisId
LEFT JOIN tblCTContractStatus SCS ON SCS.intContractStatusId = SCT.intContractStatusId
LEFT JOIN vyuCTEntity SEY ON SEY.intEntityId = SCH.intEntityId AND SEY.strEntityType = 'Customer'
LEFT JOIN tblRKFutureMarket SFM ON SFM.intFutureMarketId = SCT.intFutureMarketId
LEFT JOIN tblRKFuturesMonth SMO ON SMO.intFutureMonthId = SCT.intFutureMonthId
LEFT JOIN tblCTPosition SPO ON SPO.intPositionId = SCH.intPositionId
LEFT JOIN tblICItemUOM SPU ON SPU.intItemUOMId = SCT.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure U4 ON U4.intUnitMeasureId = SPU.intUnitMeasureId
LEFT JOIN tblCTPricingType SPT ON SPT.intPricingTypeId = SCT.intPricingTypeId
LEFT JOIN tblCTFreightRate SFR ON SFR.intFreightRateId = SCT.intFreightRateId
