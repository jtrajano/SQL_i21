CREATE PROCEDURE uspQMGetContractQuality
	@strStart NVARCHAR(10) = '0'
	,@strLimit NVARCHAR(10) = '1'
	,@strFilterCriteria NVARCHAR(MAX) = ''
	,@strSortField NVARCHAR(MAX) = 'intSampleId'
	,@strSortDirection NVARCHAR(5) = 'DESC'
	,@strLocationId NVARCHAR(10) = '0'
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @str NVARCHAR(MAX)
		,@params NVARCHAR(MAX)
		,@PropList NVARCHAR(MAX)
		,@ErrMsg NVARCHAR(MAX)
		,@SQL NVARCHAR(MAX)

	SET @SQL = 'SELECT @PropList = Stuff((  
    SELECT ''],['' + strPropertyName  
    FROM (  
     SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName  
     FROM dbo.tblCTContractHeader AS CH  
     JOIN dbo.tblEMEntity AS E ON E.intEntityId = CH.intEntityId  
     JOIN dbo.tblCTContractDetail AS CD ON CD.intContractHeaderId = CH.intContractHeaderId  
     JOIN dbo.tblICItem AS I ON I.intItemId = CD.intItemId  
     JOIN dbo.tblQMSample AS S ON S.intContractDetailId = CD.intContractDetailId
		AND S.intLocationId =' + @strLocationId + 
		'
     JOIN dbo.tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  
     JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId  
     JOIN dbo.tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId  
     JOIN dbo.tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId  
     JOIN dbo.tblQMTest AS T ON TR.intTestId = T.intTestId
     ) t  
    ORDER BY ''],['' + strTestName,strPropertyName  
    FOR XML Path('''')  
    ), 1, 2, '''') + '']'''

	SELECT @params = '@PropList nvarchar(max) OUTPUT'

	EXEC sp_executesql @SQL
		,@params
		,@PropList = @str OUTPUT

	--SELECT @str -- Property Names List  
	-- Quality Sample Data
	IF OBJECT_ID('tempdb.dbo.#ContractQuality') IS NOT NULL
		DROP TABLE #ContractQuality

	SELECT DENSE_RANK() OVER (
			ORDER BY S.intSampleId DESC
			) intRankNo
		,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractNumber
		,E.strName
		,I1.strItemNo AS strBundleItemNo
		,I.strItemNo
		,I.strDescription
		,ISNULL(C.strContainerNumber, S.strContainerNumber) AS strContainerNumber
		,S.strSampleNumber
		,ST.strSampleTypeName
		,SS.strStatus
		,P.strPropertyName + ' - ' + T.strTestName AS strPropertyName
		,TR.strPropertyValue
		,S.intSampleId
		,IC.strContractItemName
		,S.strMarks
		,(
			SELECT strShipperCode
			FROM dbo.fnQMGetShipperName(S.strMarks)
			) AS strShipperCode
		,(
			SELECT strShipperName
			FROM dbo.fnQMGetShipperName(S.strMarks)
			) AS strShipperName
		,CS.strSubLocationName
		,L.strLoadNumber
		,S.dtmSampleReceivedDate
		,S.dtmSamplingEndDate
	INTO #ContractQuality
	FROM dbo.tblCTContractHeader AS CH
	JOIN dbo.tblEMEntity AS E ON E.intEntityId = CH.intEntityId
	JOIN dbo.tblCTContractDetail AS CD ON CD.intContractHeaderId = CH.intContractHeaderId
	JOIN dbo.tblICItem AS I ON I.intItemId = CD.intItemId
	JOIN dbo.tblQMSample AS S ON S.intContractDetailId = CD.intContractDetailId
		AND S.intLocationId = @strLocationId
	JOIN dbo.tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
	JOIN dbo.tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId
	JOIN dbo.tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
	JOIN dbo.tblQMTest AS T ON TR.intTestId = T.intTestId
	LEFT JOIN dbo.tblLGLoadContainer AS C ON C.intLoadContainerId = S.intLoadContainerId
	LEFT JOIN dbo.tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
	LEFT JOIN dbo.tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
	LEFT JOIN dbo.tblLGLoad L ON L.intLoadId = S.intLoadId
	LEFT JOIN dbo.tblICItem AS I1 ON I1.intItemId = S.intItemBundleId

	SET @SQL = 'SELECT TOP ' + @strLimit + '   
  strContractNumber  
  ,strName  
  ,strContractItemName
  ,strBundleItemNo
  ,strItemNo  
  ,strDescription  
  ,strLoadNumber
  ,strContainerNumber  
  ,strMarks
  ,strShipperCode
  ,strShipperName
  ,strSubLocationName
  ,strSampleNumber  
  ,strSampleTypeName  
  ,strStatus  
  ,intSampleId  
  ,dtmSampleReceivedDate
  ,dtmSamplingEndDate
  ,(COUNT(*) OVER () + ' + @strStart + ') AS intTotalCount
  ,' + @str + 'FROM (  
	SELECT *
	FROM #ContractQuality
  ) t  
 PIVOT(MAX(strPropertyValue) FOR strPropertyName IN (' + @str + ')) pvt WHERE intRankNo > ' + @strStart

	IF (LEN(@strFilterCriteria) > 0)
		SET @SQL = @SQL + ' and ' + @strFilterCriteria
	SET @SQL = @SQL + ' ORDER BY [' + @strSortField + '] ' + @strSortDirection

	EXEC sp_executesql @SQL
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @ErrMsg != ''
	BEGIN
		RAISERROR (
				@ErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH
