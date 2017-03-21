CREATE PROCEDURE uspQMGetContractQuality @strStart NVARCHAR(10) = '0'
	,@strLimit NVARCHAR(10) = '1'
	,@strFilterCriteria NVARCHAR(MAX) = ''
	,@strSortField NVARCHAR(MAX) = 'intSampleId'
	,@strSortDirection NVARCHAR(5) = 'DESC'
	,@strLocationId NVARCHAR(10) = '0'
	,@strUserRoleID NVARCHAR(10) = '0'
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
		,@strColumnsList NVARCHAR(MAX)
	DECLARE @ysnShowSampleFromAllLocation BIT

	SELECT @ysnShowSampleFromAllLocation = ISNULL(ysnShowSampleFromAllLocation, 0)
	FROM tblQMCompanyPreference

	SET @SQL = 'SELECT @PropList = Stuff((  
    SELECT ''],['' + strPropertyName  
    FROM (  
     SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName  
     FROM tblCTContractHeader AS CH  
     JOIN tblEMEntity AS E ON E.intEntityId = CH.intEntityId  
     JOIN tblCTContractDetail AS CD ON CD.intContractHeaderId = CH.intContractHeaderId  
     JOIN tblICItem AS I ON I.intItemId = CD.intItemId  
     JOIN tblQMSample AS S ON S.intContractDetailId = CD.intContractDetailId'

	IF @ysnShowSampleFromAllLocation = 0
	BEGIN
		SET @SQL = @SQL + ' AND S.intLocationId =' + @strLocationId
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  '

	IF (@strUserRoleID <> '0')
	BEGIN
		SET @SQL = @SQL + ' JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId AND SU.intUserRoleID =' + @strUserRoleID
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId  
     JOIN tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId  
     JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId  
     JOIN tblQMTest AS T ON TR.intTestId = T.intTestId
	 LEFT JOIN tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
	 LEFT JOIN tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
	 LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
	 LEFT JOIN tblICItem AS I1 ON I1.intItemId = S.intItemBundleId
	 LEFT JOIN tblEMEntity AS E1 ON E1.intEntityId = S.intShipperEntityId'

	IF (LEN(@strFilterCriteria) > 0)
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strContractNumber]', 'CH.strContractNumber + '' - '' + LTRIM(CD.intContractSeq)')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strName]', 'E.strName')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strBundleItemNo]', 'I1.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strItemNo]', 'I.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strDescription]', 'I.strDescription')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strStatus]', 'SS.strStatus')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strMarks]', 'S.strMarks')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strShipperCode]', 'E1.strEntityNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strShipperName]', 'E1.strName')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strComment]', 'S.strComment')
		SET @SQL = @SQL + ' WHERE ' + @strFilterCriteria
	END

	SET @SQL = @SQL + ') t  
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

	SET @SQL = 
		'SELECT *
	INTO #ContractQuality
	FROM (						
		SELECT DENSE_RANK() OVER (
				ORDER BY S.intSampleId DESC
				) intRankNo
			,CH.strContractNumber + '' - '' + LTRIM(CD.intContractSeq) AS strContractNumber
			,E.strName
			,I1.strItemNo AS strBundleItemNo
			,I.strItemNo
			,I.strDescription
			,S.strContainerNumber
			,S.strSampleNumber
			,ST.strSampleTypeName
			,SS.strStatus
			,S.intSampleId
			,IC.strContractItemName
			,S.strMarks
			,E1.strEntityNo AS strShipperCode
			,E1.strName AS strShipperName
			,CS.strSubLocationName
			,L.strLoadNumber
			,S.dtmSampleReceivedDate
			,S.dtmSamplingEndDate
			,S.strComment
			,COUNT(*) OVER () AS intTotalCount
		FROM tblCTContractHeader AS CH
		JOIN tblEMEntity AS E ON E.intEntityId = CH.intEntityId
		JOIN tblCTContractDetail AS CD ON CD.intContractHeaderId = CH.intContractHeaderId
		JOIN tblICItem AS I ON I.intItemId = CD.intItemId
		JOIN tblQMSample AS S ON S.intContractDetailId = CD.intContractDetailId'

	IF @ysnShowSampleFromAllLocation = 0
	BEGIN
		SET @SQL = @SQL + ' AND S.intLocationId =' + @strLocationId
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId '

	IF (@strUserRoleID <> '0')
	BEGIN
		SET @SQL = @SQL + ' JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId AND SU.intUserRoleID =' + @strUserRoleID
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
		LEFT JOIN tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
		LEFT JOIN tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
		LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
		LEFT JOIN tblICItem AS I1 ON I1.intItemId = S.intItemBundleId
		LEFT JOIN tblEMEntity AS E1 ON E1.intEntityId = S.intShipperEntityId'

	IF (LEN(@strFilterCriteria) > 0)
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strContractNumber]', 'CH.strContractNumber + '' - '' + LTRIM(CD.intContractSeq)')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strName]', 'E.strName')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strBundleItemNo]', 'I1.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strItemNo]', 'I.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strDescription]', 'I.strDescription')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strStatus]', 'SS.strStatus')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strMarks]', 'S.strMarks')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strShipperCode]', 'E1.strEntityNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strShipperName]', 'E1.strName')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strComment]', 'S.strComment')
		SET @SQL = @SQL + ' WHERE ' + @strFilterCriteria
	END

	SET @SQL = @SQL + ') t '
	SET @SQL = @SQL + '	WHERE intRankNo > ' + @strStart + '
			AND intRankNo <= ' + @strStart + '+' + @strLimit
	SET @strColumnsList = 'intTotalCount,strContractNumber,strName,strContractItemName,strBundleItemNo,strItemNo,strDescription'
	SET @strColumnsList = @strColumnsList + ',strLoadNumber,strContainerNumber,strMarks,strShipperCode,strShipperName,strSubLocationName,strSampleNumber,strSampleTypeName'
	SET @strColumnsList = @strColumnsList + ',strStatus,intSampleId,dtmSampleReceivedDate,dtmSamplingEndDate,strComment,' + REPLACE(REPLACE(@str, '[', ''), ']', '')
	SET @SQL = @SQL + ' SELECT   
  intTotalCount
  ,strContractNumber  
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
  ,strComment
  ,' + @str + ',''' + @strColumnsList + ''' AS strColumnsList ' + 
		'FROM (  
	SELECT intTotalCount
		,strContractNumber
		,strName
		,strContractItemName
		,strBundleItemNo
		,strItemNo
		,CQ.strDescription
		,strLoadNumber
		,strContainerNumber
		,strMarks
		,strShipperCode
		,strShipperName
		,strSubLocationName
		,strSampleNumber
		,strSampleTypeName
		,strStatus
		,CQ.intSampleId
		,dtmSampleReceivedDate
		,dtmSamplingEndDate
		,CQ.strComment
		,P.strPropertyName + '' - '' + T.strTestName AS strPropertyName
		,TR.strPropertyValue
	FROM #ContractQuality CQ
	JOIN tblQMTestResult AS TR ON TR.intSampleId = CQ.intSampleId
	JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
	JOIN tblQMTest AS T ON TR.intTestId = T.intTestId
  ) t  
 PIVOT(MAX(strPropertyValue) FOR strPropertyName IN (' + @str + ')) pvt'
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
