﻿CREATE PROCEDURE uspQMGetLotQuality @strStart NVARCHAR(10) = '0'
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
		FROM tblICLot AS L
		JOIN tblICParentLot AS PL ON PL.intParentLotId = L.intParentLotId
		JOIN tblICItem AS I ON I.intItemId = L.intItemId  
		JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
		JOIN tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
		JOIN tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblQMSample S ON S.intProductValueId = L.intLotId
			AND S.intProductTypeId = 6
			AND S.intTypeId = 1'

	IF @ysnShowSampleFromAllLocation = 0 AND @strLocationId <> '0'
	BEGIN
		SET @SQL = @SQL + ' AND S.intLocationId =' + @strLocationId
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  '

	IF (@strUserRoleID <> '0')
	BEGIN
		SET @SQL = @SQL + ' JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId AND SU.intUserRoleID =' + @strUserRoleID
	END

	SET @SQL = @SQL + ' JOIN tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId
		JOIN tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
		JOIN tblQMTest AS T ON T.intTestId = TR.intTestId
		JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
		JOIN tblICLotStatus AS LS ON LS.intLotStatusId = L.intLotStatusId
		LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
		LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = S.intSubBookId
		LEFT JOIN tblEMEntity AS E ON E.intEntityId = S.intEntityId'

	IF (LEN(@strFilterCriteria) > 0)
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strItemNo]', 'I.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strDescription]', 'I.strDescription')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotNumber]', 'L.strLotNumber')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strParentLotNumber]', 'PL.strParentLotNumber')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotStatus]', 'LS.strSecondaryStatus')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strPartyName]', 'E.strName')
		--SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[dblLotQty]', 'ISNULL(L.dblWeight,L.dblQty)')
		--SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[dtmDateCreated]', 'L.dtmDateCreated')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strSampleStatus]', 'SS.strSecondaryStatus')
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
	IF OBJECT_ID('tempdb.dbo.#LotQuality') IS NOT NULL
		DROP TABLE #LotQuality

	SET @SQL = 
		'SELECT *
	INTO #LotQuality
	FROM (
		SELECT DENSE_RANK() OVER (
				ORDER BY S.intSampleId DESC
				) intRankNo  
			,C.strCategoryCode
			,I.intItemId
			,I.strItemNo  
			,I.strDescription  
			,L.intLotId
			,PL.strParentLotNumber
			,L.strLotNumber
			,LS.strSecondaryStatus AS strLotStatus
			,E.strName AS strPartyName
			,L.strLotAlias
			,S.strSampleNumber
			,B.strBook
			,SB.strSubBook
			,S.strSampleRefNo
			,SS.strSecondaryStatus AS strSampleStatus
			,ST.strSampleTypeName
			,ISNULL(L.dblWeight,L.dblQty) AS dblLotQty
			,U.strUnitMeasure
			,L.dtmDateCreated
			,S.intSampleId
			,S.strComment
			,COUNT(*) OVER () AS intTotalCount
		FROM tblICLot AS L 
		JOIN tblICParentLot AS PL ON PL.intParentLotId = L.intParentLotId
		JOIN tblICLotStatus AS LS ON LS.intLotStatusId = L.intLotStatusId  
		JOIN tblICItem AS I ON I.intItemId = L.intItemId  
		JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
		JOIN tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
		JOIN tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblQMSample S ON S.intProductValueId = L.intLotId
			AND S.intProductTypeId = 6
			AND S.intTypeId = 1'

	IF @ysnShowSampleFromAllLocation = 0 AND @strLocationId <> '0'
	BEGIN
		SET @SQL = @SQL + ' AND S.intLocationId =' + @strLocationId
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  '

	IF (@strUserRoleID <> '0')
	BEGIN
		SET @SQL = @SQL + ' JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId AND SU.intUserRoleID =' + @strUserRoleID
	END

	SET @SQL = @SQL + ' JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
		LEFT JOIN tblICItemOwner ito1 ON ito1.intItemOwnerId = L.intItemOwnerId
		LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
		LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = S.intSubBookId
		LEFT JOIN tblEMEntity AS E ON E.intEntityId = S.intEntityId'

	IF (LEN(@strFilterCriteria) > 0)
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strItemNo]', 'I.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strDescription]', 'I.strDescription')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotNumber]', 'L.strLotNumber')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strParentLotNumber]', 'PL.strParentLotNumber')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotStatus]', 'LS.strSecondaryStatus')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strPartyName]', 'E.strName')
		--SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[dblLotQty]', 'ISNULL(L.dblWeight,L.dblQty)')
		--SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[dtmDateCreated]', 'L.dtmDateCreated')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strSampleStatus]', 'SS.strSecondaryStatus')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strComment]', 'S.strComment')
		SET @SQL = @SQL + ' WHERE ' + @strFilterCriteria
	END

	SET @SQL = @SQL + ') t '
	SET @SQL = @SQL + '	WHERE intRankNo > ' + @strStart + '
			AND intRankNo <= ' + @strStart + '+' + @strLimit
	SET @strColumnsList = 'intTotalCount,strCategoryCode,intItemId,strItemNo,strDescription,intLotId,strParentLotNumber,strLotNumber'
	SET @strColumnsList = @strColumnsList + ',strLotStatus,strPartyName,strLotAlias,strSampleNumber,strBook,strSubBook,strSampleRefNo,strSampleStatus,strSampleTypeName,dblLotQty,strUnitMeasure,dtmDateCreated,intSampleId'
	SET @strColumnsList = @strColumnsList + ',strComment,' + REPLACE(REPLACE(@str, '[', ''), ']', '')
	SET @SQL = @SQL + ' SELECT   
	intTotalCount
	,strCategoryCode  
	,intItemId  
	,strItemNo  
	,strDescription  
	,intLotId  
	,strParentLotNumber
	,strLotNumber
	,strLotStatus
	,strPartyName
	,strLotAlias
	,strSampleNumber
	,strBook
	,strSubBook
	,strSampleRefNo
	,strSampleStatus
	,strSampleTypeName
	,dblLotQty  
	,strUnitMeasure
	,dtmDateCreated
	,intSampleId
	,strComment
	,' + @str + ',''' + @strColumnsList + ''' AS strColumnsList ' + 
	'FROM (  
		SELECT intTotalCount
			,strCategoryCode
			,CQ.intItemId
			,strItemNo  
			,CQ.strDescription  
			,intLotId
			,strParentLotNumber
			,strLotNumber
			,strLotStatus
			,strPartyName
			,strLotAlias
			,strSampleNumber
			,strBook
			,strSubBook
			,strSampleRefNo
			,strSampleStatus
			,strSampleTypeName
			,dblLotQty
			,strUnitMeasure
			,CQ.dtmDateCreated
			,CQ.intSampleId  
			,CQ.strComment
			,P.strPropertyName + '' - '' + T.strTestName AS strPropertyName  
			,TR.strPropertyValue
		FROM #LotQuality CQ
		JOIN tblQMTestResult AS TR ON TR.intSampleId = CQ.intSampleId
		JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
		JOIN tblQMTest AS T ON TR.intTestId = T.intTestId
	) t  
	PIVOT(MAX(strPropertyValue) FOR strPropertyName IN (' + @str + 
		')) pvt'
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
