CREATE VIEW vyuQMContractDetail
AS
SELECT CD.intContractDetailId
	,CD.intContractSeq
	,CD.dblQuantity AS dblDetailQuantity
	,CD.intItemId
	,CD.intItemContractId
	,CH.intContractHeaderId
	,CH.strContractNumber
	,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strSequenceNumber
	,CH.intEntityId
	,E.strName AS strPartyName
	,CH.strCustomerContract
	,CAST(CASE 
			WHEN IM.strType = 'Bundle'
				THEN 1
			ELSE 0
			END AS BIT) AS ysnBundleItem
	,U1.strUnitMeasure AS strItemUOM
	,IU.intUnitMeasureId
	,IM.strItemNo
	,IM.strDescription AS strItemDescription
	,CA.intCountryID AS intOriginId
	,CA.strDescription AS strItemOrigin
	,IC.strContractItemName
	,IC.intCountryId AS intItemContractOriginId
	,CG.strCountry AS strItemContractOrigin
	,S.strSampleStatus
	,S.strSampleNumber
	,S.strContainerNumber
	,S.strSampleTypeName
	,ISNULL(S.ysnFinalApproval, 'false') AS ysnFinalApproval
	,CD.intContractStatusId
	,ISNULL(CD.strERPPONumber, '') AS strERPPONumber
	,CH.intContractTypeId
	,CD.strItemSpecification
	,ISNULL(CH.ysnBrokerage, 'false') AS ysnBrokerage
	,CH.strCPContract
	,E1.strName AS strCounterPartyName
	,CD.intBookId
	,B.strBook
	,CD.intSubBookId
	,SB.strSubBook
	,CD.intItemBundleId
	,IB.strItemNo AS strBundleItemNo
	,CH.dblQuantity AS dblHeaderQuantity
	,U2.strUnitMeasure AS strHeaderUnitMeasure
FROM tblCTContractDetail CD
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = CH.intCounterPartyId
LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure CM ON CM.intCommodityUnitMeasureId = CH.intCommodityUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = CM.intUnitMeasureId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
LEFT JOIN tblICItem IB ON IB.intItemId = CD.intItemBundleId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
LEFT JOIN tblSMCountry CG ON CG.intCountryID = IC.intCountryId
LEFT JOIN tblCTBook B ON B.intBookId = CD.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT ROW_NUMBER() OVER (
				PARTITION BY S.intContractDetailId ORDER BY S.intSampleId DESC
				) intRowNum
			,S.intContractDetailId
			,S.strSampleNumber
			,S.strContainerNumber
			,ST.strSampleTypeName
			,ST.ysnFinalApproval
			,SS.strStatus AS strSampleStatus
		FROM tblQMSample S
		JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
		JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
		WHERE S.intContractDetailId IS NOT NULL
		AND S.intTypeId = 1
		) t
	WHERE intRowNum = 1
	) S ON S.intContractDetailId = CD.intContractDetailId
