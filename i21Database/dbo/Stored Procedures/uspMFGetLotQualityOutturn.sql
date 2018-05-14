CREATE PROCEDURE uspMFGetLotQualityOutturn @strStart NVARCHAR(10) = '0'
	,@strLimit NVARCHAR(10) = '1'
	,@strFilterCriteria NVARCHAR(MAX) = ''
	,@strSortField NVARCHAR(MAX) = 'intSampleId'
	,@strSortDirection NVARCHAR(5) = 'DESC'
	,@intWorkOrderId INT = 0
	,@strWeightUOM NVARCHAR(50) = '0'
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
		,@strColumnsList NVARCHAR(MAX)

	SET @SQL = 'Declare @tblMFLot Table(intLotId int)
		Insert into @tblMFLot (intLotId)
		SELECT OM.intLotId
		FROM tblMFWorkOrder W
		JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
		JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
		JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
		Where W.intWorkOrderId=' + Ltrim(@intWorkOrderId)
	SET @SQL = @SQL + ' SELECT @PropList = Stuff((  
    SELECT ''],['' + strPropertyName  
    FROM (  
		SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName  
		FROM tblICLot AS L
		JOIN @tblMFLot AS L1 on L1.intLotId=L.intLotId
		JOIN tblICItem AS I ON I.intItemId = L.intItemId  
		JOIN tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
		JOIN tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblQMSample S ON S.intProductValueId = L.intLotId
			AND S.intProductTypeId = 6
		JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  
		AND ST.intControlPointId in (6,9)
		JOIN tblQMTestResult AS TR ON TR.intSampleId = S.intSampleId
		JOIN tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
		JOIN tblQMTest AS T ON T.intTestId = TR.intTestId
		'

	IF (LEN(@strFilterCriteria) > 0)
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strItemNo]', 'I.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strDescription]', 'I.strDescription')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotNumber]', 'L.strLotNumber')
		SET @SQL = @SQL + ' WHERE ' + @strFilterCriteria
	END

	SET @SQL = @SQL + ') t  
    ORDER BY ''],['' + strTestName,strPropertyName  
    FOR XML Path('''')  
    ), 1, 2, '''') + '']'''

	SELECT @params = '@PropList nvarchar(max) OUTPUT'

	EXEC sp_executesql @SQL
		,@params
		,@PropList = @str OUTPUT

	-- Quality Sample Data
	IF OBJECT_ID('tempdb.dbo.#LotQuality') IS NOT NULL
		DROP TABLE #LotQuality

	SET @SQL = 'Declare @tblMFLot Table(intLotId int)
		Insert into @tblMFLot (intLotId)
		SELECT OM.intLotId
		FROM tblMFWorkOrder W
		JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
		JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
		JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
		Where W.intWorkOrderId=' + Ltrim(@intWorkOrderId)
	SET @SQL = @SQL + 
		' SELECT *
	INTO #LotQuality
	FROM (
		SELECT DENSE_RANK() OVER (
				ORDER BY S.intSampleId DESC
				) intRankNo  
			,I.intItemId
			,I.strItemNo  
			,I.strDescription  
			,L.intLotId
			,L.strLotNumber
			,S.intSampleId
			,S.strSampleNumber
			,L.dblQty AS dblQty
			,U.strUnitMeasure AS strQtyUOM
			,ISNULL(L.dblWeight,L.dblQty) AS dblWeight
			,U1.strUnitMeasure AS strWeightUOM
			,DateDiff(d,L.dtmDateCreated,GETDATE()) As intNoOfDaysInStorage
			,ST.intControlPointId
			,COUNT(*) OVER () AS intTotalCount
		FROM tblICLot AS L 
		JOIN @tblMFLot L1 on L.intLotId=L1.intLotId
		JOIN tblICItem AS I ON I.intItemId = L.intItemId  
		JOIN tblICItemUOM AS IU ON IU.intItemUOMId = L.intItemUOMId
		JOIN tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblICItemUOM AS IU1 ON IU1.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
		JOIN tblICUnitMeasure AS U1 ON U1.intUnitMeasureId = IU1.intUnitMeasureId
		JOIN tblQMSample S ON S.intProductValueId = L.intLotId
			AND S.intProductTypeId = 6
		JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  AND ST.intControlPointId in (6,9)
		'

	IF (LEN(@strFilterCriteria) > 0)
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strItemNo]', 'I.strItemNo')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strDescription]', 'I.strDescription')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotNumber]', 'L.strLotNumber')
		SET @SQL = @SQL + ' WHERE ' + @strFilterCriteria
	END

	SET @SQL = @SQL + ') t '
	SET @SQL = @SQL + '	WHERE intRankNo > ' + @strStart + '
			AND intRankNo <= ' + @strStart + '+' + @strLimit
	SET @strColumnsList = 'TransactionType,intSampleId,strSampleNumber,intNoOfDaysInStorage,intLotId,strLotNumber'
	SET @strColumnsList = @strColumnsList + ',intItemId,strDescription,strItemNo,dblQty,strQtyUOM,dblWeight,strWeightUOM,intTotalCount'
	SET @strColumnsList = @strColumnsList + ',' + REPLACE(REPLACE(@str, '[', ''), ']', '')
	SET @SQL = @SQL + ' SELECT intTotalCount   
	,Case When intControlPointId=6 then ''GRN'' Else ''IP'' End TransactionType
	,intSampleId
	,strSampleNumber
	,intNoOfDaysInStorage
	,intLotId  
	,strLotNumber
	,intItemId  
	,strDescription  
	,strItemNo  
	,dblQty
	,strQtyUOM
	,dblWeight
	,strWeightUOM
	,' + @str + ',''' + @strColumnsList + ''' AS strColumnsList ' + 
		'FROM (  
		SELECT intTotalCount   
			,CQ.intSampleId
			,strSampleNumber
			,intNoOfDaysInStorage
			,intLotId  
			,strLotNumber
			,CQ.intItemId
			,CQ.strDescription  
			,CQ.strItemNo  
			,dblQty
			,strQtyUOM
			,dblWeight
			,strWeightUOM
			,P.strPropertyName + '' - '' + T.strTestName AS strPropertyName  
			,TR.strPropertyValue
			,CQ.intControlPointId
		FROM #LotQuality CQ
		JOIN tblQMTestResult AS TR ON TR.intSampleId = CQ.intSampleId
		JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
		JOIN tblQMTest AS T ON TR.intTestId = T.intTestId
	) t  
	PIVOT(MAX(strPropertyValue) FOR strPropertyName IN (' + @str + ')) pvt'
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
