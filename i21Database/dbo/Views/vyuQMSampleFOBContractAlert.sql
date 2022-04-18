CREATE VIEW vyuQMSampleFOBContractAlert
AS
SELECT t.*
	,EV.intEventId
FROM (
	SELECT DISTINCT CD.intContractDetailId
		,0 AS intSampleId
		,'' COLLATE Latin1_General_CI_AS AS strSampleNumber
		,'' COLLATE Latin1_General_CI_AS AS strSampleTypeName
		,'' COLLATE Latin1_General_CI_AS AS strStatus
		,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractNumber
		,CD.dblQuantity
		,CASE 
			WHEN (ISNULL(QA.strSampleStatus, 'Rejected') = 'Partially Approved')
				THEN ISNULL(QA.dblApprovedQty, 0)
			ELSE 0
			END AS dblApprovedQty
		,I.strItemNo
		,I.strDescription
		,CD.strERPPONumber
		,MIN(CD.dtmStartDate) AS dtmDate
		,E.strName AS strEntity
		,CH.strCustomerContract AS strEntityContract
		,C.strCountry AS strItemOrigin
		,CA1.strDescription AS strItemProductType
		,CD.intContractHeaderId
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CD.intContractStatusId = 1
	JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
		AND LOWER(CB.strContractBasis) = 'fob'
	JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intGradeId
		AND WG.ysnSample = 1
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
	LEFT JOIN tblQMSample S ON S.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
		AND CA.strType = 'Origin'
	LEFT JOIN tblSMCountry C ON C.intCountryID = CA.intCountryID
	LEFT JOIN tblICCommodityAttribute CA1 ON CA1.intCommodityAttributeId = I.intProductTypeId
		AND CA1.strType = 'ProductType'
	LEFT JOIN vyuCTQualityApprovedRejected QA ON QA.intContractDetailId = CD.intContractDetailId
	WHERE ISNULL(QA.strSampleStatus, 'Rejected') IN (
			'Rejected'
			,'Partially Rejected'
			,'Partially Approved'
			)
		AND S.intTypeId = 1
	GROUP BY CD.intContractDetailId
		,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq)
		,CD.dblQuantity
		,CASE 
			WHEN (ISNULL(QA.strSampleStatus, 'Rejected') = 'Partially Approved')
				THEN ISNULL(QA.dblApprovedQty, 0)
			ELSE 0
			END
		,I.strItemNo
		,I.strDescription
		,CD.strERPPONumber
		,E.strName
		,CH.strCustomerContract
		,C.strCountry
		,CA1.strDescription
		,CD.intContractHeaderId
	) t
	inner join tblCTEvent EV on 1=1
WHERE EV.strEventName = 'Unapproved FOB Contract Samples'
	AND t.dtmDate < (GETDATE() - EV.intDaysToRemind)
