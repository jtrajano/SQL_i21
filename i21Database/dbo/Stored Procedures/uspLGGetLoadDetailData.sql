CREATE PROCEDURE uspLGGetLoadDetailData
	@intLoadId INT
AS
BEGIN
	SELECT LoadDetail.*
		,strItemDescription = Item.strDescription
		,strItemNo = Item.strItemNo
		,strPLocationName = PCL.strLocationName
		,strSLocationName = SCL.strLocationName
		,strPSubLocationName = PCLSL.strSubLocationName
		,strSSubLocationName = SCLSL.strSubLocationName
		,strPStorageLocation = PSTL.strName
		,strSStorageLocation = SSTL.strName
		,strPContractNumber = PHeader.strContractNumber
		,intPContractSeq = PDetail.intContractSeq
		,strPPricingType = PTP.strPricingType
		,intPPricingTypeId = PDetail.intPricingTypeId
		,ysnPLoad = PHeader.ysnLoad
		,dblPQuantityPerLoad = PDetail.dblQuantityPerLoad
		,dblPAvailableQty = PDetail.dblBalance - ISNULL(PDetail.dblScheduleQty, 0)
		,strPCropYear = PCY.strCropYear
		,strPLoadingPort = PLP.strCity
		,strPDestinationPort = PDP.strCity
		,strSContractNumber = SHeader.strContractNumber
		,intSContractSeq = SDetail.intContractSeq
		,intPPricingTypeId = PDetail.intPricingTypeId
		,strPPricingType = PTP.strPricingType
		,intSPricingTypeId = SDetail.intPricingTypeId
		,strSPricingType = PTS.strPricingType
		,ysnSLoad = SHeader.ysnLoad
		,dblSQuantityPerLoad = SDetail.dblQuantityPerLoad
		,strSCropYear = SCY.strCropYear
		,strSLoadingPort = SLP.strCity
		,strSDestinationPort = SDP.strCity
		,strVendor = VEN.strName
		,strCustomer = CEN.strName
		,strShipFrom = VEL.strLocationName
		,strShipTo = CEL.strLocationName
		,strSeller = SLR.strName
		,strSalesperson = SP.strName
		,ysnBundle = CONVERT(BIT, CASE Item.strType
				WHEN 'Bundle'
					THEN 1
				ELSE 0
				END)
		,intContractItemId = ICI.intItemId
		,intContractHeaderId = CASE 
			WHEN L.intPurchaseSale = 2
				THEN SHeader.intContractHeaderId
			ELSE PHeader.intContractHeaderId
			END 
		,strItemUOM = UOM.strUnitMeasure
		,intUnitMeasureId = UOM.intUnitMeasureId
		,strWeightItemUOM = WeightUOM.strUnitMeasure
		,intWeightUnitMeasureId = WeightUOM.intUnitMeasureId
		,dblWeightPerUnit = IsNull(dbo.fnLGGetItemUnitConversion (LoadDetail.intItemId, LoadDetail.intItemUOMId, ISNULL(L.intWeightUnitMeasureId, WeightUOM.intUnitMeasureId)), 0.0)
		,dblUnMatchedQty = CASE WHEN (SELECT COUNT(*) FROM tblLGLoadDetailContainerLink WHERE intLoadId = L.intLoadId) > 0 THEN 0 ELSE LoadDetail.dblQuantity END
		,strOrigin = CO.strCountry
		,strCropYear = CPY.strCropYear
		,intCommodityAttributeId = CA.intCommodityAttributeId
		,intCommodityId = Item.intCommodityId
		,strExternalShipmentNumber
		,strBillId = B.strBillId
		,strPriceCurrency = PCU.strCurrency
		,strForexCurrency = FXCU.strCurrency
		,strForexRateType = ERT.strCurrencyExchangeRateType
		,strPriceUOM = PUM.strUnitMeasure
		,ysnSubCurrency = PCU.ysnSubCurrency
		,dtmCashFlowDate = CASE WHEN (L.intPurchaseSale = 2) THEN SDetail.dtmCashFlowDate ELSE PDetail.dtmCashFlowDate END
		,strSiteID = RIGHT('000'+ CAST(TMS.intSiteNumber AS NVARCHAR(4)),4)  COLLATE Latin1_General_CI_AS
		,strSerialNumber = TMD.strSerialNumber
		,strXRefVendorProduct = IVX.strVendorProduct
		,intBatchId = QB.intBatchId
		,strBatchId = QB.strBatchId
		,strTeaGardenChopInvoiceNumber = QB.strTeaGardenChopInvoiceNumber
		,strVendorLotNumber = QB.strVendorLotNumber
		,intBrokerId = QB.intBrokerId
		,strBroker = EB.strName
		,strLeafGrade = QB.strLeafGrade
		,intGardenMarkId = QB.intGardenMarkId
		,strGardenMark = GM.strGardenMark
		,strSustainability = QB.strSustainability
		,ysnTeaOrganic = QB.ysnTeaOrganic
		,intSales = QB.intSales
		,intSalesYear = QB.intSalesYear
		,strCatalogueType = QCT.strCatalogueType
		,strManufacturingLeafType = QB.strLeafManufacturingType
	FROM tblLGLoadDetail LoadDetail
		 JOIN tblLGLoad							L			ON		L.intLoadId = LoadDetail.intLoadId AND L.intLoadId = @intLoadId
	LEFT JOIN tblSMCompanyLocation				PCL				ON		PCL.intCompanyLocationId = LoadDetail.intPCompanyLocationId
	LEFT JOIN tblSMCompanyLocation				SCL				ON		SCL.intCompanyLocationId = LoadDetail.intSCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation	PCLSL			ON		PCLSL.intCompanyLocationSubLocationId = LoadDetail.intPSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation	SCLSL			ON		SCLSL.intCompanyLocationSubLocationId = LoadDetail.intSSubLocationId
	LEFT JOIN tblICStorageLocation				PSTL			ON		PSTL.intStorageLocationId = LoadDetail.intPStorageLocationId
	LEFT JOIN tblICStorageLocation				SSTL			ON		SSTL.intStorageLocationId = LoadDetail.intSStorageLocationId
	LEFT JOIN tblCTContractDetail				PDetail			ON		PDetail.intContractDetailId = LoadDetail.intPContractDetailId
	LEFT JOIN tblCTContractHeader				PHeader			ON		PHeader.intContractHeaderId = PDetail.intContractHeaderId
	LEFT JOIN tblCTContractDetail				SDetail			ON		SDetail.intContractDetailId = LoadDetail.intSContractDetailId
	LEFT JOIN tblCTContractHeader				SHeader			ON		SHeader.intContractHeaderId = SDetail.intContractHeaderId
	LEFT JOIN tblCTPricingType					PTP				ON		PTP.intPricingTypeId = PDetail.intPricingTypeId
	LEFT JOIN tblCTPricingType					PTS				ON		PTS.intPricingTypeId = SDetail.intPricingTypeId
	LEFT JOIN tblCTCropYear						PCY				ON		PCY.intCropYearId = PHeader.intCropYearId
	LEFT JOIN tblCTCropYear						SCY				ON		SCY.intCropYearId = SHeader.intCropYearId
	LEFT JOIN tblCTCropYear						CPY				ON		CPY.intCropYearId = LoadDetail.intCropYearId
	LEFT JOIN tblSMCity							PLP				ON		PLP.intCityId = PDetail.intLoadingPortId
	LEFT JOIN tblSMCity							PDP				ON		PDP.intCityId = PDetail.intDestinationPortId
	LEFT JOIN tblSMCity							SLP				ON		SLP.intCityId = SDetail.intLoadingPortId
	LEFT JOIN tblSMCity							SDP				ON		SDP.intCityId = SDetail.intDestinationPortId
	LEFT JOIN tblEMEntity						VEN				ON		VEN.intEntityId = LoadDetail.intVendorEntityId
	LEFT JOIN tblEMEntityLocation				VEL				ON		VEL.intEntityLocationId = LoadDetail.intVendorEntityLocationId
	LEFT JOIN tblEMEntity						CEN				ON		CEN.intEntityId = LoadDetail.intCustomerEntityId
	LEFT JOIN tblEMEntityLocation				CEL				ON		CEL.intEntityLocationId = LoadDetail.intCustomerEntityLocationId
	LEFT JOIN tblICItem							Item			ON		Item.intItemId = LoadDetail.intItemId
	LEFT JOIN tblSMCurrency						PCU				ON		PCU.intCurrencyID = LoadDetail.intPriceCurrencyId
	LEFT JOIN tblSMCurrency						FXCU			ON		FXCU.intCurrencyID = LoadDetail.intForexCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRateType		ERT				ON		ERT.intCurrencyExchangeRateTypeId = LoadDetail.intForexRateTypeId
	LEFT JOIN tblICItemUOM						PIM				ON		PIM.intItemUOMId = LoadDetail.intPriceUOMId
	LEFT JOIN tblICUnitMeasure					PUM				ON		PIM.intUnitMeasureId = PUM.intUnitMeasureId
	LEFT JOIN tblICCommodity					Commodity		ON		Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICItemUOM						ItemUOM			ON		ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
	LEFT JOIN tblICUnitMeasure					UOM				ON		UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM						WeightItemUOM	ON		WeightItemUOM.intItemUOMId = LoadDetail.intWeightItemUOMId
	LEFT JOIN tblICUnitMeasure					WeightUOM		ON		WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
	LEFT JOIN tblICCommodityAttribute			CA				ON		CA.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblEMEntity						SLR				ON		SLR.intEntityId = LoadDetail.intSellerId
	LEFT JOIN tblEMEntity						SP				ON		SP.intEntityId = LoadDetail.intSalespersonId
	LEFT JOIN tblAPBillDetail					BD				ON		BD.intLoadDetailId = LoadDetail.intLoadDetailId AND BD.intItemId = LoadDetail.intItemId
	LEFT JOIN tblAPBill							B				ON		B.intBillId = BD.intBillId
	LEFT JOIN tblICItemContract					ICI				ON		ICI.intItemId = Item.intItemId AND PDetail.intItemContractId = ICI.intItemContractId
	LEFT JOIN tblSMCountry						CO				ON		CO.intCountryID = (CASE WHEN ISNULL(ICI.intCountryId, 0) = 0 THEN ISNULL(CA.intCountryID, 0) ELSE ICI.intCountryId END)
	LEFT JOIN tblTMSite							TMS				ON		TMS.intSiteID = LoadDetail.intTMSiteId
	LEFT JOIN tblTMDevice						TMD				ON		TMD.intDeviceId = LoadDetail.intTMDeviceId
    LEFT JOIN tblICItemVendorXref				IVX				ON		IVX.intVendorId = LoadDetail.intVendorEntityId
	LEFT JOIN tblMFBatch						QB				ON		QB.intBatchId = LoadDetail.intBatchId
	LEFT JOIN tblQMSample						QS				ON		QS.intSampleId = QB.intSampleId
	LEFT JOIN tblQMCatalogueType				QCT				ON		QCT.intCatalogueTypeId = QS.intCatalogueTypeId
	LEFT JOIN tblARMarketZone					MZ				ON		MZ.intMarketZoneId = QS.intMarketZoneId
	LEFT JOIN vyuEMSearchEntityBroker			EB				ON		EB.intEntityId = QB.intBrokerId
	LEFT JOIN tblQMGardenMark					GM				ON		GM.intGardenMarkId = QB.intGardenMarkId
END