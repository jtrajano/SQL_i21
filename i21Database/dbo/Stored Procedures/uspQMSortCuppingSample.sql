CREATE PROCEDURE uspQMSortCuppingSample
	@strSampleIds	NVARCHAR(MAX)
AS

IF OBJECT_ID('tempdb..#SESSIONRANKING') IS NOT NULL DROP TABLE #SESSIONRANKING
IF OBJECT_ID('tempdb..#SAMPLES') IS NOT NULL DROP TABLE #SAMPLES
IF OBJECT_ID('tempdb..#FINALRANKING') IS NOT NULL DROP TABLE #FINALRANKING

--GET RANKING
SELECT intId				= ROW_NUMBER() OVER (ORDER BY PG.intSortId ASC, PD.intSortId ASC)
	 , intSortHeaderId		= PG.intSortId
	 , intSortDetailId		= PD.intSortId
	 , intProductTypeId		= PD.intProductTypeId	
	 , strProductType		= PT.strDescription
	 , intOriginId			= PD.intOriginId
	 , strOrigin			= O.strDescription
	 , intExtensionId		= PD.intExtensionId
	 , strExtension			= E.strDescription
	 , intItemId			= PD.intItemId
	 , strItemNo			= I.strItemNo
INTO #SESSIONRANKING
FROM tblQMPriorityGroup PG
INNER JOIN tblQMPriorityGroupDetail PD ON PG.intPriorityGroupId = PD.intPriorityGroupId
LEFT JOIN tblICItem I ON PD.intItemId = I.intItemId
LEFT JOIN tblICCommodityAttribute PT ON PD.intProductTypeId = PT.intCommodityAttributeId AND PT.strType = 'ProductType'
LEFT JOIN tblICCommodityAttribute O ON PD.intOriginId = O.intCommodityAttributeId AND O.strType = 'Origin'
LEFT JOIN tblICCommodityAttribute E ON PD.intExtensionId = E.intCommodityAttributeId

--GET SAMPLE DETAILS
SELECT intSampleId			= S.intSampleId
	 , intProductTypeId		= I.intProductTypeId	
	 , strProductType		= PT.strDescription
	 , intOriginId			= I.intOriginId
	 , strOrigin			= O.strDescription
	 , intExtensionId		= I.intProductLineId
	 , strExtension			= EX.strDescription
	 , intItemId			= S.intItemId
	 , strItemNo			= I.strItemNo 
	 , strStatus 			= STAT.strStatus
	 , strSampleNumber		= S.strSampleNumber
	 , strSampleTypeName	= ST.strSampleTypeName
	 , strEntity			= E.strName
	 , strContractType		= CT.strContractType
	 , strContractNumber	= CH.strContractNumber
	 , intContractSequence	= CD.intContractSeq
	 , strLotNumber			= L.strLotNumber
	 , dblQuantity			= S.dblRepresentingQty
	 , strPacking			= UM.strUnitMeasure
	 , strMethodology		= SC.strSamplingCriteria
	 , intSampleTypeId		= S.intSampleTypeId
	 , intContractHeaderId	= S.intContractHeaderId
	 , intContractDetailId	= S.intContractDetailId
	 , intLotId				= L.intLotId
INTO #SAMPLES
FROM tblQMSample S
INNER JOIN fnGetRowsFromDelimitedValues(@strSampleIds) V ON S.intSampleId = V.intID
INNER JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
LEFT JOIN tblQMSampleStatus STAT ON S.intSampleStatusId = STAT.intSampleStatusId
LEFT JOIN tblICItem I ON S.intItemId = I.intItemId
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

--RANK ACCORDING TO SORT
SELECT S.intItemId
	 , S.intSampleId
	 , intId = ISNULL(R.intId, ROW_NUMBER() OVER (ORDER BY S.intSampleId ASC))
	 , S.strItemNo
INTO #FINALRANKING
FROM #SAMPLES S
LEFT JOIN #SESSIONRANKING R ON ((R.intItemId IS NOT NULL AND S.intItemId = R.intItemId) OR R.intItemId IS NULL) 
						   AND ((R.strProductType IS NOT NULL AND S.strProductType = R.strProductType) OR R.strProductType IS NULL)
						   AND ((R.strOrigin IS NOT NULL AND S.strOrigin = R.strOrigin) OR R.strOrigin IS NULL)
						   AND ((R.strExtension IS NOT NULL AND S.strExtension = R.strExtension) OR R.strExtension IS NULL)
ORDER BY ISNULL(R.intId, 99)

SELECT intRank				= ROW_NUMBER() OVER (ORDER BY FR.intId ASC)
	 , strSampleNumber		= S.strSampleNumber	 
	 , strSampleTypeName	= S.strSampleTypeName
	 , strMethodology		= S.strMethodology
	 , strProductType		= S.strProductType
	 , strOrigin			= S.strOrigin
	 , strExtension			= S.strExtension
	 , strItemNo			= S.strItemNo
	 , strEntity			= S.strEntity
	 , strContractType		= S.strContractType
	 , strContractNumber	= S.strContractNumber
	 , intContractSequence	= S.intContractSequence
	 , strLotNumber			= S.strLotNumber
	 , dblQuantity			= S.dblQuantity	 
	 , strPacking			= S.strPacking
     , intSampleId          = S.intSampleId
	 , intSampleTypeId		= S.intSampleTypeId
	 , intItemId			= S.intItemId
	 , intContractHeaderId	= S.intContractHeaderId
	 , intContractDetailId	= S.intContractDetailId
	 , intLotId				= S.intLotId
	 , strStatus			= S.strStatus
FROM (
	SELECT intSampleId
		 , intId		= MIN(intId)
	FROM #FINALRANKING
	GROUP BY intSampleId	
) FR
INNER JOIN #SAMPLES S ON FR.intSampleId = S.intSampleId
ORDER BY FR.intId