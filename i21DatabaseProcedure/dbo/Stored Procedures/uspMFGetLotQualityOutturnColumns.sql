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
		Declare @tblMFFinalLot Table(intLotId int,strLotNumber nvarchar(50) collate Latin1_General_CI_AS)
		Insert into @tblMFLot (intLotId)
		SELECT OM.intLotId
		FROM tblMFWorkOrder W
		JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
		JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
		JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
		Where W.intWorkOrderId=' + Ltrim(@intWorkOrderId)+'
		UNION 
		Select WI.intLotId
		From tblMFWorkOrderInputLot WI
		Where WI.intWorkOrderId=' + Ltrim(@intWorkOrderId)+' and WI.ysnConsumptionReversed =0
		Insert into @tblMFFinalLot (intLotId,strLotNumber) 
		Select L.intLotId,L.strLotNumber 
		from tblICLot L 
		Where L.strLotNumber in (Select L2.strLotNumber from @tblMFLot L1 JOIN tblICLot L2 on L1.intLotId=L2.intLotId)'
		SET @SQL = @SQL + 'SELECT @PropList = Stuff((  
	SELECT ''] INT,['' + strPropertyName  
    FROM (  
     SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName,TR.intSequenceNo  
	FROM dbo.tblQMTestResult AS TR
  JOIN @tblMFFinalLot AS L ON L.intLotId = TR.intProductValueId AND TR.intProductTypeId = 6 and TR.intSampleId in (Select Max(S1.intSampleId) from tblQMSample S1 Where S1.intSampleStatusId =3 and S1.strLotNumber=L.strLotNumber AND S1.intProductTypeId = 6 )' 
  SET @SQL = @SQL + ' JOIN dbo.tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
  JOIN dbo.tblQMTest AS T ON T.intTestId = TR.intTestId
     ) t  
    ORDER BY t.intSequenceNo
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
									,dtmSampleReceivedDate INT
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
									,dtmSampleReceivedDate INT
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
