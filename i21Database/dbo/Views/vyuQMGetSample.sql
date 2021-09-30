CREATE VIEW vyuQMGetSample
AS
SELECT SPS.intSamplePreStageId AS TrxSequenceNo
	,intRecordStatus AS RecordStatus
	,CASE SPS.strRowState
		WHEN 'Added'
			THEN 1
		WHEN 'Modified'
			THEN 2
		WHEN 'Delete'
			THEN 4
		ELSE 2
		END AS ActionId
	,S.strSampleNumber AS SampleNo
	,ST.strSampleTypeName AS SampleType
	,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS ContractNo
	,VE.strVendorAccountNum AS PartyAccountNo
	,E.strName AS PartyName
	,I.strItemNo AS ItemNo
	,I.strDescription AS ItemDescription
	,S.strContainerNumber AS ContainerNo
	,S.strMarks AS Marks
	,S.strLotNumber AS MotherLotNo
	,CONVERT(NUMERIC(18, 0), ISNULL(dblRepresentingQty, 0)) AS Qty
	,CONVERT(VARCHAR, CD.dtmStartDate, 112) AS ContractDeliveryMonth
	,CONVERT(VARCHAR, S.dtmSampleReceivedDate, 112) AS SampleReceivedDate
	,S.dtmCreated AS CreatedDateTime
	,CE.strName AS CreatedBy
	,C.strCountry AS Origin
	,CD.strGrade AS Grade
	,CLSL.strSubLocationName AS StorageLocation
FROM dbo.tblQMSamplePreStage SPS
JOIN dbo.tblQMSampleType ST ON ST.intSampleTypeId = SPS.intSampleTypeId
JOIN dbo.tblICItem I ON I.intItemId = SPS.intItemId
JOIN tblICCommodity COM ON COM.intCommodityId = I.intCommodityId
	AND COM.strCommodityCode = 'Coffee'
LEFT JOIN dbo.tblSMCountry C ON C.intCountryID = SPS.intCountryID
JOIN dbo.tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = SPS.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblQMSample S ON S.intSampleId = SPS.intSampleId
LEFT JOIN dbo.tblCTContractDetail AS CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = S.intEntityId
LEFT JOIN dbo.tblAPVendor VE ON VE.intEntityId = S.intEntityId
LEFT JOIN dbo.tblEMEntity CE ON CE.intEntityId = S.intCreatedUserId
