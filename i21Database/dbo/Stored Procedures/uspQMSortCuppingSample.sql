CREATE PROCEDURE uspQMSortCuppingSample
	@strSampleIds	NVARCHAR(MAX)
AS

SELECT intRank				= ROW_NUMBER() OVER (ORDER BY intSampleId)     
	 , strSampleNumber		= S.strSampleNumber	 
	 , strSampleTypeName	= ST.strSampleTypeName
	 , strMethodology		= ''
	 , strProductType		= PT.strDescription
	 , strOrigin			= O.strDescription
	 , strExtension			= EX.strAttribute1
	 , strItemNo			= I.strItemNo + ' - ' + I.strDescription
	 , strEntity			= E.strName
	 , strContractType		= CT.strContractType
	 , strContractNumber	= CH.strContractNumber
	 , intContractSequence	= CD.intContractSeq
	 , strLotNumber			= L.strLotNumber
	 , dblQuantity			= S.dblSampleQty	 
	 , strPacking			= ''
     , intSampleId          = S.intSampleId
	 , intSampleTypeId		= S.intSampleTypeId
	 , intItemId			= S.intItemId
	 , intContractHeaderId	= S.intContractHeaderId
	 , intContractDetailId	= S.intContractDetailId
	 , intLotId				= L.intLotId
FROM tblQMSample S
INNER JOIN fnGetRowsFromDelimitedValues(@strSampleIds) V ON S.intSampleId = V.intID
INNER JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
LEFT JOIN tblICItem I ON S.intItemId = I.intItemId
LEFT JOIN tblICCommodityAttribute PT ON I.intProductTypeId = PT.intCommodityAttributeId AND PT.strType = 'ProductType'
LEFT JOIN tblICCommodityAttribute O ON I.intOriginId = O.intCommodityAttributeId AND O.strType = 'Origin'
LEFT JOIN tblICCommodityAttribute1 EX ON I.intCommodityAttributeId1 = EX.intCommodityAttributeId1
LEFT JOIN tblCTContractDetail CD ON S.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
LEFT JOIN tblICLot L ON L.intLotId = S.intProductValueId AND S.intProductTypeId = 6
LEFT JOIN tblEMEntity E ON S.intEntityId = E.intEntityId