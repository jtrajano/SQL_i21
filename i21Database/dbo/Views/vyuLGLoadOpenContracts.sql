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
	,ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0) AS dblUnLoadedQuantity
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
	,ISNULL(CD.dblScheduleQty, 0) AS dblScheduleQty
	,CH.strCustomerContract
	,ISNULL(CD.dblBalance, 0) AS dblBalance
	,CASE WHEN CP.ysnValidateExternalPONo = 1 AND ISNULL(CD.strERPPONumber,'')= ''
		THEN CAST(0 AS BIT)
	ELSE
		CASE 
			WHEN (
					(
						CAST(CASE 
								WHEN CD.intContractStatusId IN (1,4)
									THEN 1
								ELSE 0
								END AS BIT) = 1
						)
					AND (
						(ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0) > 0)
						OR (CH.ysnUnlimitedQuantity = 1)
						)
					)
				THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
			END 
		END AS ysnAllowedToShow
	,CH.ysnUnlimitedQuantity
	,ISNULL(CH.ysnLoad, 0) AS ysnLoad
	,CD.dblQuantityPerLoad
	,intNoOfLoad = CONVERT(INT,((ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0)) / NULLIF(CD.dblQuantityPerLoad, 0))) 
	,Item.strType AS strItemType
	,CH.intPositionId
	,CTP.strPositionType
	,CD.intLoadingPortId
	,CD.intDestinationPortId
	,CD.intDestinationCityId
	,LoadingPort.strCity AS strOriginPort
	,DestPort.strCity AS strDestinationPort
	,DestCity.strCity AS strDestinationCity
	,CD.strPackingDescription
	,CD.intShippingLineId AS intShippingLineEntityId
	,ShipLine.strName AS strShippingLine
	,CD.intNumberOfContainers
	,CD.intContainerTypeId
	,Cont.strContainerType
	,CD.strVessel
	,CH.intContractTypeId
	,S.strSampleStatus
	,S.strSampleNumber
	,S.strContainerNumber
	,S.strSampleTypeName
	,CONVERT(NVARCHAR(100), S.dtmTestingStartDate, 101) COLLATE Latin1_General_CI_AS AS strTestingStartDate
	,CONVERT(NVARCHAR(100), S.dtmTestingEndDate, 101) COLLATE Latin1_General_CI_AS AS strTestingEndDate
	,CASE 
		WHEN S.intCompanyLocationSubLocationId IS NULL
			THEN CD.intSubLocationId
		ELSE S.intCompanyLocationSubLocationId
		END AS intCompanyLocationSubLocationId
	,CASE 
		WHEN ISNULL(S.strSubLocationName, '') = ''
			THEN CLSL.strSubLocationName
		ELSE S.strSubLocationName
		END AS strSubLocationName
	,S.dblRepresentingQty AS dblContainerQty
	,SL.strName AS strStorageLocationName
	,CD.intStorageLocationId
	,intShipmentType = 1
	,CD.strERPPONumber
	,ISNULL(WG.ysnSample,0) AS ysnSampleRequired
	,strOrigin = ISNULL(CO.strCountry, CO2.strCountry)
	,CD.intBookId
	,BO.strBook
	,CD.intSubBookId
	,SB.strSubBook
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.dblCashPrice ELSE AD.dblSeqPrice END AS dblSeqPrice
	,PT.strPricingType
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intCurrencyId ELSE AD.intSeqCurrencyId END AS intSeqCurrencyId
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CPCU.strCurrency ELSE AD.strSeqCurrency END AS strSeqCurrency
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intPriceItemUOMId ELSE AD.intSeqPriceUOMId END AS intSeqPriceUOMId
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN U3.strUnitMeasure ELSE AD.strSeqPriceUOM END AS strSeqPriceUOM 
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CPCU.ysnSubCurrency ELSE PCU.ysnSubCurrency END AS ysnSubCurrency
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intRateTypeId ELSE NULL END AS intRateTypeId
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.dblRate ELSE NULL END AS dblRate
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intInvoiceCurrencyId ELSE NULL END AS intInvoiceCurrencyId
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN FXC.strCurrency ELSE NULL END AS strInvoiceCurrency
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CET.strCurrencyExchangeRateType ELSE NULL END AS strCurrencyExchangeRateType
	,CD.intFreightTermId
	,FT.strFreightTerm
	,CD.intShipToId
	,strShipTo = SH.strLocationName
	,intHeaderBookId = CH.intBookId
	,intHeaderSubBookId = CH.intSubBookId
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
JOIN tblICItem Item ON Item.intItemId = CD.intItemId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
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

UNION

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
	,dblUnLoadedQuantity = ISNULL(CD.dblBalance, 0) - 
			CASE WHEN ((CASE WHEN ISNULL(CD.dblScheduleQty, 0) > ISNULL(CD.dblShippingInstructionQty,0) THEN ISNULL(CD.dblScheduleQty, 0) ELSE ISNULL(CD.dblShippingInstructionQty, 0) END <=0)) THEN 0 
				ELSE CASE WHEN ISNULL(CD.dblScheduleQty, 0) > ISNULL(CD.dblShippingInstructionQty,0) THEN ISNULL(CD.dblScheduleQty, 0) ELSE ISNULL(CD.dblShippingInstructionQty, 0) END 
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
	,ISNULL(CD.dblShippingInstructionQty, 0) AS dblScheduleQty
	,CH.strCustomerContract
	,ISNULL(CD.dblBalance, 0) AS dblBalance
	,CASE WHEN CP.ysnValidateExternalPONo = 1 AND ISNULL(CD.strERPPONumber,'')= ''
		THEN CAST(0 AS BIT)
		ELSE
			CASE 
				WHEN (
						(
							CAST(CASE 
									WHEN CD.intContractStatusId IN (1,4)
										THEN 1
									ELSE 0
									END AS BIT) = 1
							)
						AND (
							(
								ISNULL(CD.dblBalance, 0) - (CASE WHEN ((CASE WHEN ISNULL(CD.dblScheduleQty, 0) > ISNULL(CD.dblShippingInstructionQty,0) THEN ISNULL(CD.dblScheduleQty, 0) ELSE ISNULL(CD.dblShippingInstructionQty, 0) END <=0)) THEN 0 
															ELSE CASE WHEN ISNULL(CD.dblScheduleQty, 0) > ISNULL(CD.dblShippingInstructionQty,0) THEN ISNULL(CD.dblScheduleQty, 0) ELSE ISNULL(CD.dblShippingInstructionQty, 0) END 
															END) > 0
								)
							OR (CH.ysnUnlimitedQuantity = 1)
							)
						)
					THEN CAST(1 AS BIT)
				ELSE CAST(0 AS BIT)
				END 
			END AS ysnAllowedToShow
	,CH.ysnUnlimitedQuantity
	,ISNULL(CH.ysnLoad, 0) AS ysnLoad
	,CD.dblQuantityPerLoad
	,intNoOfLoad = CONVERT(INT,((ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0)) / NULLIF(CD.dblQuantityPerLoad, 0))) 
	,Item.strType AS strItemType
	,CH.intPositionId
	,CTP.strPositionType
	,CD.intLoadingPortId
	,CD.intDestinationPortId
	,CD.intDestinationCityId
	,LoadingPort.strCity AS strOriginPort
	,DestPort.strCity AS strDestinationPort
	,DestCity.strCity AS strDestinationCity
	,CD.strPackingDescription
	,CD.intShippingLineId AS intShippingLineEntityId
	,ShipLine.strName AS strShippingLine
	,CD.intNumberOfContainers
	,CD.intContainerTypeId
	,Cont.strContainerType
	,CD.strVessel
	,CH.intContractTypeId
	,S.strSampleStatus
	,S.strSampleNumber
	,S.strContainerNumber
	,S.strSampleTypeName
	,CONVERT(NVARCHAR(100), S.dtmTestingStartDate, 101) COLLATE Latin1_General_CI_AS AS strTestingStartDate
	,CONVERT(NVARCHAR(100), S.dtmTestingEndDate, 101) COLLATE Latin1_General_CI_AS AS strTestingEndDate
	,CASE 
		WHEN S.intCompanyLocationSubLocationId IS NULL
			THEN CD.intSubLocationId
		ELSE S.intCompanyLocationSubLocationId
		END AS intCompanyLocationSubLocationId
	,CASE 
		WHEN ISNULL(S.strSubLocationName, '') = ''
			THEN CLSL.strSubLocationName
		ELSE S.strSubLocationName
		END AS strSubLocationName
	,S.dblRepresentingQty AS dblContainerQty
	,SL.strName AS strStorageLocationName
	,CD.intStorageLocationId
	,intShipmentType = 2
	,CD.strERPPONumber
	,ISNULL(WG.ysnSample,0) AS ysnSampleRequired
	,strOrigin = ISNULL(CO.strCountry, CO2.strCountry)
	,CD.intBookId
	,BO.strBook
	,CD.intSubBookId
	,SB.strSubBook
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.dblCashPrice ELSE AD.dblSeqPrice END AS dblSeqPrice
	,PT.strPricingType
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intCurrencyId ELSE AD.intSeqCurrencyId END AS intSeqCurrencyId
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CPCU.strCurrency ELSE AD.strSeqCurrency END AS strSeqCurrency
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intPriceItemUOMId ELSE AD.intSeqPriceUOMId END AS intSeqPriceUOMId
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN U3.strUnitMeasure ELSE AD.strSeqPriceUOM END AS strSeqPriceUOM 
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CPCU.ysnSubCurrency ELSE PCU.ysnSubCurrency END AS ysnSubCurrency
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intRateTypeId ELSE NULL END AS intRateTypeId
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.dblRate ELSE NULL END AS dblRate
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CD.intInvoiceCurrencyId ELSE NULL END AS intInvoiceCurrencyId
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN FXC.strCurrency ELSE NULL END AS strInvoiceCurrency
	,CASE WHEN ISNULL(AD.ysnValidFX,0) = 1 AND AD.intSeqCurrencyId <> DC.intDefaultCurrencyId THEN CET.strCurrencyExchangeRateType ELSE NULL END AS strCurrencyExchangeRateType
	,CD.intFreightTermId
	,FT.strFreightTerm
	,CD.intShipToId
	,strShipTo = SH.strLocationName
	,intHeaderBookId = CH.intBookId
	,intHeaderSubBookId = CH.intSubBookId
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
JOIN tblICItem Item ON Item.intItemId = CD.intItemId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
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
GROUP BY CD.intContractDetailId
	,CD.intContractHeaderId
	,CD.intContractSeq
	,CD.intItemId
	,Item.strDescription
	,Item.strItemNo
	,Item.intCommodityId
	,CD.dblQuantity
	,CD.intUnitMeasureId
	,CD.intItemUOMId
	,CD.intPriceItemUOMId
	,U1.strUnitMeasure
	,CD.intNetWeightUOMId
	,U2.intUnitMeasureId
	,U2.strUnitMeasure
	,U3.strUnitMeasure
	,CD.intCompanyLocationId
	,CL.strLocationName
	,CD.dblBalance
	,CD.dblScheduleQty
	,CH.intContractTypeId
	,CH.intEntityId
	,CH.strContractNumber
	,CH.dtmContractDate
	,E.strName
	,CD.dtmStartDate
	,CD.dtmEndDate
	,CD.dtmPlannedAvailabilityDate
	,E.intDefaultLocationId
	,CH.strCustomerContract
	,CD.intContractStatusId
	,CH.ysnUnlimitedQuantity
	,CH.ysnLoad
	,CD.dblQuantityPerLoad
	,CD.intNoOfLoad
	,Item.strType
	,CH.intPositionId
	,CTP.strPositionType
	,CD.intLoadingPortId
	,CD.intDestinationPortId
	,CD.intDestinationCityId
	,LoadingPort.strCity
	,DestCity.strCity
	,DestPort.strCity
	,CD.strPackingDescription
	,CD.intShippingLineId
	,ShipLine.strName
	,CD.intNumberOfContainers
	,CD.intContainerTypeId
	,Cont.strContainerType
	,CD.strVessel
	,S.strSampleStatus
	,S.strSampleNumber
	,S.strContainerNumber
	,S.strSampleTypeName
	,S.dtmTestingStartDate
	,S.dtmTestingEndDate
	,S.intCompanyLocationSubLocationId
	,S.strSubLocationName
	,S.dblRepresentingQty
	,CD.strERPPONumber
	,ysnValidateExternalPONo
	,CD.intSubLocationId
	,CLSL.strSubLocationName
	,SL.strName
	,CD.intStorageLocationId
	,WG.ysnSample
	,CD.dblShippingInstructionQty
	,CD.intFreightTermId
	,CO.strCountry
	,CO2.strCountry
	,CD.intShipToId
	,SH.strLocationName
	,FT.strFreightTerm
	,CD.intBookId
	,BO.strBook
	,CD.intSubBookId
	,SB.strSubBook
	,AD.dblSeqPrice
	,PT.strPricingType
	,AD.intSeqCurrencyId 
	,AD.strSeqCurrency
	,AD.intSeqPriceUOMId
	,AD.strSeqPriceUOM
	,PCU.ysnSubCurrency
	,CD.intRateTypeId
	,CD.dblRate
	,CET.strCurrencyExchangeRateType
	,CD.intInvoiceCurrencyId
	,FXC.strCurrency
	,CD.dblCashPrice
	,CD.intCurrencyId
	,CPCU.strCurrency
	,CPCU.ysnSubCurrency
	,AD.ysnValidFX
	,DC.intDefaultCurrencyId
	,CH.intBookId
	,CH.intSubBookId