CREATE VIEW vyuQMSampleContractAlert
AS
SELECT t.*
	,EV.intEventId
FROM (
	SELECT DISTINCT S.intSampleId
		,S.strSampleNumber
		,ST.strSampleTypeName
		,SS.strStatus
		,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractNumber
		,I.strItemNo
		,I.strDescription
		,CD.strERPPONumber
		,MIN(TR.dtmPropertyValueCreated) AS dtmDate
		,E.strName AS strEntity
		,CH.strCustomerContract AS strEntityContract
		,C.strCountry AS strItemOrigin
		,CA1.strDescription AS strItemProductType
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		AND S.intSampleStatusId <> 3
	JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
	JOIN tblCTContractDetail AS CD ON CD.intContractDetailId = S.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItem I ON I.intItemId = S.intItemId
	JOIN tblQMTestResult TR ON TR.intSampleId = S.intSampleId
		AND TR.strPropertyValue <> ''
		AND TR.dtmPropertyValueCreated IS NOT NULL
	JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
		AND CA.strType = 'Origin'
	LEFT JOIN tblSMCountry C ON C.intCountryID = CA.intCountryID
	LEFT JOIN tblICCommodityAttribute CA1 ON CA1.intCommodityAttributeId = I.intProductTypeId
		AND CA1.strType = 'ProductType'
	GROUP BY S.intSampleId
		,S.strSampleNumber
		,ST.strSampleTypeName
		,SS.strStatus
		,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq)
		,I.strItemNo
		,I.strDescription
		,CD.strERPPONumber
		,E.strName
		,CH.strCustomerContract
		,C.strCountry
		,CA1.strDescription
	) t
	,tblCTEvent EV
WHERE EV.strEventName = 'Unapproved Contract Samples'
	AND t.dtmDate < (GETDATE() - EV.intDaysToRemind)
