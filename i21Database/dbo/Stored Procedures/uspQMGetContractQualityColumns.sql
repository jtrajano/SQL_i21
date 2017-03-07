CREATE PROCEDURE uspQMGetContractQualityColumns @strLocationId NVARCHAR(10) = '0'
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
     FROM dbo.tblCTContractHeader AS CH  
     JOIN dbo.tblEMEntity AS E ON E.intEntityId = CH.intEntityId  
     JOIN dbo.tblCTContractDetail AS CD ON CD.intContractHeaderId = CH.intContractHeaderId  
     JOIN dbo.tblICItem AS I ON I.intItemId = CD.intItemId  
     JOIN dbo.tblQMSample AS S ON S.intContractDetailId = CD.intContractDetailId'

	IF @ysnShowSampleFromAllLocation = 0
	BEGIN
		SET @SQL = @SQL + ' AND S.intLocationId =' + @strLocationId
	END

	SET @SQL = @SQL + ' JOIN dbo.tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  '

	IF (@strUserRoleID <> '0')
	BEGIN
		SET @SQL = @SQL + ' JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId AND SU.intUserRoleID =' + @strUserRoleID
	END

	SET @SQL = @SQL + ' JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId  
     JOIN dbo.tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId  
     JOIN dbo.tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId  
     JOIN dbo.tblQMTest AS T ON TR.intTestId = T.intTestId  
     ) t  
    ORDER BY ''],['' + strTestName,strPropertyName  
    FOR XML Path('''')  
    ), 1, 6, '''') + ''] INT'''

	SELECT @params = '@PropList nvarchar(max) OUTPUT'

	EXEC sp_executesql @SQL
		,@params
		,@PropList = @str OUTPUT

	IF OBJECT_ID('tempdb.dbo.##ContractProperty') IS NOT NULL
		DROP TABLE ##ContractProperty

	IF ISNULL(@str, '') <> ''
	BEGIN
		SELECT @SQL = 'CREATE TABLE ##ContractProperty (intSampleId INT,strContractNumber INT,strName INT,strContractItemName INT,strBundleItemNo INT,strItemNo INT,strDescription INT,strLoadNumber INT,strContainerNumber INT,strMarks INT,strShipperCode INT,strShipperName INT,strSubLocationName INT,strSampleNumber INT,strSampleTypeName INT,strStatus INT,dtmSampleReceivedDate INT,dtmSamplingEndDate INT,strComment INT,' + @str + ')'
	END
	ELSE
	BEGIN
		SELECT @SQL = 'CREATE TABLE ##ContractProperty (intSampleId INT,strContractNumber INT,strName INT,strContractItemName INT,strBundleItemNo INT,strItemNo INT,strDescription INT,strLoadNumber INT,strContainerNumber INT,strMarks INT,strShipperCode INT,strShipperName INT,strSubLocationName INT,strSampleNumber INT,strSampleTypeName INT,strStatus INT,dtmSampleReceivedDate INT,dtmSamplingEndDate INT,strComment INT)'
	END

	EXEC sp_executesql @SQL

	INSERT INTO ##ContractProperty (intSampleId)
	SELECT NULL

	SELECT *
	FROM ##ContractProperty
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
