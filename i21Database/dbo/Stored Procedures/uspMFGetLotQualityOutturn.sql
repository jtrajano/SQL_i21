CREATE PROCEDURE uspMFGetLotQualityOutturn @strStart NVARCHAR(10) = '0'
	,@strLimit NVARCHAR(10) = '1'
	,@strFilterCriteria NVARCHAR(MAX) = ''
	,@strSortField NVARCHAR(MAX) = 'intSampleId'
	,@strSortDirection NVARCHAR(5) = 'DESC'
	,@intWorkOrderId INT = 0
	,@strWeightUOM NVARCHAR(50) = 'LB'
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
		,@intUnitMeasureId INT

	SELECT @intUnitMeasureId = intUnitMeasureId
	FROM tblICUnitMeasure
	WHERE strUnitMeasure = @strWeightUOM

	SET @SQL = 'Declare @tblMFLot Table(intLotId int)
		Declare @tblMFFinalLot Table(intLotId int,strLotNumber nvarchar(50)  collate Latin1_General_CI_AS)
		Insert into @tblMFLot (intLotId)
		SELECT OM.intLotId
		FROM tblMFWorkOrder W
		JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
		JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
		JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
		Where W.intWorkOrderId=' + Ltrim(@intWorkOrderId) + '
		UNION 
		Select WI.intLotId
		From tblMFWorkOrderInputLot WI
		Where WI.intWorkOrderId=' + Ltrim(@intWorkOrderId) + ' and WI.ysnConsumptionReversed =0
		Insert into @tblMFFinalLot (intLotId,strLotNumber) 
		Select L.intLotId,L.strLotNumber 
		from tblICLot L 
		Where L.strLotNumber in (Select L2.strLotNumber from @tblMFLot L1 JOIN tblICLot L2 on L1.intLotId=L2.intLotId)'
	SET @SQL = @SQL + 
		' SELECT @PropList = Stuff((  
    SELECT ''],['' + strPropertyName  
    FROM (  
		SELECT DISTINCT P.strPropertyName + '' - '' + T.strTestName AS strPropertyName,T.strTestName  
		FROM tblICLot AS L
		JOIN @tblMFFinalLot AS L1 on L1.intLotId=L.intLotId
		JOIN tblICItem AS I ON I.intItemId = L.intItemId  
		JOIN tblICItemUOM AS IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
		JOIN tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblQMSample S ON S.intProductValueId = L.intLotId
			AND S.intProductTypeId = 6 
		JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  
		AND ST.intControlPointId in (5,6,9)
		and S.intSampleId in (Select Max(S1.intSampleId) from tblQMSample S1 JOIN tblQMSampleType ST1 on S1.intSampleTypeId=ST1.intSampleTypeId Where S1.intSampleStatusId =3 and S1.strLotNumber=L1.strLotNumber AND S1.intProductTypeId = 6 and ST1.intControlPointId=ST.intControlPointId )
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
SET @SQL='Declare @tblMFTask table(strLotNumber nvarchar(50) collate Latin1_General_CI_AS,dblQty decimal(38,20),intItemUOMId int,dblWeight decimal(38,20),intWeightUOMId int)
Insert into @tblMFTask
SELECT Distinct L.strLotNumber 
			,T.dblQty 
			,T.intItemUOMId 
			,T.dblWeight
			,T.intWeightUOMId
FROM tblMFWorkOrder W
JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblICLot L ON L.intLotId = OM.intLotId
JOIN tblMFTask T ON T.intLotId = L.intLotId
	AND T.intOrderHeaderId = OM.intOrderHeaderId
WHERE W.intWorkOrderId ='+ ltrim(@intWorkOrderId)


	SET @SQL = @SQL+'Declare @tblMFLot Table(intLotId int)
		Declare @tblMFFinalLot Table(intLotId int,strLotNumber nvarchar(50) collate Latin1_General_CI_AS)
		Insert into @tblMFLot (intLotId)
		SELECT OM.intLotId
		FROM tblMFWorkOrder W
		JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
		JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
		JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
		Where W.intWorkOrderId=' + Ltrim(@intWorkOrderId) + '
		UNION 
		Select WI.intLotId
		From tblMFWorkOrderInputLot WI
		Where WI.intWorkOrderId=' + Ltrim(@intWorkOrderId) + ' and WI.ysnConsumptionReversed =0
		Insert into @tblMFFinalLot (intLotId,strLotNumber) 
		Select L.intLotId,L.strLotNumber 
		from tblICLot L 
		Where L.strLotNumber in (Select L2.strLotNumber from @tblMFLot L1 JOIN tblICLot L2 on L1.intLotId=L2.intLotId)'
	SET @SQL = @SQL + ' SELECT *
	INTO #LotQuality
	FROM (
		SELECT Distinct DENSE_RANK() OVER (
				ORDER BY S.intSampleId DESC
				) intRankNo  
			,I.intItemId
			,I.strItemNo  
			,I.strDescription  
			,L.intLotId
			,L.strLotNumber
			,S.intSampleId
			,S.strSampleNumber
			,S.dtmSampleReceivedDate
			,Case When T.dblQty is not null Then T.dblQty else L.dblQty End AS dblQty
			,U.strUnitMeasure AS strQtyUOM
			,dbo.fnMFConvertQuantityToTargetItemUOM(ISNULL(L.intWeightUOMId,L.intItemUOMId), IU1.intItemUOMId, Case When T.dblQty is not null Then ISNULL(T.dblWeight,T.dblQty) else ISNULL(L.dblWeight,L.dblQty) End) AS dblWeight
			,''' + @strWeightUOM + 
		''' AS strWeightUOM
			,DateDiff(d,L.dtmDateCreated,GETDATE()) As intNoOfDaysInStorage
			,ST.intControlPointId
			,COUNT(*) OVER () AS intTotalCount
		FROM tblICLot AS L 
		JOIN @tblMFFinalLot L1 on L.intLotId=L1.intLotId
		JOIN tblICItem AS I ON I.intItemId = L.intItemId  
		JOIN tblICItemUOM AS IU ON IU.intItemUOMId = L.intItemUOMId
		JOIN tblICUnitMeasure AS U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblICItemUOM AS IU1 ON IU1.intItemId = L.intItemId and IU1.intUnitMeasureId=' + Ltrim(@intUnitMeasureId) + 
		'
		JOIN tblQMSample S ON S.intProductValueId = L.intLotId AND S.intProductTypeId = 6 
		JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId  AND ST.intControlPointId in (5,6,9)
		and S.intSampleId in (Select Max(S1.intSampleId) from tblQMSample S1 JOIN tblQMSampleType ST1 on S1.intSampleTypeId=ST1.intSampleTypeId Where S1.intSampleStatusId =3 and S1.strLotNumber=L1.strLotNumber AND S1.intProductTypeId = 6 and ST1.intControlPointId=ST.intControlPointId )
		Left JOIN @tblMFTask T on T.strLotNumber=L1.strLotNumber
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
	SET @strColumnsList = 'TransactionType,intSampleId,strSampleNumber,dtmSampleReceivedDate,intNoOfDaysInStorage,intLotId,strLotNumber'
	SET @strColumnsList = @strColumnsList + ',intItemId,strDescription,strItemNo,dblQty,strQtyUOM,dblWeight,strWeightUOM,intTotalCount'
	SET @strColumnsList = @strColumnsList + ',' + REPLACE(REPLACE(@str, '[', ''), ']', '')
	SET @SQL = @SQL + ' SELECT intTotalCount   
	,Case When intControlPointId IN (5,9) then ''GRN'' Else ''IP'' End TransactionType
	,intSampleId
	,strSampleNumber
	,dtmSampleReceivedDate
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
			,dtmSampleReceivedDate
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
