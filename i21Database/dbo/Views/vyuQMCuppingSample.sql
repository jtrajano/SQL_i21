CREATE VIEW vyuQMCuppingSample
AS
SELECT intSampleId			= S.intSampleId
	 , strSampleNumber		= S.strSampleNumber
	 , strSampleTypeName	= ST.strSampleTypeName
	 , strMethodology		= '' --TEMP
	 , strProductType		= PT.strDescription
	 , strOrigin			= O.strDescription
	 , strExtension			= EX.strAttribute1
	 , strItemNo			= I.strItemNo
	 , strEntity			= E.strName
	 , strContractType		= CT.strContractType
	 , strContractNumber	= CH.strContractNumber
	 , intContractSequence	= CD.intContractSeq
	 , strLotNumber			= L.strLotNumber
	 , dblQuantity			= S.dblSampleQty
	 , strPacking			= '' --TEMP
	 , strStatus			= STAT.strStatus
FROM tblQMSample S
INNER JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
LEFT JOIN tblQMSampleStatus STAT ON S.intSampleStatusId = STAT.intSampleStatusId
LEFT JOIN tblQMSample TYPE2 ON S.intSampleId = TYPE2.intRelatedSampleId
LEFT JOIN tblICItem I ON S.intItemId = I.intItemId
LEFT JOIN tblICCommodity IC ON I.intCommodityId = IC.intCommodityId
LEFT JOIN tblICCommodityAttribute PT ON I.intProductTypeId = PT.intCommodityAttributeId AND PT.strType = 'ProductType'
LEFT JOIN tblICCommodityAttribute O ON I.intOriginId = O.intCommodityAttributeId AND O.strType = 'Origin'
LEFT JOIN tblICCommodityAttribute1 EX ON I.intCommodityAttributeId1 = EX.intCommodityAttributeId1 --TEMP
LEFT JOIN tblCTContractDetail CD ON S.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
LEFT JOIN tblICLot L ON L.intLotId = S.intProductValueId AND S.intProductTypeId = 6
LEFT JOIN tblEMEntity E ON S.intEntityId = E.intEntityId
WHERE S.intTypeId = 1