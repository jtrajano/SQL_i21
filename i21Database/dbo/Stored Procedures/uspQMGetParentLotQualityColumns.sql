﻿CREATE PROCEDURE uspQMGetParentLotQualityColumns @strLocationId NVARCHAR(10) = '0'
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
	FROM dbo.tblQMTestResult AS TR
  JOIN dbo.tblICParentLot AS PL ON PL.intParentLotId = TR.intProductValueId AND TR.intProductTypeId = 11 
  JOIN dbo.tblICLot AS L ON L.intParentLotId = PL.intParentLotId 
  JOIN dbo.tblICItem AS I ON I.intItemId = L.intItemId  
  JOIN dbo.tblICCategory AS C ON C.intCategoryId = I.intCategoryId
  JOIN dbo.tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
  JOIN dbo.tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
  JOIN dbo.tblQMSample AS S ON S.intSampleId = TR.intSampleId'

	IF @ysnShowSampleFromAllLocation = 0 AND @strLocationId <> '0'
	BEGIN
		SET @SQL = @SQL + ' AND S.intLocationId =' + @strLocationId
	END

	IF (@strUserRoleID <> '0')
	BEGIN
		SET @SQL = @SQL + ' JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId AND SU.intUserRoleID =' + @strUserRoleID
	END

	SET @SQL = @SQL + ' JOIN dbo.tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
  JOIN dbo.tblQMTest AS T ON T.intTestId = TR.intTestId
     ) t  
    ORDER BY ''],['' + strTestName,strPropertyName  
    FOR XML Path('''')  
	), 1, 6, '''') + ''] INT'''

	SELECT @params = '@PropList nvarchar(max) OUTPUT'

	EXEC sp_executesql @SQL
		,@params
		,@PropList = @str OUTPUT

	IF OBJECT_ID('tempdb.dbo.##ParentLotProperty') IS NOT NULL
		DROP TABLE ##ParentLotProperty

	IF ISNULL(@str, '') <> ''
	BEGIN
		SELECT @SQL = 'CREATE TABLE ##ParentLotProperty (intSampleId INT,intItemId INT,intLotId INT,strCategoryCode INT,strItemNo INT,strDescription INT,strParentLotNumber INT,strLotStatus INT,strLotAlias INT,dblLotQty INT,strUnitMeasure INT,dtmDateCreated INT,strPartyName INT,strSampleNumber INT,strSampleRefNo INT,strSampleStatus INT,strSampleTypeName INT,strComment INT,' + @str + ')'
	END
	ELSE
	BEGIN
		SELECT @SQL = 'CREATE TABLE ##ParentLotProperty (intSampleId INT,intItemId INT,intLotId INT,strCategoryCode INT,strItemNo INT,strDescription INT,strParentLotNumber INT,strLotStatus INT,strLotAlias INT,dblLotQty INT,strUnitMeasure INT,dtmDateCreated INT,strPartyName INT,strSampleNumber INT,strSampleRefNo INT,strSampleStatus INT,strSampleTypeName INT,strComment INT)'
	END

	EXEC sp_executesql @SQL

	INSERT INTO ##ParentLotProperty (intSampleId)
	SELECT NULL

	SELECT *
	FROM ##ParentLotProperty
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
