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
	,dblPAllocatedQty = ISNULL(dbo.fnCalculateQtyBetweenUOM(PCT.intItemUOMId, PToUOM.intItemUOMId, ALD.dblPAllocatedQty), ALD.dblPAllocatedQty)
	,dblPContractAllocatedQty = PCT.dblAllocatedQty
	,intPUnitMeasureId = ALD.intPUnitMeasureId
	,strPurchaseContractNumber = PCH.strContractNumber
	,intPContractSeq = PCT.intContractSeq
	,strPContractNumber = Cast(PCH.strContractNumber AS VARCHAR(100)) + '/' + Cast(PCT.intContractSeq AS VARCHAR(100))
	,strPERPPONumber = PCT.strERPPONumber
	,intPItemId = PCT.intItemId
	,strPItemUOM = U1.strUnitMeasure
	,strPItemNo = IM.strItemNo
	,strPItemDescription = IM.strDescription 
	,strPItemOrigin = PCA.strDescription
	,strPProductType = PTP.strDescription
	,strPBundleItemNo = PBI.strItemNo
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
	,intPShippingInstructionId = PSIH.intLoadId
	,strPShippingInstruction = PSIH.strLoadNumber
	,intPShippingAdviceId = PLSH.intLoadId
	,strPShippingAdvice = PLSH.strLoadNumber
	,strPReceiptNumber = PIRH.strReceiptNumber
	,intPInventoryReceiptId = PIRH.intInventoryReceiptId
	,strPWarehouse = PLSWSL.strSubLocationName
	,strPLogisticsLead = PLL.strName
	,strPSampleType = PST.strSampleTypeName
	,strPSampleStatus = PSS.strStatus
	,dtmPUpdatedDate = PS.dtmTestedOn
	,strPShipmentStatus = PLSSS.strShipmentStatus
	,strPFinancialStatus = CASE WHEN PCT.ysnFinalPNL = 1 THEN 'Final P&L Created'
						WHEN PCT.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created'
						WHEN BD.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received' 
						WHEN PCT.strFinancialStatus IS NOT NULL THEN PCT.strFinancialStatus 
						ELSE '' END
	,dblPPricedLots =  CASE WHEN PCT.intPricingTypeId IN(1,6) THEN ISNULL(PCT.dblNoOfLots, 0) ELSE PFI.dblLotsFixed END
	,dblPUnpricedLots = CASE WHEN PCT.intPricingTypeId IN(1,6) THEN NULL ELSE ISNULL(PCT.dblNoOfLots, 0) - ISNULL(PFI.dblLotsFixed, 0) END
	---- Sales Contract Details
	,intSContractDetailId = ALD.intSContractDetailId
	,dblSAllocatedQty = ISNULL(dbo.fnCalculateQtyBetweenUOM(SCT.intItemUOMId, SToUOM.intItemUOMId, ALD.dblSAllocatedQty), ALD.dblSAllocatedQty)
	,dblSContractAllocatedQty = SCT.dblAllocatedQty
	,intSUnitMeasureId = ALD.intSUnitMeasureId
	,strSalesContractNumber = SCH.strContractNumber
	,intSContractSeq = SCT.intContractSeq
	,strSContractNumber = Cast(SCH.strContractNumber as VarChar(100)) + '/' + Cast(SCT.intContractSeq as VarChar(100))
	,strSCustomerRefNo = SCH.strCustomerContract
	,strSERPPONumber = SCT.strERPPONumber
	,intSItemId = SCT.intItemId
	,strSItemUOM = U3.strUnitMeasure
	,strSItemNo = SIM.strItemNo
	,strSItemDescription = SIM.strDescription
	,strSItemDescriptionSpecification = SIM.strDescription + ' - ' + ISNULL(SCT.strItemSpecification,'')
	,strSItemOrigin = SCA.strDescription
	,strSProductType = PTS.strDescription
	,strSBundleItemNo = SBI.strItemNo
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
	,strSLogisticsLead = SLL.strName
	,strSSampleType = SST.strSampleTypeName
	,strSSampleStatus = SSS.strStatus
	,dtmSUpdatedDate = SS.dtmTestedOn
	,strSShipmentStatus = SLSSS.strShipmentStatus
	,strSFinancialStatus = SFS.strFinancialStatus
	,intSShippedId = SLSH.intLoadId
	,strSShipped = SLSH.strLoadNumber
	,intSInvoiceId = ISNULL(SPFIH.intInvoiceId, SDIH.intInvoiceId)
	,strSInvoiceNo = ISNULL(SPFIH.strInvoiceNumber, SDIH.strInvoiceNumber)
	,intSInvoiceIdProvisional = SPIH.intInvoiceId
	,strSInvoiceNoProvisional = SPIH.strInvoiceNumber
	,dblSPricedLots =  CASE WHEN SCT.intPricingTypeId IN(1,6) THEN ISNULL(SCT.dblNoOfLots, 0) ELSE SFI.dblLotsFixed END
	,dblSUnpricedLots = CASE WHEN SCT.intPricingTypeId IN(1,6) THEN NULL ELSE ISNULL(SCT.dblNoOfLots, 0) - ISNULL(SFI.dblLotsFixed, 0) END
	,ysnDelivered = CONVERT(BIT, 
		CASE WHEN (ISNULL(dbo.fnCalculateQtyBetweenUOM(SCT.intItemUOMId, SToUOM.intItemUOMId, ALD.dblSAllocatedQty), ALD.dblSAllocatedQty) > ISNULL(LS.dblQuantity, 0)) THEN 0 ELSE 1 END)
	,dblSDeliveredQty = ISNULL(LS.dblQuantity, 0)
	,dblBalanceToDeliver = dbo.fnCalculateQtyBetweenUOM(SCT.intItemUOMId, SToUOM.intItemUOMId, ALD.dblSAllocatedQty) - ISNULL(LSB.dblBatchQuantity, 0)
	,strInvoiceStatus = CASE WHEN (ISNULL(PCT.dblInvoicedQty, 0) = 0 AND ISNULL(SCT.dblInvoicedQty, 0) = 0) THEN 'Not Invoiced' ELSE 'Partially Invoiced' END COLLATE Latin1_General_CI_AS

	-- Certificates
	,strPCertificates = PCC.strCertificates
	,strSCertificates = SCC.strCertificates

	-- Crop Year
	,strPCropYear = PCY.strCropYear
	,strSCropYear = SCY.strCropYear
	
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
LEFT JOIN tblICItem PBI ON PBI.intItemId = PCT.intItemBundleId
LEFT JOIN tblSMCountry PCO ON PCO.intCountryID = PCA.intCountryID
LEFT JOIN tblSMFreightTerms PCB ON PCB.intFreightTermId = PCH.intFreightTermId
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
OUTER APPLY (SELECT TOP 1 intContractDetailId FROM tblAPBillDetail bd WHERE bd.intContractDetailId = PCT.intContractDetailId) BD
LEFT JOIN tblCTContractDetail SCT ON SCT.intContractDetailId = ALD.intSContractDetailId
LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCT.intContractHeaderId
LEFT JOIN tblICItemUOM SIU ON SIU.intItemUOMId = SCT.intItemUOMId
LEFT JOIN tblICUnitMeasure U3 ON U3.intUnitMeasureId = SIU.intUnitMeasureId
LEFT JOIN tblICItem SIM ON SIM.intItemId = SCT.intItemId
LEFT JOIN tblICCommodityAttribute PTS ON PTS.intCommodityAttributeId = SIM.intProductTypeId AND PTS.strType = 'ProductType'
LEFT JOIN tblICCommodityAttribute SCA ON SCA.intCommodityAttributeId = SIM.intOriginId AND SCA.strType = 'Origin'
LEFT JOIN tblICItem SBI ON SBI.intItemId = SCT.intItemBundleId
LEFT JOIN tblSMCountry SCO ON SCO.intCountryID = SCA.intCountryID
LEFT JOIN tblSMFreightTerms SCB ON SCB.intFreightTermId = SCH.intFreightTermId
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
LEFT JOIN (tblLGLoadDetail SLSD INNER JOIN tblLGLoad SLSH ON SLSH.intLoadId = SLSD.intLoadId)
	ON SLSD.intSContractDetailId = SCT.intContractDetailId AND SLSH.intShipmentType = 1
LEFT JOIN (tblLGLoadDetail PSID INNER JOIN tblLGLoad PSIH ON PSIH.intLoadId = PSID.intLoadId)
	ON PSID.intPContractDetailId = PCT.intContractDetailId AND PSIH.intShipmentType = 2 AND (
		(PSIH.intSourceType = 4 AND PSID.intSContractDetailId = SCT.intContractDetailId) OR (PSIH.intSourceType <> 4)
	)
LEFT JOIN (tblLGLoadDetail PLSD INNER JOIN tblLGLoad PLSH ON PLSH.intLoadId = PLSD.intLoadId)
	ON PLSD.intPContractDetailId = PCT.intContractDetailId AND PLSH.intShipmentType = 1 AND (
		(PLSH.intSourceType = 4 AND PLSD.intSContractDetailId = SCT.intContractDetailId) OR (PLSH.intSourceType <> 4)
	)
LEFT JOIN (tblICInventoryReceiptItem PIRD INNER JOIN tblICInventoryReceipt PIRH ON PIRH.intInventoryReceiptId = PIRD.intInventoryReceiptId)
	ON PIRD.intLoadShipmentDetailId = PLSD.intLoadDetailId
LEFT JOIN (tblLGLoadWarehouse PLSW INNER JOIN tblSMCompanyLocationSubLocation PLSWSL ON PLSWSL.intCompanyLocationSubLocationId = PLSW.intSubLocationId) ON PLSW.intLoadId = PLSH.intLoadId
LEFT JOIN tblEMEntity PLL ON PLL.intEntityId = PCT.intLogisticsLeadId
LEFT JOIN (tblQMSample PS INNER JOIN tblQMSampleType PST ON PST.intSampleTypeId = PS.intSampleTypeId) ON PS.intProductValueId = PCT.intContractDetailId AND PS.intProductTypeId = 8 -- Contract item
LEFT JOIN tblQMSampleStatus PSS ON PSS.intSampleStatusId = PS.intSampleStatusId
LEFT JOIN vyuCTShipmentStatus PLSSS ON PLSSS.intLoadDetailId = PLSD.intLoadDetailId
LEFT JOIN tblEMEntity SLL ON SLL.intEntityId = SCT.intLogisticsLeadId
LEFT JOIN (tblQMSample SS INNER JOIN tblQMSampleType SST ON SST.intSampleTypeId = SS.intSampleTypeId) ON SS.intProductValueId = SCT.intContractDetailId AND SS.intProductTypeId = 8 -- Contract item
LEFT JOIN tblQMSampleStatus SSS ON SSS.intSampleStatusId = SS.intSampleStatusId
LEFT JOIN vyuCTShipmentStatus SLSSS ON SLSSS.intLoadDetailId = SLSD.intLoadDetailId
LEFT JOIN (
	tblARInvoiceDetail SPID
	INNER JOIN tblARInvoice SPIH ON SPIH.intInvoiceId = SPID.intInvoiceId AND SPIH.strType = 'Provisional'
	LEFT JOIN tblARInvoice SPFIH ON SPFIH.intOriginalInvoiceId = SPIH.intInvoiceId AND SPFIH.ysnFromProvisional = 1
) ON SPID.intLoadDetailId = SLSD.intLoadDetailId
LEFT JOIN ( tblARInvoiceDetail SDID INNER JOIN tblARInvoice SDIH ON SDIH.intInvoiceId = SDID.intInvoiceId AND SDIH.ysnFromProvisional = 0) ON SDID.intLoadDetailId = SLSD.intLoadDetailId
OUTER APPLY dbo.fnCTGetFinancialStatus(SCT.intContractDetailId) SFS
-- Crop Year
LEFT JOIN tblCTCropYear PCY ON PCY.intCropYearId = PCH.intCropYearId
LEFT JOIN tblCTCropYear SCY ON SCY.intCropYearId = SCH.intCropYearId
-- Certificates
OUTER APPLY dbo.fnLGGetDelimitedContractCertificates(PCT.intContractDetailId) PCC
OUTER APPLY dbo.fnLGGetDelimitedContractCertificates(SCT.intContractDetailId) SCC
LEFT JOIN tblCTBook BO ON BO.intBookId = ALH.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = ALH.intSubBookId
LEFT JOIN tblCTPriceFixation PFI ON PFI.intContractDetailId = PCT.intContractDetailId
LEFT JOIN tblCTPriceFixation SFI ON SFI.intContractDetailId = SCT.intContractDetailId
OUTER APPLY (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = IM.intItemId AND intUnitMeasureId = ALH.intWeightUnitMeasureId) PToUOM
OUTER APPLY (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = SIM.intItemId AND intUnitMeasureId = ALH.intWeightUnitMeasureId) SToUOM
OUTER APPLY (SELECT L.strLoadNumber, L.dtmETAPOD, L.strDestinationCity, dblQuantity = SUM(ISNULL(dbo.fnCalculateQtyBetweenUOM(LD.intItemUOMId, ToUOM.intItemUOMId, LD.dblQuantity), 0)) 
				FROM tblLGLoadDetail LD JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
				OUTER APPLY (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = LD.intItemId AND intUnitMeasureId = ALH.intWeightUnitMeasureId) ToUOM
			WHERE LD.intAllocationDetailId = ALD.intAllocationDetailId AND L.ysnPosted = 1 AND L.intPurchaseSale IN (2, 3) AND L.intShipmentType = 1
			GROUP BY L.strLoadNumber, L.dtmETAPOD, L.strDestinationCity) LS
OUTER APPLY (SELECT 
				dblBatchQuantity = SUM(ISNULL(dbo.fnCalculateQtyBetweenUOM(LD.intItemUOMId, ToUOM.intItemUOMId, LD.dblQuantity), 0)) 
			FROM tblLGLoadDetail LD JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
				OUTER APPLY (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = LD.intItemId AND intUnitMeasureId = ALH.intWeightUnitMeasureId) ToUOM
			WHERE LD.intAllocationDetailId = ALD.intAllocationDetailId AND L.ysnPosted = 1 AND L.intPurchaseSale IN (2, 3) AND L.intShipmentType = 1) LSB