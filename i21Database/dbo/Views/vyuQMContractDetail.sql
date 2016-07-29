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
FROM tblCTContractDetail CD
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
LEFT JOIN tblSMCountry CG ON CG.intCountryID = IC.intCountryId
