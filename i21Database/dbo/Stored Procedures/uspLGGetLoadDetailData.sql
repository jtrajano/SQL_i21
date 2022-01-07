CREATE PROCEDURE uspLGGetLoadDetailData
	@intLoadId INT
AS
BEGIN
	SELECT LoadDetail.*
		,strItemDescription = Item.strDescription
		,strPLocationName = PCL.strLocationName
		,strPSubLocationName = PCLSL.strSubLocationName
		,strSSubLocationName = SCLSL.strSubLocationName
		,strSLocationName = SCL.strLocationName
		,strPContractNumber = PHeader.strContractNumber
		,intPContractSeq = PDetail.intContractSeq
		,strPPricingType = PTP.strPricingType
		,intPPricingTypeId = PDetail.intPricingTypeId
		,ysnPLoad = PHeader.ysnLoad
		,dblPQuantityPerLoad = PDetail.dblQuantityPerLoad
		,strSContractNumber = SHeader.strContractNumber
		,intSContractSeq = SDetail.intContractSeq
		,intPPricingTypeId = PDetail.intPricingTypeId
		,strPPricingType = PTP.strPricingType
		,intSPricingTypeId = SDetail.intPricingTypeId
		,strSPricingType = PTS.strPricingType
		,ysnSLoad = SHeader.ysnLoad
		,dblSQuantityPerLoad = SDetail.dblQuantityPerLoad
		,strVendor = VEN.strName
		,strCustomer = CEN.strName
		,strShipFrom = VEL.strLocationName
		,strShipTo = CEL.strLocationName
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
	FROM tblLGLoadDetail LoadDetail
		 JOIN tblLGLoad							L			ON		L.intLoadId = LoadDetail.intLoadId AND L.intLoadId = @intLoadId
	LEFT JOIN tblSMCompanyLocation				PCL				ON		PCL.intCompanyLocationId = LoadDetail.intPCompanyLocationId
	LEFT JOIN tblSMCompanyLocation				SCL				ON		SCL.intCompanyLocationId = LoadDetail.intSCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation	PCLSL			ON		PCLSL.intCompanyLocationSubLocationId = LoadDetail.intPSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation	SCLSL			ON		SCLSL.intCompanyLocationSubLocationId = LoadDetail.intSSubLocationId
	LEFT JOIN tblCTContractDetail				PDetail			ON		PDetail.intContractDetailId = LoadDetail.intPContractDetailId
	LEFT JOIN tblCTContractHeader				PHeader			ON		PHeader.intContractHeaderId = PDetail.intContractHeaderId
	LEFT JOIN tblCTContractDetail				SDetail			ON		SDetail.intContractDetailId = LoadDetail.intSContractDetailId
	LEFT JOIN tblCTContractHeader				SHeader			ON		SHeader.intContractHeaderId = SDetail.intContractHeaderId
	LEFT JOIN tblCTPricingType					PTP				ON		PTP.intPricingTypeId = PDetail.intPricingTypeId
	LEFT JOIN tblCTPricingType					PTS				ON		PTS.intPricingTypeId = SDetail.intPricingTypeId
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
	LEFT JOIN tblAPBillDetail					BD				ON		BD.intLoadDetailId = LoadDetail.intLoadDetailId AND BD.intItemId = LoadDetail.intItemId
	LEFT JOIN tblAPBill							B				ON		B.intBillId = BD.intBillId
	LEFT JOIN tblICItemContract					ICI				ON		ICI.intItemId = Item.intItemId AND PDetail.intItemContractId = ICI.intItemContractId
	LEFT JOIN tblSMCountry						CO				ON		CO.intCountryID = (CASE 
																							WHEN ISNULL(ICI.intCountryId, 0) = 0
																								THEN ISNULL(CA.intCountryID, 0)
																							ELSE ICI.intCountryId
																							END)
END