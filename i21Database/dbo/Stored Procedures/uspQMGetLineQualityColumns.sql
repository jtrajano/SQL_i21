CREATE PROCEDURE uspQMGetLineQualityColumns @strLocationId NVARCHAR(10) = '0'
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
	SELECT ''] INT,['' + strPropertyName  
    FROM (  
     SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName
	   FROM tblQMTestResult AS TR
	   JOIN tblMFWorkOrder W ON W.intWorkOrderId = TR.intProductValueId AND TR.intProductTypeId = 12
	   JOIN tblICItem AS I ON I.intItemId = W.intItemId  
	   JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
	   JOIN tblQMSample AS S ON S.intSampleId = TR.intSampleId'

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
	   JOIN tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
	   JOIN tblQMTest AS T ON T.intTestId = TR.intTestId
	   JOIN tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
     ) t  
    ORDER BY ''],['' + strTestName,strPropertyName  
    FOR XML Path('''')  
	), 1, 6, '''') + ''] INT'''

	SELECT @params = '@PropList nvarchar(max) OUTPUT'

	EXEC sp_executesql @SQL
		,@params
		,@PropList = @str OUTPUT

	IF OBJECT_ID('tempdb.dbo.##LineProperty') IS NOT NULL
		DROP TABLE ##LineProperty

	IF ISNULL(@str, '') <> ''
	BEGIN
		SELECT @SQL = 'CREATE TABLE ##LineProperty (intSampleId INT,intItemId INT,intWorkOrderId INT,strCategoryCode INT,strItemNo INT,strDescription INT,strWorkOrderNo INT,strWorkOrderStatus INT,strSampleNumber INT,strSampleStatus INT,strSampleTypeName INT,dtmSampleReceivedDate INT,strComment INT,' + @str + ')'
	END
	ELSE
	BEGIN
		SELECT @SQL = 'CREATE TABLE ##LineProperty (intSampleId INT,intItemId INT,intWorkOrderId INT,strCategoryCode INT,strItemNo INT,strDescription INT,strWorkOrderNo INT,strWorkOrderStatus INT,strSampleNumber INT,strSampleStatus INT,strSampleTypeName INT,dtmSampleReceivedDate INT,strComment INT)'
	END

	EXEC sp_executesql @SQL

	INSERT INTO ##LineProperty (intSampleId)
	SELECT NULL

	SELECT *
	FROM ##LineProperty
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
