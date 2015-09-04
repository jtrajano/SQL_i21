CREATE PROCEDURE [dbo].[uspQMGetContractQualityCount]
	@strFilterCriteria NVARCHAR(MAX) = ''
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

	SET @SQL = 
		'SELECT @PropList = Stuff((  
    SELECT ''],['' + strPropertyName  
    FROM (  
     SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName  
     FROM dbo.tblCTContractHeader AS CH  
     JOIN dbo.tblEntity AS E ON E.intEntityId = CH.intEntityId  
     JOIN dbo.tblCTContractDetail AS CD ON CD.intContractHeaderId = CH.intContractHeaderId  
     JOIN dbo.tblICItem AS I ON I.intItemId = CD.intItemId  
     JOIN dbo.tblQMSample AS S ON S.intContractDetailId = CD.intContractDetailId  
     JOIN dbo.tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  
     JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId  
     JOIN dbo.tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId  
     JOIN dbo.tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId  
     JOIN dbo.tblQMTest AS T ON TR.intTestId = T.intTestId  
     LEFT JOIN dbo.tblLGShipmentBLContainer AS C ON C.intShipmentBLContainerId = S.intShipmentBLContainerId  
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
  intContractNumber  
  ,strName  
  ,strItemNo  
  ,strDescription  
  ,strContainerNumber  
  ,strSampleNumber  
  ,strSampleTypeName  
  ,strStatus  
  ,intSampleId  
  ,' + @str + 
		'FROM (  
  SELECT DENSE_RANK() OVER (ORDER BY S.intSampleId DESC) intRankNo  
   ,CH.intContractNumber  
   ,E.strName  
   ,I.strItemNo  
   ,I.strDescription  
   ,C.strContainerNumber  
   ,S.strSampleNumber  
   ,ST.strSampleTypeName  
   ,SS.strStatus  
   ,P.strPropertyName + '' - '' + T.strTestName AS strPropertyName  
   ,TR.strPropertyValue  
   ,S.intSampleId  
  FROM dbo.tblCTContractHeader AS CH  
  JOIN dbo.tblEntity AS E ON E.intEntityId = CH.intEntityId  
  JOIN dbo.tblCTContractDetail AS CD ON CD.intContractHeaderId = CH.intContractHeaderId  
  JOIN dbo.tblICItem AS I ON I.intItemId = CD.intItemId  
  JOIN dbo.tblQMSample AS S ON S.intContractDetailId = CD.intContractDetailId  
  JOIN dbo.tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  
  JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId  
  JOIN dbo.tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId  
  JOIN dbo.tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId  
  JOIN dbo.tblQMTest AS T ON TR.intTestId = T.intTestId  
  LEFT JOIN dbo.tblLGShipmentBLContainer AS C ON C.intShipmentBLContainerId = S.intShipmentBLContainerId  
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
