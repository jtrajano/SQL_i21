﻿CREATE VIEW vyuQMSampleContractAlert
AS
SELECT t.*
	,EV.intEventId
FROM (
	SELECT *
	FROM (
		SELECT DISTINCT S.intSampleId
			,ROW_NUMBER() OVER (
				PARTITION BY CD.intContractDetailId
				,ST.intSampleTypeId ORDER BY S.intSampleId DESC
				) intRowNum
			,S.strSampleNumber
			,ST.strSampleTypeName
			,SS.strStatus
			,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractNumber
			,0.0 AS dblQuantity
			,0.0 AS dblApprovedQty
			,I.strItemNo
			,I.strDescription
			,CD.strERPPONumber
			,MIN(TR.dtmPropertyValueCreated) AS dtmDate
			,E.strName AS strEntity
			,CH.strCustomerContract AS strEntityContract
			,C.strCountry AS strItemOrigin
			,CA1.strDescription AS strItemProductType
			,S.intSampleStatusId
			,CD.intContractDetailId
			,CD.intContractHeaderId
		FROM tblQMSample S
		JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
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
			,CD.intContractDetailId
			,ST.intSampleTypeId
			,S.intSampleStatusId
			,CD.intContractHeaderId
		) a
	WHERE a.intRowNum = 1
		AND a.intSampleStatusId <> 3
		AND a.intSampleStatusId <> 4
	) t
	inner join tblCTEvent EV on 1=1
WHERE EV.strEventName = 'Unapproved Contract Samples'
	AND t.dtmDate < (GETDATE() - EV.intDaysToRemind)
