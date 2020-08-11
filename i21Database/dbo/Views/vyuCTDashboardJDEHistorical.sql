CREATE VIEW [dbo].[vyuCTDashboardJDEHistorical]

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
		,dbo.fnCTConvertQuantityToTargetItemUOM(SQ.intItemId, U7.intUnitMeasureId, U8.intUnitMeasureId, SQ.dblNetWeight)	 	[dblNetWeightMT]
		,SQ.strNetWeightUOM				
		,CD.strFixationBy					
		,SQ.strPricingType					
		,SQ.strCurrency					
		,SQ.strFutMarketName				
		,SQ.strFutureMonthYear AS strFutureMonth					
		,SQ.dblFutures						
		,SQ.dblBasis						
		,SQ.dblCashPrice					
		,CD.dblTotalCost						
		,ISNULL(RY.strCountry, OG.strCountry)	AS strOrigin
		,PG.strName	COLLATE Latin1_General_CI_AS AS strPurchasingGroup
		,CT.strContainerType		
		,CD.intNumberOfContainers			
		,SQ.strItemNo				
		,SQ.strItemDescription	
		,IM.strShortName AS strItemShortName
		,PT.strDescription						AS strProductType
		,CS.strContractStatus				
		,(SQ.dblQuantity - SQ.dblBalance)		AS dblQtyShortClosed
		,FT.strFreightTerm					
		,SV.strShipVia						
		,BK.strBook						
		,SK.strSubBook					
		,CD.strInvoiceNo						
		,CD.strCertifications AS strCertificationName	
		,CH.intContractHeaderId				
		,ISNULL(CD.dblScheduleQty, 0)			AS dblScheduleQty
		,CASE 	WHEN ISNULL(CD.ysnInvoice, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnInvoice
		,CASE 	WHEN ISNULL(CD.ysnProvisionalInvoice, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnProvisionalInvoice
		,CASE 	WHEN ISNULL(CD.ysnQuantityFinal, 0) = 0 
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnQuantityFinal
		,CH.strInternalComment
		,LG.dblQuantity							AS dblShippingInsQty
		,CASE 	WHEN ISNULL(CD.ysnRiskToProducer, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnRiskToProducer
		,CASE 	WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnClaimsToProducer

		,CD.strERPPONumber
		,CD.strERPItemNumber
		,CD.strERPBatchNumber
		,CD.strGarden
		,CH.strCustomerContract
		,CB.strContractBasis
		,CD.dtmPlannedAvailabilityDate
		,dtmPlannedAvailabilityDateYM = CD.dtmPlannedAvailabilityDate
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
		,LV.strShipmentType
		,LV.strContainerNumber
		,LV.dtmStuffingDate
		,LV.dtmETSPOL
		,LV.dtmETAPOL
		,LV.dtmETAPOD
		,LV.strBookingReference
		,LV.intLoadId
		,LV.dtmDeadlineCargo
		,LV.strETAPOLReasonCode 
		,LV.strETSPOLReasonCode
		,LV.strETAPODReasonCode
		,LV.strETAPOLReasonCodeDescription
		,LV.strETSPOLReasonCodeDescription
		,LV.strETAPODReasonCodeDescription
		,CASE 	WHEN ISNULL(LV.ysnDocsReceived, 0) = 0 	
				THEN 'N'
				ELSE 'Y' 
		 END	COLLATE Latin1_General_CI_AS AS ysnDocsReceived
		,CD.strVendorLotID
		,SQ.strContractItemName
		,SQ.strContractItemNo
		,IC.strGrade  AS strQualityApproval
		,CASE 	WHEN CD.dblBalance <> CD.dblQuantity	
				THEN 'Y'
				ELSE 'N' 
		 END	COLLATE Latin1_General_CI_AS AS ysnQtyReceived
		,SQ.dblAppliedQty
		,CD.strRemark
		,CH.dtmCreated
		,CD.dtmUpdatedAvailabilityDate
		,SQ.strLocationName
		,CH.dtmContractDate
		,IM.strItemNo AS strBundleItemNo
		,CH.intBookId as intHeaderBookId
		,CH.intSubBookId as intHeaderSubBookId
		,CD.intBookId as intDetailBookId
		,CD.intSubBookId as intDetailSubBookId 

	FROM 		vyuCTContractSequence			 	SQ	WITH (NOLOCK)		
	JOIN 		tblCTContractDetail				 	CD	WITH (NOLOCK) ON	CD.intContractDetailId				=	SQ.intContractDetailId AND SQ.intContractStatusId NOT IN (1,2,4)
	JOIN 		tblCTContractHeader				 	CH	WITH (NOLOCK) ON	CH.intContractHeaderId				=	SQ.intContractHeaderId
	LEFT JOIN	tblCTContractBasis					CB	WITH (NOLOCK) ON	CB.intContractBasisId				=	CH.intContractBasisId
	LEFT JOIN	tblICItem						 	IM	WITH (NOLOCK) ON	IM.intItemId						=	SQ.intItemId
	LEFT JOIN 	tblEMEntity						 	PR	WITH (NOLOCK) ON	PR.intEntityId						=	ISNULL(CD.intProducerId,CH.intProducerId)
	LEFT JOIN 	tblSMCity						 	LP	WITH (NOLOCK) ON	LP.intCityId						=	CD.intLoadingPortId
	LEFT JOIN 	tblSMCity						 	DP	WITH (NOLOCK) ON	DP.intCityId						=	CD.intDestinationPortId
	LEFT JOIN 	tblSMCity						 	DC	WITH (NOLOCK) ON	DC.intCityId						=	CD.intDestinationCityId
	LEFT JOIN 	tblICItemContract				 	IC	WITH (NOLOCK) ON	IC.intItemContractId				=	CD.intItemContractId
	LEFT JOIN 	tblSMCountry					 	RY	WITH (NOLOCK) ON	RY.intCountryID						=	IC.intCountryId
	LEFT JOIN 	tblICCommodityAttribute			 	CA	WITH (NOLOCK) ON	CA.intCommodityAttributeId			=	IM.intOriginId
														AND	CA.strType							=	'Origin'
	LEFT JOIN 	tblSMCountry					 	OG	WITH (NOLOCK) ON	OG.intCountryID						=	CA.intCountryID
	LEFT JOIN 	tblLGContainerType				 	CT	WITH (NOLOCK) ON	CT.intContainerTypeId				=	CD.intContainerTypeId
	LEFT JOIN 	tblSMCompanyLocationSubLocation	 	SB	WITH (NOLOCK) ON	SB.intCompanyLocationSubLocationId	=	CD.intSubLocationId
	LEFT JOIN 	tblICStorageLocation			 	SL	WITH (NOLOCK) ON	SL.intStorageLocationId				=	CD.intStorageLocationId
	LEFT JOIN 	tblCTContractStatus				 	CS	WITH (NOLOCK) ON	CS.intContractStatusId				=	SQ.intContractStatusId
	LEFT JOIN 	tblSMFreightTerms				 	FT	WITH (NOLOCK) ON	FT.intFreightTermId					=	CD.intFreightTermId
	LEFT JOIN 	tblSMShipVia					 	SV	WITH (NOLOCK) ON	SV.intEntityId						=	CD.intShipViaId
	LEFT JOIN 	tblEMEntity						 	ES	WITH (NOLOCK) ON	ES.intEntityId						=	CD.intShippingLineId
	LEFT JOIN 	tblEMEntity						 	EP	WITH (NOLOCK) ON	EP.intEntityId						=	CD.intShipperId
	LEFT JOIN 	tblSMPurchasingGroup			 	PG	WITH (NOLOCK) ON	PG.intPurchasingGroupId				=	CD.intPurchasingGroupId
	LEFT JOIN 	tblICCommodityAttribute			 	PT	WITH (NOLOCK) ON	PT.intCommodityAttributeId			=	IM.intProductTypeId
	LEFT JOIN 	tblCTBook						 	BK	WITH (NOLOCK) ON	BK.intBookId						=	SQ.intBookId
	LEFT JOIN 	tblCTSubBook					 	SK	WITH (NOLOCK) ON	SK.intSubBookId						=	SQ.intSubBookId
	LEFT JOIN 	tblICItemUOM					 	WU	WITH (NOLOCK) ON	WU.intItemUOMId						=	SQ.intNetWeightUOMId
	LEFT JOIN 	tblICUnitMeasure				 	U7	WITH (NOLOCK) ON	U7.intUnitMeasureId					=	WU.intUnitMeasureId
	LEFT JOIN 	tblICUnitMeasure				 	U8	WITH (NOLOCK) ON	1 = 1
														AND U8.strUnitMeasure					=	'Ton'
	LEFT JOIN 	
	(
		SELECT 	intPContractDetailId,
				SUM(LD.dblQuantity)	 dblQuantity
		FROM 	tblLGLoad		 	LO	 WITH (NOLOCK)
		JOIN 	tblLGLoadDetail	 	LD	 WITH (NOLOCK) ON LO.intLoadId = LD.intLoadId
		WHERE	LO.intShipmentType = 2
		GROUP BY intPContractDetailId
	)										 		LG				  ON	LG.intPContractDetailId				=	CD.intContractDetailId
	LEFT JOIN	vyuCTLoadView						LV	WITH (NOLOCK) ON	LV.intContractDetailId				=	CD.intContractDetailId
	LEFT JOIN	vyuCTQualityApprovedRejected		QA	WITH (NOLOCK) ON	QA.intContractDetailId				=	CD.intContractDetailId