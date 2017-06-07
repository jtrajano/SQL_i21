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
	,IM.intOriginId
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
FROM tblCTContractDetail CD
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
LEFT JOIN tblSMCountry CG ON CG.intCountryID = IC.intCountryId
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
		) t
	WHERE intRowNum = 1
	) S ON S.intContractDetailId = CD.intContractDetailId
