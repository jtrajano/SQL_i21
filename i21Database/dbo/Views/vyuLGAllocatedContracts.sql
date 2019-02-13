CREATE VIEW vyuLGAllocatedContracts
AS
SELECT
	 ALD.intAllocationDetailId
	,ALD.intAllocationHeaderId

	-- Allocation Header details
	,ALH.[strAllocationNumber]
	,ALD.strAllocationDetailRefNo
	,ALH.intCommodityId
	,strCommodity = Comm.strDescription
	,ALH.intCompanyLocationId
	,CompLoc.strLocationName
	,ALH.intWeightUnitMeasureId
	,WTUOM.strUnitMeasure
	,strHeaderComments = ALH.strComments
	,ALH.intBookId
	,BO.strBook
	,ALH.intSubBookId
	,SB.strSubBook
	
	-- Allocation Details
	,ALD.dtmAllocatedDate
	,ALD.intUserSecurityId
	,UserId.strUserName
	,ALD.strComments
	
	-- Purchase Contract Details
	,intPContractDetailId = ALD.intPContractDetailId
	,dblPAllocatedQty = ALD.dblPAllocatedQty
	,dblPContractAllocatedQty = PCT.dblAllocatedQty
	,intPUnitMeasureId = ALD.intPUnitMeasureId
	,strPurchaseContractNumber = PCH.strContractNumber
	,intPContractSeq = PCT.intContractSeq
	,strPContractNumber = Cast(PCH.strContractNumber AS VARCHAR(100)) + '/' + Cast(PCT.intContractSeq AS VARCHAR(100))
	,intPItemId = PCT.intItemId
	,strPItemUOM = U1.strUnitMeasure
	,strPItemNo = IM.strItemNo
	,strPItemDescription = IM.strDescription 
	,strPItemOrigin = PCA.strDescription
	,strPProductType = PTP.strDescription
	,dblPDetailQuantity = PCT.dblQuantity
	,dtmPContractDate = PCH.dtmContractDate
	,dblPBalance = PCT.dblBalance
	,dblPBasis = PCT.dblBasis
	,dblPCashPrice = PCT.dblCashPrice
	,strPPriceBasis = CAST(PBC.strCurrency as VARCHAR(100)) + '/' + CAST(PBUOM.strUnitMeasure as VARCHAR(100))
	,dblPFutures = PCT.dblFutures
	,dblPTotal = PCT.dblTotalCost
	,dtmPStartDate = PCT.dtmStartDate
	,dtmPEndDate = PCT.dtmEndDate
	,strPContractBasis = PCB.strContractBasis
	,strPContractStatus = PCS.strContractStatus
    ,strSeller = PEY.strName
	,strPFixationBy = PCT.strFixationBy
	,strPFutMarketName = PFM.strFutMarketName
	,strPFutureMonth = PMO.strFutureMonth
	,dblPLatestClosingPrice = dbo.fnRKGetLatestClosingPrice(PCT.intFutureMarketId, PCT.intFutureMonthId, GETDATE())
	,strPPosition = PPO.strPosition
	,strPPriceUOM = U2.strUnitMeasure
	,strPPricingType = PPT.strPricingType
	,strPOriginDest = PFR.strOrigin + ' - ' + PFR.strDest
	,strPOrigin = PCO.strCountry
	,dblPNoOfLots = PCT.dblNoOfLots
	
	---- Sales Contract Details
	,intSContractDetailId = ALD.intSContractDetailId
	,dblSAllocatedQty = ALD.dblSAllocatedQty
	,dblSContractAllocatedQty = SCT.dblAllocatedQty
	,intSUnitMeasureId = ALD.intSUnitMeasureId
	,strSalesContractNumber = SCH.strContractNumber
	,intSContractSeq = SCT.intContractSeq
	,strSContractNumber = Cast(SCH.strContractNumber as VarChar(100)) + '/' + Cast(SCT.intContractSeq as VarChar(100))
	,strSCustomerRefNo = SCH.strCustomerContract
	,intSItemId = SCT.intItemId
	,strSItemUOM = U3.strUnitMeasure
	,strSItemNo = SIM.strItemNo
	,strSItemDescription = SIM.strDescription
	,strSItemDescriptionSpecification = SIM.strDescription + ' - ' + ISNULL(SCT.strItemSpecification,'')
	,strSItemOrigin = SCA.strDescription
	,strSProductType = PTS.strDescription
	,dblSDetailQuantity = SCT.dblQuantity
	,dtmSContractDate = SCH.dtmContractDate
	,dblSBalance = SCT.dblBalance
	,dblSBasis = SCT.dblBasis
	,dblSCashPrice = SCT.dblCashPrice
	,strSPriceBasis = CAST(SBC.strCurrency as VARCHAR(100)) + '/' + CAST(SBUOM.strUnitMeasure as VARCHAR(100))
	,dblSFutures = SCT.dblFutures
	,dblSTotal = SCT.dblTotalCost
	,dtmSStartDate = SCT.dtmStartDate
	,dtmSEndDate = SCT.dtmEndDate
	,strSContractBasis = SCB.strContractBasis
	,strSContractStatus = SCS.strContractStatus
	,strBuyer = SEY.strName
	,strSFixationBy = SCT.strFixationBy
	,strSFutMarketName = SFM.strFutMarketName
	,strSFutureMonth = SMO.strFutureMonth
	,dblSLatestClosingPrice = dbo.fnRKGetLatestClosingPrice(SCT.intFutureMarketId, SCT.intFutureMonthId, GETDATE())
	,strSPosition = SPO.strPosition
	,strSPriceUOM = U2.strUnitMeasure
	,strSPricingType = SPT.strPricingType
	,strSOriginDest = SFR.strOrigin+' - '+SFR.strDest
	,strSOrigin = SCO.strCountry
	,dblSNoOfLots = SCT.dblNoOfLots
	,ysnDelivered = CONVERT(BIT, CASE WHEN (ALD.dblSAllocatedQty > ISNULL(LS.dblQuantity, 0)) THEN 0 ELSE 1 END)
	,dblSDeliveredQty = ISNULL(LS.dblQuantity, 0)
	,dblBalanceToDeliver = ALD.dblSAllocatedQty - ISNULL(LS.dblQuantity, 0)
	,strInvoiceStatus = CASE WHEN (ISNULL(PCT.dblInvoicedQty, 0) = 0 AND ISNULL(SCT.dblInvoicedQty, 0) = 0) THEN 'Not Invoiced' ELSE 'Partially Invoiced' END COLLATE Latin1_General_CI_AS 
	
	--Load Shipment
	,strLoadNumber = LS.strLoadNumber
	,strDestinationCity = LS.strDestinationCity
	,dtmETAPOD = LS.dtmETAPOD
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
LEFT JOIN tblICCommodityAttribute PTP ON PTP.intCommodityAttributeId = IM.intProductTypeId AND PTP.strType = 'ProductType'
LEFT JOIN tblICCommodityAttribute PCA ON PCA.intCommodityAttributeId = IM.intOriginId AND PCA.strType = 'Origin'
LEFT JOIN tblSMCountry PCO ON PCO.intCountryID = PCA.intCountryID
LEFT JOIN tblCTContractBasis PCB ON PCB.intContractBasisId = PCH.intContractBasisId
LEFT JOIN tblCTContractStatus PCS ON PCS.intContractStatusId = PCT.intContractStatusId
LEFT JOIN tblSMCurrency PBC ON PBC.intCurrencyID = PCT.intBasisCurrencyId
LEFT JOIN tblICItemUOM PBIU ON PBIU.intItemUOMId = PCT.intBasisUOMId
LEFT JOIN tblICUnitMeasure PBUOM ON PBUOM.intUnitMeasureId = PBIU.intUnitMeasureId
LEFT JOIN tblEMEntity PEY ON PEY.intEntityId = PCH.intEntityId
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
LEFT JOIN tblICCommodityAttribute PTS ON PTS.intCommodityAttributeId = SIM.intProductTypeId AND PTS.strType = 'ProductType'
LEFT JOIN tblICCommodityAttribute SCA ON SCA.intCommodityAttributeId = SIM.intOriginId AND SCA.strType = 'Origin'
LEFT JOIN tblSMCountry SCO ON SCO.intCountryID = SCA.intCountryID
LEFT JOIN tblCTContractBasis SCB ON SCB.intContractBasisId = SCH.intContractBasisId
LEFT JOIN tblCTContractStatus SCS ON SCS.intContractStatusId = SCT.intContractStatusId
LEFT JOIN tblSMCurrency SBC ON SBC.intCurrencyID = SCT.intBasisCurrencyId
LEFT JOIN tblICItemUOM SBIU ON SBIU.intItemUOMId = SCT.intBasisUOMId
LEFT JOIN tblICUnitMeasure SBUOM ON SBUOM.intUnitMeasureId = SBIU.intUnitMeasureId
LEFT JOIN tblEMEntity SEY ON SEY.intEntityId = SCH.intEntityId
LEFT JOIN tblRKFutureMarket SFM ON SFM.intFutureMarketId = SCT.intFutureMarketId
LEFT JOIN tblRKFuturesMonth SMO ON SMO.intFutureMonthId = SCT.intFutureMonthId
LEFT JOIN tblCTPosition SPO ON SPO.intPositionId = SCH.intPositionId
LEFT JOIN tblICItemUOM SPU ON SPU.intItemUOMId = SCT.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure U4 ON U4.intUnitMeasureId = SPU.intUnitMeasureId
LEFT JOIN tblCTPricingType SPT ON SPT.intPricingTypeId = SCT.intPricingTypeId
LEFT JOIN tblCTFreightRate SFR ON SFR.intFreightRateId = SCT.intFreightRateId
LEFT JOIN tblCTBook BO ON BO.intBookId = ALH.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = ALH.intSubBookId
OUTER APPLY (SELECT L.strLoadNumber, L.dtmETAPOD, L.strDestinationCity, dblQuantity = SUM(LD.dblQuantity) FROM tblLGLoadDetail LD JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			WHERE LD.intAllocationDetailId = ALD.intAllocationDetailId AND L.ysnPosted = 1 AND L.intPurchaseSale IN (2, 3) AND L.intShipmentType = 1
			GROUP BY L.strLoadNumber, L.dtmETAPOD, L.strDestinationCity) LS