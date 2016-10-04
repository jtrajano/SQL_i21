CREATE PROCEDURE uspQMGetContractQualityColumns
	@strLocationId NVARCHAR(10) = '0'
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
    SELECT ''] INT,['' + strPropertyName  
    FROM (  
     SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName  
     FROM dbo.tblCTContractHeader AS CH  
     JOIN dbo.tblEMEntity AS E ON E.intEntityId = CH.intEntityId  
     JOIN dbo.tblCTContractDetail AS CD ON CD.intContractHeaderId = CH.intContractHeaderId  
     JOIN dbo.tblICItem AS I ON I.intItemId = CD.intItemId  
     JOIN dbo.tblQMSample AS S ON S.intContractDetailId = CD.intContractDetailId
		AND S.intLocationId =' + @strLocationId + '
     JOIN dbo.tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  
     JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId  
     JOIN dbo.tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId  
     JOIN dbo.tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId  
     JOIN dbo.tblQMTest AS T ON TR.intTestId = T.intTestId  
     LEFT JOIN dbo.tblLGLoadContainer AS C ON C.intLoadContainerId = S.intLoadContainerId  
     ) t  
    ORDER BY ''],['' + strTestName,strPropertyName  
    FOR XML Path('''')  
    ), 1, 6, '''') + ''] INT'''

	SELECT @params = '@PropList nvarchar(max) OUTPUT'

	EXEC sp_executesql @SQL
		,@params
		,@PropList = @str OUTPUT

	IF OBJECT_ID('tempdb.dbo.##PropertyName') IS NOT NULL
		DROP TABLE ##PropertyName

	SELECT @SQL = 'CREATE TABLE ##PropertyName (strContractNumber INT,strName INT,strContractItemName INT,strBundleItemNo INT,strItemNo INT,strDescription INT,strLoadNumber INT,strContainerNumber INT,strMarks INT,strShipperCode INT,strShipperName INT,strSubLocationName INT,strSampleNumber INT,strSampleTypeName INT,strStatus INT,intSampleId INT,dtmSampleReceivedDate INT,dtmSamplingEndDate INT,' + @str + ')'

	EXEC sp_executesql @SQL

	INSERT INTO ##PropertyName (strContractNumber)
	SELECT NULL

	SELECT *
	FROM ##PropertyName
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
