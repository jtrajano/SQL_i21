CREATE VIEW vyuQMCuppingSessionDetail
AS
SELECT intCuppingSessionId			= CS.intCuppingSessionId
	 , intCuppingSessionDetailId	= CSD.intCuppingSessionDetailId
	 , strCuppingSessionNumber		= CS.strCuppingSessionNumber
	 , intRank						= CSD.intRank    
	 , strSampleNumber				= S.strSampleNumber
	 , strSessionSampleNumber 		= TYPE2.strSampleNumber	 
	 , strSampleTypeName			= ST.strSampleTypeName
	 , strSessionSampleTypeName		= ST2.strSampleTypeName
	 , strMethodology				= SC.strSamplingCriteria
	 , strProductType				= PT.strDescription
	 , strOrigin					= O.strDescription
	 , strExtension					= EX.strDescription
	 , strItemNo					= I.strItemNo
	 , strDescription				= I.strDescription
	 , strEntity					= E.strName
	 , strContractType				= CT.strContractType
	 , strContractNumber			= CH.strContractNumber
	 , intContractSequence			= CD.intContractSeq
	 , strLotNumber					= L.strLotNumber
	 , dblQuantity					= S.dblRepresentingQty	 
	 , strPacking					= UM.strUnitMeasure
     , intSampleId					= S.intSampleId
	 , intSampleTypeId				= S.intSampleTypeId
	 , intItemId					= S.intItemId
	 , intContractHeaderId			= S.intContractHeaderId
	 , intContractDetailId			= S.intContractDetailId
	 , intLotId						= L.intLotId
     , dtmCuppingDate               = CS.dtmCuppingDate
     , strCuppingTime               = CONVERT(VARCHAR(8), CS.dtmCuppingTime, 8) COLLATE Latin1_General_CI_AS
	 , intConcurrencyId				= CSD.intConcurrencyId
	 , intSampleType2Id				= TYPE2.intSampleId
	 , strStatus 					= STAT.strStatus
	 , strSessionStatus 			= STAT2.strStatus
	 , intSamplingCriteriaId		= S.intSamplingCriteriaId
	 , intRepresentingUOMId			= S.intRepresentingUOMId
FROM tblQMCuppingSession CS
INNER JOIN tblQMCuppingSessionDetail CSD ON CS.intCuppingSessionId = CSD.intCuppingSessionId
INNER JOIN tblQMSample S ON CSD.intSampleId = S.intSampleId
INNER JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
LEFT JOIN tblQMSampleStatus STAT ON S.intSampleStatusId = STAT.intSampleStatusId
LEFT JOIN tblQMSample TYPE2 ON S.intSampleId = TYPE2.intParentSampleId AND CSD.intCuppingSessionDetailId = TYPE2.intCuppingSessionDetailId
LEFT JOIN tblQMSampleType ST2 ON TYPE2.intSampleTypeId = ST2.intSampleTypeId
LEFT JOIN tblQMSampleStatus STAT2 ON TYPE2.intSampleStatusId = STAT2.intSampleStatusId
LEFT JOIN tblICItem I ON S.intItemId = I.intItemId
LEFT JOIN tblICCommodity IC ON I.intCommodityId = IC.intCommodityId
LEFT JOIN tblICCommodityAttribute PT ON I.intProductTypeId = PT.intCommodityAttributeId AND PT.strType = 'ProductType'
LEFT JOIN tblICCommodityAttribute O ON I.intOriginId = O.intCommodityAttributeId AND O.strType = 'Origin'
LEFT JOIN tblICCommodityProductLine EX ON I.intProductLineId = EX.intCommodityProductLineId
LEFT JOIN tblCTContractDetail CD ON S.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
LEFT JOIN tblICLot L ON L.intLotId = S.intProductValueId AND S.intProductTypeId = 6
LEFT JOIN tblEMEntity E ON S.intEntityId = E.intEntityId
LEFT JOIN tblQMSamplingCriteria SC ON S.intSamplingCriteriaId = SC.intSamplingCriteriaId
LEFT JOIN tblICUnitMeasure UM ON S.intRepresentingUOMId = UM.intUnitMeasureId