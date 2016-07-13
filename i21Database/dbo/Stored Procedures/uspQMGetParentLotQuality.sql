CREATE PROCEDURE [dbo].[uspQMGetParentLotQuality]
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
	FROM dbo.tblQMTestResult AS TR
  JOIN dbo.tblICParentLot AS PL ON PL.intParentLotId = TR.intProductValueId AND TR.intProductTypeId = 11 
  JOIN dbo.tblICLot AS L ON L.intParentLotId = PL.intParentLotId 
  JOIN dbo.tblICItem AS I ON I.intItemId = L.intItemId  
  JOIN dbo.tblICCategory AS C ON C.intCategoryId = I.intCategoryId
  JOIN dbo.tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
  JOIN dbo.tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
  JOIN dbo.tblQMSample AS S ON S.intSampleId = TR.intSampleId
	AND S.intLocationId =' + @strLocationId + '
  JOIN dbo.tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
  JOIN dbo.tblQMTest AS T ON T.intTestId = TR.intTestId
     ) t  
    ORDER BY ''],['' + strTestName,strPropertyName  
    FOR XML Path('''')  
    ), 1, 2, '''') + '']'''

	SELECT @params = '@PropList nvarchar(max) OUTPUT'

	EXEC sp_executesql @SQL
		,@params
		,@PropList = @str OUTPUT

	--SELECT @str -- Property Names List  
	SET @SQL = 'SELECT TOP ' + @strLimit + '   
  strCategoryCode  
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
  ,' + @str + 
		'FROM (  
  SELECT DENSE_RANK() OVER (ORDER BY S.intSampleId DESC) intRankNo  
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
   ,P.strPropertyName + '' - '' + T.strTestName AS strPropertyName  
   ,TR.strPropertyValue  
  FROM dbo.tblQMTestResult AS TR
  JOIN dbo.tblICParentLot AS PL ON PL.intParentLotId = TR.intProductValueId AND TR.intProductTypeId = 11 
  JOIN dbo.tblICLot AS L ON L.intParentLotId = PL.intParentLotId 
  JOIN dbo.tblICLotStatus AS LS ON LS.intLotStatusId = PL.intLotStatusId  
  JOIN dbo.tblICItem AS I ON I.intItemId = L.intItemId  
  JOIN dbo.tblICCategory AS C ON C.intCategoryId = I.intCategoryId
  JOIN dbo.tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
  JOIN dbo.tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
  JOIN dbo.tblQMSample AS S ON S.intSampleId = TR.intSampleId
	AND S.intLocationId =' + @strLocationId + '
  JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId  
  JOIN dbo.tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
  JOIN dbo.tblQMTest AS T ON T.intTestId = TR.intTestId
  GROUP BY
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
   ,P.strPropertyName + '' - '' + T.strTestName
   ,TR.strPropertyValue
  ) t  
 PIVOT(max(strPropertyValue) FOR strPropertyName IN (' 
		+ @str + ')) pvt WHERE intRankNo > ' + @strStart

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
