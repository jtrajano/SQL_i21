CREATE PROCEDURE uspQMGetLineQuality
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
	   FROM tblQMTestResult AS TR
	   JOIN tblMFWorkOrder W ON W.intWorkOrderId = TR.intProductValueId AND TR.intProductTypeId = 12
	   JOIN tblICItem AS I ON I.intItemId = W.intItemId  
	   JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
	   JOIN tblQMSample AS S ON S.intSampleId = TR.intSampleId
		  AND S.intLocationId =' + @strLocationId + 
		'
	   JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  
	   JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
	   JOIN tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
	   JOIN tblQMTest AS T ON T.intTestId = TR.intTestId
	   JOIN tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
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
  ,intWorkOrderId  
  ,strWorkOrderNo
  ,strWorkOrderStatus
  ,strSampleNumber
  ,strSampleStatus
  ,strSampleTypeName
  ,intSampleId
  ,dtmSampleReceivedDate
  ,' + @str + 
		'FROM (  
  SELECT DENSE_RANK() OVER (ORDER BY S.intSampleId DESC) intRankNo  
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
   ,P.strPropertyName + '' - '' + T.strTestName AS strPropertyName  
   ,TR.strPropertyValue
    FROM tblQMTestResult AS TR
    JOIN tblMFWorkOrder W ON W.intWorkOrderId = TR.intProductValueId AND TR.intProductTypeId = 12
    JOIN tblICItem AS I ON I.intItemId = W.intItemId  
    JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
    JOIN tblQMSample AS S ON S.intSampleId = TR.intSampleId
	   AND S.intLocationId =' + @strLocationId + 
		'
    JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  
    JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
    JOIN tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
    JOIN tblQMTest AS T ON T.intTestId = TR.intTestId
    JOIN tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
  ) t  
 PIVOT(max(strPropertyValue) FOR strPropertyName IN (' + @str + ')) pvt WHERE intRankNo > ' + @strStart

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
