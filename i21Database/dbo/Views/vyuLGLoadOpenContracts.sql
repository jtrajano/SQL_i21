CREATE VIEW vyuLGLoadOpenContracts
AS
SELECT CD.intContractDetailId
	,CD.intContractHeaderId
	,CD.intContractSeq
	,CD.intItemId
	,Item.strDescription strItemDescription
	,Item.strItemNo
	,Item.intCommodityId
	,CD.dblQuantity AS dblDetailQuantity
	,CD.intUnitMeasureId
	,CD.intItemUOMId
	,U1.strUnitMeasure AS strUnitMeasure
	,CD.intNetWeightUOMId
	,U2.intUnitMeasureId AS intNetWeightUnitMeasureId
	,U2.strUnitMeasure AS strNetWeightUnitMeasure
	,CD.intCompanyLocationId
	,CL.strLocationName AS strLocationName
	,dblUnLoadedQuantity = 
		CASE WHEN (ShipType.intShipmentType = 2)
			THEN ISNULL(CD.dblBalance, 0)
				- CASE WHEN ((CASE WHEN ISNULL(CD.dblScheduleQty, 0) > ISNULL(CD.dblShippingInstructionQty,0) THEN ISNULL(CD.dblScheduleQty, 0) ELSE ISNULL(CD.dblShippingInstructionQty, 0) END <=0)) THEN 0 
					ELSE CASE WHEN ISNULL(CD.dblScheduleQty, 0) > ISNULL(CD.dblShippingInstructionQty,0) THEN ISNULL(CD.dblScheduleQty, 0) ELSE ISNULL(CD.dblShippingInstructionQty, 0) END 
					END
			ELSE 
				ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0)
			END
	,CH.intContractTypeId intPurchaseSale
	,CH.intEntityId
	,CH.strContractNumber
	,CH.dtmContractDate
	,E.strName strEntityName
	,CONVERT(NVARCHAR(100), CD.dtmStartDate, 101) COLLATE Latin1_General_CI_AS AS strStartDate
	,CONVERT(NVARCHAR(100), CD.dtmEndDate, 101) COLLATE Latin1_General_CI_AS AS strEndDate
	,CD.dtmStartDate
	,CD.dtmEndDate
	,CD.dtmPlannedAvailabilityDate
	,E.intDefaultLocationId
	,dblScheduleQty = CASE WHEN (ShipType.intShipmentType = 2) THEN ISNULL(CD.dblShippingInstructionQty, 0) ELSE ISNULL(CD.dblScheduleQty, 0) END
	,CH.strCustomerContract
	,dblBalance = ISNULL(CD.dblBalance, 0)
	,ysnAllowedToShow = CONVERT(BIT,
		CASE WHEN (CP.ysnValidateExternalPONo = 1 AND ISNULL(CD.strERPPONumber,'') = '') THEN 0
			WHEN (CD.intContractStatusId IN (1,4)  
				AND (CASE WHEN (ShipType.intShipmentType = 2)
						THEN ISNULL(CD.dblBalance, 0)
							- CASE WHEN ((CASE WHEN ISNULL(CD.dblScheduleQty, 0) > ISNULL(CD.dblShippingInstructionQty,0) THEN ISNULL(CD.dblScheduleQty, 0) ELSE ISNULL(CD.dblShippingInstructionQty, 0) END <=0)) THEN 0 
								ELSE CASE WHEN ISNULL(CD.dblScheduleQty, 0) > ISNULL(CD.dblShippingInstructionQty,0) THEN ISNULL(CD.dblScheduleQty, 0) ELSE ISNULL(CD.dblShippingInstructionQty, 0) END 
								END
						ELSE 
							ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0)
						END > 0)) THEN 1
			WHEN CH.ysnUnlimitedQuantity = 1 THEN 1
			ELSE 0 END)
	,CH.ysnUnlimitedQuantity
	,ysnLoad = ISNULL(CH.ysnLoad, 0)
	,CD.dblQuantityPerLoad
	,intNoOfLoad = CONVERT(INT,((ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0)) / NULLIF(CD.dblQuantityPerLoad, 0))) 
	,strItemType = Item.strType
	,CH.intPositionId
	,CTP.strPositionType
	,CD.intLoadingPortId
	,CD.intDestinationPortId
	,CD.intDestinationCityId
	,strOriginPort = LoadingPort.strCity
	,strDestinationPort = DestPort.strCity
	,strDestinationCity = DestCity.strCity
	,CD.strPackingDescription
	,intShippingLineEntityId = CD.intShippingLineId
	,strShippingLine = ShipLine.strName
	,CD.intNumberOfContainers
	,CD.intContainerTypeId
	,Cont.strContainerType
	,CD.strVessel
	,CH.intContractTypeId
	,S.strSampleStatus
	,S.strSampleNumber
	,S.strContainerNumber
	,S.strSampleTypeName
	,strTestingStartDate = CONVERT(NVARCHAR(100), S.dtmTestingStartDate, 101) COLLATE Latin1_General_CI_AS
	,strTestingEndDate = CONVERT(NVARCHAR(100), S.dtmTestingEndDate, 101) COLLATE Latin1_General_CI_AS
	,intCompanyLocationSubLocationId = CASE WHEN S.intCompanyLocationSubLocationId IS NULL THEN CD.intSubLocationId ELSE S.intCompanyLocationSubLocationId END
	,strSubLocationName = CASE WHEN ISNULL(S.strSubLocationName, '') = '' THEN CLSL.strSubLocationName ELSE S.strSubLocationName END
	,dblContainerQty = S.dblRepresentingQty
	,strStorageLocationName = SL.strName
	,CD.intStorageLocationId
	,intShipmentType = ShipType.intShipmentType
	,CD.strERPPONumber
	,ysnSampleRequired = ISNULL(WG.ysnSample,0)
	,strOrigin = ISNULL(CO.strCountry, CO2.strCountry)
	,CD.intBookId
	,BO.strBook
	,CD.intSubBookId
	,SB.strSubBook
	,dblSeqPrice = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.dblCashPrice ELSE AD.dblSeqPrice END
	,PT.strPricingType
	,intSeqCurrencyId = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intCurrencyId ELSE AD.intSeqCurrencyId END
	,strSeqCurrency = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CPCU.strCurrency ELSE AD.strSeqCurrency END
	,intSeqPriceUOMId = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intPriceItemUOMId ELSE AD.intSeqPriceUOMId END
	,strSeqPriceUOM = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN U3.strUnitMeasure ELSE AD.strSeqPriceUOM END 
	,ysnSubCurrency = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CPCU.ysnSubCurrency ELSE PCU.ysnSubCurrency END
	,intRateTypeId = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intRateTypeId ELSE NULL END
	,dblRate = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.dblRate ELSE NULL END
	,intInvoiceCurrencyId = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intInvoiceCurrencyId ELSE NULL END
	,strInvoiceCurrency = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN FXC.strCurrency ELSE NULL END
	,strCurrencyExchangeRateType = CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CET.strCurrencyExchangeRateType ELSE NULL END
	,CD.intFreightTermId
	,FT.strFreightTerm
	,CD.intShipToId
	,strShipTo = SH.strLocationName
	,intHeaderBookId = CH.intBookId
	,intHeaderSubBookId = CH.intSubBookId
	,ysnAllowReweighs = WW.ysnPayablesOnShippedWeights
FROM (SELECT intShipmentType = 1 UNION SELECT intShipmentType = 2) ShipType
CROSS JOIN tblCTContractHeader CH
INNER JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
INNER JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
INNER JOIN tblICItem Item ON Item.intItemId = CD.intItemId
INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
INNER JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
LEFT JOIN tblSMCurrency PCU ON PCU.intCurrencyID = AD.intSeqCurrencyId
LEFT JOIN tblSMCurrency FXC ON FXC.intCurrencyID = CD.intInvoiceCurrencyId
LEFT JOIN tblSMCurrency CPCU ON CPCU.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM WIU ON WIU.intItemUOMId = CD.intNetWeightUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = WIU.intUnitMeasureId
LEFT JOIN tblICItemUOM PIU ON PIU.intItemUOMId = CD.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure U3 ON U3.intUnitMeasureId = PIU.intUnitMeasureId
LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId
LEFT JOIN tblSMCity DestPort ON DestPort.intCityId = CD.intDestinationPortId
LEFT JOIN tblSMCity DestCity ON DestCity.intCityId = CD.intDestinationCityId
LEFT JOIN tblEMEntity ShipLine ON ShipLine.intEntityId = CD.intShippingLineId
LEFT JOIN tblLGContainerType Cont ON Cont.intContainerTypeId = CD.intContainerTypeId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intGradeId
LEFT JOIN tblCTWeightGrade WW ON WW.intWeightGradeId = CH.intWeightId
LEFT JOIN tblCTPosition CTP ON CTP.intPositionId = CH.intPositionId
LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
LEFT JOIN tblICItemContract ICI ON ICI.intItemId = Item.intItemId
	AND CD.intItemContractId = ICI.intItemContractId
LEFT JOIN tblSMCurrencyExchangeRateType CET ON CET.intCurrencyExchangeRateTypeId = CD.intRateTypeId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CD.intFreightTermId
LEFT JOIN tblSMCountry CO ON CO.intCountryID = ICI.intCountryId
LEFT JOIN tblSMCountry CO2 ON CO2.intCountryID = CA.intCountryID
LEFT JOIN tblEMEntityLocation SH ON SH.intEntityLocationId = CD.intShipToId
OUTER APPLY (
	SELECT TOP 1
		S.intContractDetailId
		,S.strSampleNumber
		,S.strContainerNumber
		,ST.strSampleTypeName
		,SS.strStatus AS strSampleStatus
		,S.dtmTestingStartDate
		,S.dtmTestingEndDate
		,S.intCompanyLocationSubLocationId
		,CLSL.strSubLocationName
		,S.dblRepresentingQty
	FROM tblQMSample S
	JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
	WHERE S.intContractDetailId = CD.intContractDetailId
	ORDER BY S.dtmTestingEndDate DESC, S.intSampleId DESC) S 
CROSS APPLY tblLGCompanyPreference CP
OUTER APPLY (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference) DC
