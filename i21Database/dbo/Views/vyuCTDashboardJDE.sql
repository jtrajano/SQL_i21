CREATE VIEW [dbo].[vyuCTDashboardJDE]
AS
SELECT 	 SQ.intContractDetailId			
		,SQ.strContractNumber				
		,SQ.intContractSeq					
		,SQ.strEntityName						AS strSupplier
		,PR.strName								AS strProducer
		,SQ.dtmStartDate					
		,SQ.dtmEndDate						
		,CD.strLoadingPointType				
		,LP.strCity								AS strLoadingPoint
		,CD.strDestinationPointType			
		,DP.strCity								AS strDestinationPoint
		,DC.strCity								AS strDestinationCity
		,CD.strShippingTerm					
		,ES.strName								AS strShippingLine
		,CD.strVessel						
		,EP.strName								AS strShipper
		,SB.strSubLocationName				
		,SL.strName								AS strStorageLocationName
		,SQ.dblQuantity					
		,SQ.strItemUOM						
		,SQ.dblNetWeight					
		,dbo.fnCTConvertQuantityToTargetItemUOM(SQ.intItemId, U7.intUnitMeasureId, U8.intUnitMeasureId, SQ.dblNetWeight)	 	[NetWeight-MT]
		,SQ.strNetWeightUOM				
		,CD.strFixationBy					
		,SQ.strPricingType					
		,SQ.strCurrency					
		,SQ.strFutMarketName				
		,SQ.strFutureMonth					
		,SQ.dblFutures						
		,SQ.dblBasis						
		,SQ.dblCashPrice					
		,CD.dblTotalCost						
		,ISNULL(RY.strCountry, OG.strCountry)	AS strOrigin
		,PG.strName								AS strPurchasingGroup
		,CT.strContainerType		
		,CD.intNumberOfContainers			
		,SQ.strItemNo						
		,PT.strDescription						AS strProductType
		,CS.strContractStatus				
		,(SQ.dblQuantity - SQ.dblBalance)		AS dblQtyShortClosed
		,FT.strFreightTerm					
		,SV.strShipVia						
		,BK.strBook						
		,SK.strSubBook					
		,CD.strInvoiceNo						
		,CF.strCertificationName	
		,CH.intContractHeaderId				
		,ISNULL(CD.dblScheduleQty, 0)			AS dblScheduleQty
		,CASE 	WHEN ISNULL(CD.ysnInvoice, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		AS ysnInvoice
		,CASE 	WHEN ISNULL(CD.ysnProvisionalInvoice, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		AS ysnProvisionalInvoice
		,CASE 	WHEN ISNULL(CD.ysnQuantityFinal, 0) = 0 
						THEN 'N'
						ELSE 'Y' 
				END		AS ysnQuantityFinal
		,CH.strInternalComment
		,LG.dblQuantity							AS dblShippingInsQty
		,CASE 	WHEN ISNULL(CD.ysnRiskToProducer, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		AS ysnRiskToProducer
		,CASE 	WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		AS ysnClaimsToProducer

		,CD.strERPPONumber
		,CD.strERPItemNumber
		,CD.strERPBatchNumber
		,CD.strGarden
		,CH.strCustomerContract
		,CB.strContractBasis
		,CD.dtmPlannedAvailabilityDate
		,SQ.strCommodityCode
		,QA.strSampleStatus
		,QA.dblApprovedQty
		
		,LV.strLoadNumber
		,LV.strLoadShippingLine
		,LV.strOriginPort
		,LV.strDestinationPort
		,LV.strMVessel
		,LV.strMVoyageNumber
		,LV.strFVessel
		,LV.strFVoyageNumber
		,LV.strBLNumber
		,LV.dblLoadQuantity
		,LV.intShipmentType
		,LV.strContainerNumber
		,LV.dtmStuffingDate
		,LV.dtmETSPOL
		,LV.dtmETAPOL
		,LV.dtmETAPOD
		,CASE 	WHEN ISNULL(LV.ysnDocsReceived, 0) = 0 	
				THEN 'N'
				ELSE 'Y' 
		 END	AS ysnDocsReceived
		,CD.strVendorLotID
		,SQ.strContractItemName
		,SQ.strContractItemNo
		,CASE 	WHEN CD.dblBalance <> CD.dblQuantity	
				THEN 'Y'
				ELSE 'N' 
		 END	AS ysnQtyReceived
		,SQ.dblAppliedQty
		,CD.strRemark

	FROM 		vyuCTContractSequence			 	SQ			
	JOIN 		tblCTContractDetail				 	CD	ON	CD.intContractDetailId				=	SQ.intContractDetailId
	JOIN 		tblCTContractHeader				 	CH	ON	CH.intContractHeaderId				=	SQ.intContractHeaderId
	LEFT JOIN	tblCTContractBasis					CB	ON	CB.intContractBasisId				=	CH.intContractBasisId
	LEFT JOIN	tblICItem						 	IM	ON	IM.intItemId						=	SQ.intItemId
	LEFT JOIN 	tblEMEntity						 	PR	ON	PR.intEntityId						=	CH.intProducerId
	LEFT JOIN 	tblSMCity						 	LP	ON	LP.intCityId						=	CD.intLoadingPortId
	LEFT JOIN 	tblSMCity						 	DP	ON	DP.intCityId						=	CD.intDestinationPortId
	LEFT JOIN 	tblSMCity						 	DC	ON	DC.intCityId						=	CD.intDestinationCityId
	LEFT JOIN 	tblICItemContract				 	IC	ON	IC.intItemContractId				=	CD.intItemContractId
	LEFT JOIN 	tblSMCountry					 	RY	ON	RY.intCountryID						=	IC.intCountryId
	LEFT JOIN 	tblICCommodityAttribute			 	CA	ON	CA.intCommodityAttributeId			=	IM.intOriginId
														AND	CA.strType							=	'Origin'
	LEFT JOIN 	tblSMCountry					 	OG	ON	OG.intCountryID						=	CA.intCountryID
	LEFT JOIN 	tblLGContainerType				 	CT	ON	CT.intContainerTypeId				=	CD.intContainerTypeId
	LEFT JOIN 	tblSMCompanyLocationSubLocation	 	SB	ON	SB.intCompanyLocationSubLocationId	=	CD.intSubLocationId
	LEFT JOIN 	tblICStorageLocation			 	SL	ON	SL.intStorageLocationId				=	CD.intStorageLocationId
	LEFT JOIN 	tblCTContractStatus				 	CS	ON	CS.intContractStatusId				=	SQ.intContractStatusId
	LEFT JOIN 	tblSMFreightTerms				 	FT	ON	FT.intFreightTermId					=	CD.intFreightTermId
	LEFT JOIN 	tblSMShipVia					 	SV	ON	SV.[intEntityShipViaId]				=	CD.intShipViaId
	LEFT JOIN 	tblEMEntity						 	ES	ON	ES.intEntityId						=	CD.intShippingLineId
	LEFT JOIN 	tblEMEntity						 	EP	ON	EP.intEntityId						=	CD.intShipperId
	LEFT JOIN 	tblSMPurchasingGroup			 	PG	ON	PG.intPurchasingGroupId				=	CD.intPurchasingGroupId
	LEFT JOIN 	tblICCommodityAttribute			 	PT	ON	PT.intCommodityAttributeId			=	IM.intProductTypeId
	LEFT JOIN 	tblCTBook						 	BK	ON	BK.intBookId						=	SQ.intBookId
	LEFT JOIN 	tblCTSubBook					 	SK	ON	SK.intSubBookId						=	SQ.intSubBookId
	LEFT JOIN 	tblCTContractCertification		 	CC	ON	CC.intContractDetailId				=	SQ.intContractDetailId
	LEFT JOIN 	tblICCertification				 	CF	ON	CF.intCertificationId				=	CC.intCertificationId
	LEFT JOIN 	tblICItemUOM					 	WU	ON	WU.intItemUOMId						=	SQ.intNetWeightUOMId
	LEFT JOIN 	tblICUnitMeasure				 	U7	ON	U7.intUnitMeasureId					=	WU.intUnitMeasureId
	LEFT JOIN 	tblICUnitMeasure				 	U8	ON	1 = 1
														AND U8.strUnitMeasure					=	'Ton'
	LEFT JOIN 	
	(
		SELECT 	intPContractDetailId,
				SUM(LD.dblQuantity)	 dblQuantity
		FROM 	tblLGLoad		 	LO	
		JOIN 	tblLGLoadDetail	 	LD	 ON LO.intLoadId = LD.intLoadId
		WHERE	LO.intShipmentType = 2
		GROUP BY intPContractDetailId
	)										 		LG	ON	LG.intPContractDetailId				=	CD.intContractDetailId
	LEFT JOIN	vyuCTLoadView						LV	ON	LV.intContractDetailId				=	CD.intContractDetailId
	OUTER APPLY dbo.fnCTGetSampleDetail(CD.intContractDetailId)	QA