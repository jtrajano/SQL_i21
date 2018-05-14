CREATE PROCEDURE uspMFGetLotQualityOutturnColumns (@intWorkOrderId int=0)
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

		SET @SQL = 'Declare @tblMFLot Table(intLotId int)
		Insert into @tblMFLot (intLotId)
		SELECT OM.intLotId
		FROM tblMFWorkOrder W
		JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
		JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
		JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
		Where W.intWorkOrderId=' + Ltrim(@intWorkOrderId)
		SET @SQL = @SQL + 'SELECT @PropList = Stuff((  
	SELECT ''] INT,['' + strPropertyName  
    FROM (  
     SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName  
	FROM dbo.tblQMTestResult AS TR
  JOIN @tblMFLot AS L ON L.intLotId = TR.intProductValueId AND TR.intProductTypeId = 6' 
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

	IF OBJECT_ID('tempdb.dbo.##LotProperty') IS NOT NULL
		DROP TABLE ##LotProperty

	IF ISNULL(@str, '') <> ''
	BEGIN
		SELECT @SQL = 'CREATE TABLE ##LotProperty (
									TransactionType INT
									,intSampleId INT
									,strSampleNumber INT
									,intNoOfDaysInStorage INT
									,intLotId INT
									,strLotNumber INT
									,intItemId INT
									,strDescription INT
									,strItemNo INT
									,dblQty INT
									,strQtyUOM INT
									,dblWeight INT
									,strWeightUOM INT
									,' + @str + '
									)'
	END
	ELSE
	BEGIN
		SELECT @SQL = 'CREATE TABLE ##LotProperty (
									TransactionType INT
									,intSampleId INT
									,strSampleNumber INT
									,intNoOfDaysInStorage INT
									,intLotId INT
									,strLotNumber INT
									,intItemId INT
									,strDescription INT
									,strItemNo INT
									,dblQty INT
									,strQtyUOM INT
									,dblWeight INT
									,strWeightUOM INT
												)'
	END

	EXEC sp_executesql @SQL

	INSERT INTO ##LotProperty (intSampleId)
	SELECT NULL

	SELECT *
	FROM ##LotProperty
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
