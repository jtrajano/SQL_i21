CREATE PROCEDURE uspQMGetLineQuality @strStart NVARCHAR(10) = '0'
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
	DECLARE @ysnShowSampleFromAllLocation BIT

	SELECT @ysnShowSampleFromAllLocation = ISNULL(ysnShowSampleFromAllLocation, 0)
	FROM tblQMCompanyPreference

	SET @SQL = 'SELECT @PropList = Stuff((  
    SELECT ''],['' + strPropertyName  
    FROM (  
     SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName
	   FROM tblMFWorkOrder W
	   JOIN tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
	   JOIN tblICItem AS I ON I.intItemId = W.intItemId  
	   JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
	   JOIN tblQMSample AS S ON S.intWorkOrderId = W.intWorkOrderId
			AND S.intProductTypeId = 12
			AND S.intProductValueId = W.intWorkOrderId'

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
	IF OBJECT_ID('tempdb.dbo.#LineQuality') IS NOT NULL
		DROP TABLE #LineQuality

	SET @SQL = 'SELECT *
	INTO #LineQuality
	FROM (				
		SELECT DENSE_RANK() OVER (
				ORDER BY S.intSampleId DESC
				) intRankNo  
		   ,C.strCategoryCode
		   ,I.intItemId
		   ,I.strItemNo  
		   ,I.strDescription  
		   ,W.intWorkOrderId
		   ,W.strWorkOrderNo
		   ,WS.strName AS strWorkOrderStatus
		   ,S.strSampleNumber
		   ,SS.strSecondaryStatus AS strSampleStatus
		   ,ST.strSampleTypeName  
		   ,S.intSampleId  
		   ,S.dtmSampleReceivedDate
		   ,S.strComment
		   ,COUNT(*) OVER () AS intTotalCount
		FROM tblMFWorkOrder W
		JOIN tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
		JOIN tblICItem AS I ON I.intItemId = W.intItemId  
		JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
		JOIN tblQMSample AS S ON S.intWorkOrderId = W.intWorkOrderId
			AND S.intProductTypeId = 12
			AND S.intProductValueId = W.intWorkOrderId'

	IF @ysnShowSampleFromAllLocation = 0
	BEGIN
		SET @SQL = @SQL + ' AND S.intLocationId =' + @strLocationId
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  '

	IF (@strUserRoleID <> '0')
	BEGIN
		SET @SQL = @SQL + ' JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId AND SU.intUserRoleID =' + @strUserRoleID
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId'

	IF (LEN(@strFilterCriteria) > 0)
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strItemNo]', 'I.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strDescription]', 'I.strDescription')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strWorkOrderStatus]', 'WS.strName')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strSampleStatus]', 'SS.strSecondaryStatus')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strComment]', 'S.strComment')
		SET @SQL = @SQL + ' WHERE ' + @strFilterCriteria
	END

	SET @SQL = @SQL + ') t '
	SET @SQL = @SQL + '	WHERE intRankNo > ' + @strStart + '
			AND intRankNo <= ' + @strStart + '+' + @strLimit
	SET @SQL = @SQL + ' SELECT   
	intTotalCount
	,strCategoryCode  
	,intItemId  
	,strItemNo  
	,strDescription  
	,intWorkOrderId  
	,strWorkOrderNo
	,strWorkOrderStatus
	,strSampleNumber
	,strSampleStatus
	,strSampleTypeName
	,intSampleId
	,dtmSampleReceivedDate
	,strComment
	,' + @str + 'FROM (  
		SELECT intTotalCount
			,strCategoryCode
			,CQ.intItemId
			,strItemNo  
			,CQ.strDescription  
			,CQ.intWorkOrderId
			,strWorkOrderNo
			,strWorkOrderStatus
			,strSampleNumber
			,strSampleStatus
			,strSampleTypeName  
			,CQ.intSampleId  
			,dtmSampleReceivedDate
			,CQ.strComment
			,P.strPropertyName + '' - '' + T.strTestName AS strPropertyName
			,TR.strPropertyValue
		FROM #LineQuality CQ
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
