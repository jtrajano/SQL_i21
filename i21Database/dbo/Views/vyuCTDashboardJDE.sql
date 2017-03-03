CREATE VIEW [dbo].[vyuCTDashboardJDE]
AS
SELECT 	 
	 CSeq.intContractDetailId
	,CSeq.strContractNumber
	,CSeq.intContractSeq
	,CSeq.strEntityName AS strSupplier
	,PR.strName AS strProducer
	,CSeq.dtmStartDate
	,CSeq.dtmEndDate
	,CD.strLoadingPointType
	,LP.strCity AS strLoadingPoint
	,CD.strDestinationPointType
	,LP.strCity AS strDestinationPoint
	,DC.strCity AS strDestinationCity
	,CD.strShippingTerm
	,SL.strName AS strShippingLine
	,CD.strVessel
	,Shp.strName AS strShipper
	,SB.strSubLocationName
	,SLoc.strName AS strStorageLocationName
	,CSeq.dblQuantity
	,CSeq.strItemUOM
	,CSeq.dblNetWeight
	,dbo.fnCTConvertQuantityToTargetItemUOM(CSeq.intItemId, U7.intUnitMeasureId, U8.intUnitMeasureId, CSeq.dblNetWeight) [NetWeight-MT]
	,CSeq.strNetWeightUOM
	,CD.strFixationBy
	,CSeq.strPricingType
	,CSeq.strCurrency
	,CSeq.strFutMarketName
	,CSeq.strFutureMonth
	,CSeq.dblFutures
	,CSeq.dblBasis
	,CSeq.dblCashPrice
	,CD.dblTotalCost
	,ISNULL(RY.strCountry,OG.strCountry) AS strOrigin
	,PG.strName AS strPurchasingGroup
	,ContainerType.strContainerType
	,CD.intNumberOfContainers
	,CSeq.strItemNo
	,ProductType.strDescription AS strProductType
	,CS.strContractStatus
	,(CSeq.dblQuantity - CSeq.dblBalance) AS dblQtyShortClosed
	,FT.strFreightTerm
	,SV.strShipVia
	,Book.strBook
	,SubBook.strSubBook
	,CD.strInvoiceNo
	,Certification.strCertificationName
	,CH.intContractHeaderId
	,ISNULL(CD.dblScheduleQty,0) AS dblScheduleQty
	,CASE 
		WHEN	ISNULL(CD.ysnInvoice,0)=0 THEN 'N'	
		ELSE 'Y' 
	 END 
	 AS ysnInvoice
	,CASE 
		WHEN	ISNULL(CD.ysnProvisionalInvoice,0)=0 THEN 'N'	
		ELSE 'Y' 
	 END 
	 AS ysnProvisionalInvoice
	,CASE 
		WHEN	ISNULL(CD.ysnQuantityFinal,0)=0 THEN 'N'	
		ELSE 'Y' 
	 END  
	 AS ysnQuantityFinal
	,CH.strInternalComment
	,LG.dblQuantity AS dblShippingInsQty
FROM vyuCTContractSequence CSeq
JOIN tblCTContractDetail CD ON CD.intContractDetailId = CSeq.intContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CSeq.intContractHeaderId
JOIN tblICItem Item ON Item.intItemId = CSeq.intItemId
LEFT JOIN tblEMEntity PR ON PR.intEntityId = CH.intProducerId
LEFT JOIN tblSMCity LP ON LP.intCityId = CD.intLoadingPortId
LEFT JOIN tblSMCity DC ON DC.intCityId = CD.intDestinationCityId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId		
LEFT JOIN tblSMCountry RY ON RY.intCountryID = IC.intCountryId
LEFT JOIN tblICCommodityAttribute CA ON	CA.intCommodityAttributeId = Item.intOriginId AND CA.strType ='Origin'			
LEFT JOIN tblSMCountry OG ON OG.intCountryID = CA.intCountryID
LEFT JOIN tblLGContainerType ContainerType ON ContainerType.intContainerTypeId=CD.intContainerTypeId 	
LEFT JOIN tblSMCompanyLocationSubLocation SB ON SB.intCompanyLocationSubLocationId = CD.intSubLocationId
LEFT JOIN tblICStorageLocation SLoc ON SLoc.intStorageLocationId = CD.intStorageLocationId
LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CSeq.intContractStatusId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CD.intFreightTermId
LEFT JOIN tblSMShipVia SV ON SV.[intEntityShipViaId] = CD.intShipViaId
LEFT JOIN tblEMEntity SL ON SL.intEntityId = CD.intShippingLineId
LEFT JOIN tblEMEntity Shp ON Shp.intEntityId = CD.intShipperId
LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = Item.intProductTypeId
LEFT JOIN tblCTBook Book ON Book.intBookId = CSeq.intBookId
LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = CSeq.intSubBookId
LEFT JOIN tblCTContractCertification CC ON CC.intContractDetailId = CSeq.intContractDetailId
LEFT JOIN tblICCertification Certification ON Certification.intCertificationId = CC.intCertificationId
LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = CSeq.intNetWeightUOMId
LEFT JOIN tblICUnitMeasure U7 ON U7.intUnitMeasureId = WU.intUnitMeasureId
LEFT JOIN tblICUnitMeasure U8 ON 1 = 1 AND U8.strUnitMeasure = 'Metric Ton'
LEFT JOIN (
		SELECT intPContractDetailId,SUM(LD.dblQuantity) dblQuantity FROM tblLGLoad LO
		JOIN tblLGLoadDetail LD ON LO.intLoadId = LD.intLoadId
		WHERE LO.intShipmentType = 2
		GROUP BY intPContractDetailId
) LG ON LG.intPContractDetailId = CD.intContractDetailId