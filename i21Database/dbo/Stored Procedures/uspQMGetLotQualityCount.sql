CREATE PROCEDURE [dbo].[uspQMGetLotQualityCount]
	@strFilterCriteria NVARCHAR(MAX) = ''
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
  JOIN dbo.tblICLot AS L ON L.intLotId = TR.intProductValueId AND TR.intProductTypeId = 6  
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
	SET @SQL = 'SELECT COUNT(intSampleId) FROM (SELECT   
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
   ,L.intLotId
   ,L.strLotNumber
   ,LS.strSecondaryStatus AS strLotStatus
   ,L.strLotAlias
   ,S.strSampleNumber
   ,SS.strSecondaryStatus AS strSampleStatus
   ,ISNULL(L.dblWeight,L.dblQty) AS dblLotQty
   ,U.strUnitMeasure
   ,L.dtmDateCreated
   ,S.intSampleId  
   ,P.strPropertyName + '' - '' + T.strTestName AS strPropertyName  
   ,TR.strPropertyValue  
  FROM dbo.tblQMTestResult AS TR
  JOIN dbo.tblICLot AS L ON L.intLotId = TR.intProductValueId AND TR.intProductTypeId = 6  
  JOIN dbo.tblICLotStatus AS LS ON LS.intLotStatusId = L.intLotStatusId  
  JOIN dbo.tblICItem AS I ON I.intItemId = L.intItemId  
  JOIN dbo.tblICCategory AS C ON C.intCategoryId = I.intCategoryId
  JOIN dbo.tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
  JOIN dbo.tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
  JOIN dbo.tblQMSample AS S ON S.intSampleId = TR.intSampleId
	AND S.intLocationId =' + @strLocationId + '
  JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId  
  JOIN dbo.tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
  JOIN dbo.tblQMTest AS T ON T.intTestId = TR.intTestId
  ) t  
 PIVOT(max(strPropertyValue) FOR strPropertyName IN (' 
		+ @str + ')) pvt) AS DT'

	IF (LEN(@strFilterCriteria) > 0)
		SET @SQL = @SQL + ' WHERE ' + @strFilterCriteria

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
