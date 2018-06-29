CREATE VIEW vyuQMCuppingReport
AS
SELECT S.intSampleId
	,S.strSampleNumber
	,I.strItemNo
	,I.strShortName
	,I.strDescription
	,E.strName AS strEntityName
	,E.strEntityNo AS strEntityNumber
	,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractNumber
	,IC.strContractItemName
	,S.strMarks
	,S.strContainerNumber
	,SL.strSubLocationDescription
	,Result_cup.strPropertyValue AS strOverallCupAnalysis
	,Result_humidity.strPropertyValue AS strHumidity
	,Result_bulk.strPropertyValue AS strBulkDensity
	,SS.strStatus
	,S.dtmTestedOn
	,S.strSampleNote
	,ST.strSampleTypeName
	,S.intLocationId
	,CD.dtmStartDate
	,CD.dtmEndDate
	,CD.intContractDetailId
	,CD.intContractHeaderId
	,S.intLoadDetailContainerLinkId
	,(
		SELECT strShipperCode
		FROM dbo.fnQMGetShipperName(S.strMarks)
		) AS strShipperCode
	,(
		SELECT strShipperName
		FROM dbo.fnQMGetShipperName(S.strMarks)
		) AS strShipperName
FROM dbo.tblQMSample AS S
JOIN dbo.tblICItem AS I ON I.intItemId = S.intItemId
JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
JOIN dbo.tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
LEFT JOIN dbo.tblEMEntity AS E ON E.intEntityId = S.intEntityId
LEFT JOIN dbo.tblCTContractDetail AS CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN dbo.tblCTContractHeader AS CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN dbo.tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation AS SL ON SL.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblQMReportCuppingPropertyMapping AS Property_cup_map ON UPPER(Property_cup_map.strPropertyName) = 'OVERALL CUP ANALYSIS'
LEFT JOIN dbo.tblQMProperty AS Property_cup ON UPPER(Property_cup.strPropertyName) = UPPER(Property_cup_map.strActualPropertyName)
LEFT JOIN dbo.tblQMTestResult AS Result_cup ON Result_cup.intSampleId = S.intSampleId
	AND Result_cup.intPropertyId = Property_cup.intPropertyId
LEFT JOIN dbo.tblQMReportCuppingPropertyMapping AS Property_humidity_map ON UPPER(Property_humidity_map.strPropertyName) = 'HUMIDITY'
LEFT JOIN dbo.tblQMProperty AS Property_humidity ON UPPER(Property_humidity.strPropertyName) = UPPER(Property_humidity_map.strActualPropertyName)
LEFT JOIN dbo.tblQMTestResult AS Result_humidity ON Result_humidity.intSampleId = S.intSampleId
	AND Result_humidity.intPropertyId = Property_humidity.intPropertyId
LEFT JOIN dbo.tblQMReportCuppingPropertyMapping AS Property_bulk_map ON UPPER(Property_bulk_map.strPropertyName) = 'Bulk Density'
LEFT JOIN dbo.tblQMProperty AS Property_bulk ON UPPER(Property_bulk.strPropertyName) = UPPER(Property_bulk_map.strActualPropertyName)
LEFT JOIN dbo.tblQMTestResult AS Result_bulk ON Result_bulk.intSampleId = S.intSampleId
	AND Result_bulk.intPropertyId = Property_bulk.intPropertyId
