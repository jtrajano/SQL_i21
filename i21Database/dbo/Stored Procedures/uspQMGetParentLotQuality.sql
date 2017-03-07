CREATE PROCEDURE uspQMGetParentLotQuality @strStart NVARCHAR(10) = '0'
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
		FROM tblICParentLot AS PL
		JOIN tblICLot AS L ON L.intParentLotId = PL.intParentLotId 
		JOIN tblICItem AS I ON I.intItemId = L.intItemId  
		JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
		JOIN tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
		JOIN tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblQMSample S ON S.intProductValueId = L.intParentLotId
			AND S.intProductTypeId = 11'

	IF @ysnShowSampleFromAllLocation = 0
	BEGIN
		SET @SQL = @SQL + ' AND S.intLocationId =' + @strLocationId
	END

	IF (@strUserRoleID <> '0')
	BEGIN
		SET @SQL = @SQL + ' JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId AND SU.intUserRoleID =' + @strUserRoleID
	END

	SET @SQL = @SQL + ' JOIN tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId
		JOIN tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
		JOIN tblQMTest AS T ON T.intTestId = TR.intTestId
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
	IF OBJECT_ID('tempdb.dbo.#ParentLotQuality') IS NOT NULL
		DROP TABLE #ParentLotQuality

	SET @SQL = 
		'SELECT *
	INTO #ParentLotQuality
	FROM (
		SELECT DENSE_RANK() OVER (
				ORDER BY S.intSampleId DESC
				) intRankNo  
			,C.strCategoryCode
			,I.intItemId
			,I.strItemNo  
			,I.strDescription  
			,PL.intParentLotId AS intLotId
			,PL.strParentLotNumber AS strLotNumber
			,LS.strSecondaryStatus AS strLotStatus
			,L.strLotAlias
			,S.strSampleNumber
			,SS.strSecondaryStatus AS strSampleStatus
			,ISNULL(SUM(L.dblWeight),SUM(L.dblQty)) AS dblLotQty
			,U.strUnitMeasure
			,MIN(L.dtmDateCreated) AS dtmDateCreated
			,S.intSampleId
			,S.strComment
			,COUNT(*) OVER () AS intTotalCount 
		FROM tblICParentLot AS PL 
		JOIN tblICLot AS L ON L.intParentLotId = PL.intParentLotId 
		JOIN tblICLotStatus AS LS ON LS.intLotStatusId = PL.intLotStatusId  
		JOIN tblICItem AS I ON I.intItemId = L.intItemId  
		JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
		JOIN tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
		JOIN tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblQMSample S ON S.intProductValueId = L.intParentLotId
			AND S.intProductTypeId = 11'

	IF @ysnShowSampleFromAllLocation = 0
	BEGIN
		SET @SQL = @SQL + ' AND S.intLocationId =' + @strLocationId
	END

	IF (@strUserRoleID <> '0')
	BEGIN
		SET @SQL = @SQL + ' JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId AND SU.intUserRoleID =' + @strUserRoleID
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
		LEFT JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
		LEFT JOIN tblICItemOwner ito1 ON ito1.intItemOwnerId = LI.intItemOwnerId'

	IF (LEN(@strFilterCriteria) > 0)
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strItemNo]', 'I.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strDescription]', 'I.strDescription')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotNumber]', 'PL.strParentLotNumber')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotStatus]', 'LS.strSecondaryStatus')
		--SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[dblLotQty]', 'ISNULL(L.dblWeight,L.dblQty)')
		--SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[dtmDateCreated]', 'L.dtmDateCreated')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strSampleStatus]', 'SS.strSecondaryStatus')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strComment]', 'S.strComment')
		SET @SQL = @SQL + ' WHERE ' + @strFilterCriteria
	END

	SET @SQL = @SQL + ' GROUP BY
			C.strCategoryCode
			,I.intItemId
			,I.strItemNo
			,I.strDescription
			,PL.intParentLotId
			,PL.strParentLotNumber
			,LS.strSecondaryStatus
			,L.strLotAlias
			,S.strSampleNumber
			,SS.strSecondaryStatus
			,U.strUnitMeasure
			,S.intSampleId
			,S.strComment'
	SET @SQL = @SQL + ') t '
	SET @SQL = @SQL + '	WHERE intRankNo > ' + @strStart + '
			AND intRankNo <= ' + @strStart + '+' + @strLimit
	SET @SQL = @SQL + ' SELECT   
	intTotalCount
	,strCategoryCode  
	,intItemId  
	,strItemNo  
	,strDescription  
	,intLotId  
	,strLotNumber
	,strLotStatus
	,strLotAlias
	,strSampleNumber
	,strSampleStatus
	,dblLotQty  
	,strUnitMeasure
	,dtmDateCreated
	,intSampleId
	,strComment
	,' + @str + 'FROM (  
		SELECT intTotalCount
			,strCategoryCode
			,CQ.intItemId
			,strItemNo  
			,CQ.strDescription  
			,intLotId
			,strLotNumber
			,strLotStatus
			,strLotAlias
			,strSampleNumber
			,strSampleStatus
			,dblLotQty
			,strUnitMeasure
			,CQ.dtmDateCreated
			,CQ.intSampleId
			,CQ.strComment
			,P.strPropertyName + '' - '' + T.strTestName AS strPropertyName  
			,TR.strPropertyValue
		FROM #ParentLotQuality CQ
		JOIN tblQMTestResult AS TR ON TR.intSampleId = CQ.intSampleId
		JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
		JOIN tblQMTest AS T ON TR.intTestId = T.intTestId
	) t  
	PIVOT(MAX(strPropertyValue) FOR strPropertyName IN (' + 
		@str + ')) pvt'
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
