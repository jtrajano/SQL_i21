CREATE PROCEDURE uspMFReportDailyProduction @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@dtmStartDate DATETIME
		,@dtmEndDate DATETIME
		,@dtmStartDate1 DATETIME
		,@dtmEndDate1 DATETIME
		,@intLocationId INT
		,@xmlDocumentId INT
		,@strLocationName nvarchar(50)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
			[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @dtmStartDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmStartDate'

	SELECT @dtmEndDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmEndDate'

	SELECT @dtmStartDate1 = @dtmStartDate
		,@dtmEndDate1 = @dtmEndDate

	SELECT @strLocationName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strLocationName'

	SELECT @intLocationId=intCompanyLocationId FROM dbo.tblSMCompanyLocation WHERE strLocationName=@strLocationName

	DECLARE @dtmShiftStartTime DATETIME
		,@dtmShiftEndTime DATETIME
		,@strCompanyName NVARCHAR(50)

	SELECT @strCompanyName = strCompanyName
	FROM dbo.tblSMCompanySetup

	SELECT TOP 1 @dtmShiftStartTime = dtmShiftStartTime + intStartOffset
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
	ORDER BY intShiftSequence ASC

	SELECT @dtmStartDate = @dtmStartDate + @dtmShiftStartTime

	SELECT TOP 1 @dtmShiftEndTime = dtmShiftEndTime + intEndOffset
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
	ORDER BY intShiftSequence DESC

	SELECT @dtmEndDate = @dtmEndDate + @dtmShiftEndTime

	SELECT L.strLotNumber
		,LT.dtmDate
		,LT.dtmCreated
		,LTT.strName
		,I.strItemNo
		,I.strDescription
		,LT.dblQty
		,UM.strUnitMeasure
		,SL.strName AS strStorageLocationName
		,@strCompanyName AS strCompanyName
		,@dtmStartDate1 AS dtmStartDate
		,@dtmEndDate1 AS dtmEndDate
		,'' AS strShiftName
		,L.dtmExpiryDate
		,LS.strSecondaryStatus 
	INTO #tblMFDailyProduction
	FROM dbo.tblICLot L
	JOIN dbo.tblICInventoryLotTransaction LT ON L.intLotId = LT.intLotId
	JOIN dbo.tblICInventoryTransactionType LTT ON LT.intTransactionTypeId = LTT.intTransactionTypeId
	JOIN dbo.tblICLotStatus  LS on L.intLotStatusId =LS.intLotStatusId 
	JOIN dbo.tblICItem I ON L.intItemId = I.intItemId
	JOIN dbo.tblICItemUOM IU ON L.intItemUOMId = IU.intItemUOMId
	JOIN dbo.tblICStorageLocation SL ON L.intStorageLocationId = SL.intStorageLocationId
	JOIN dbo.tblICUnitMeasure UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
	WHERE LT.intTransactionTypeId = 9
		AND dtmDate >= @dtmStartDate
		AND dtmDate <= @dtmEndDate
		AND LT.dblQty > 0
	
	UNION
	
	SELECT L.strLotNumber
		,LT.dtmDate
		,LT.dtmCreated
		,LTT.strName
		,I.strItemNo
		,I.strDescription
		,LT.dblQty
		,UM.strUnitMeasure
		,SL.strName
		,@strCompanyName AS strCompanyName
		,@dtmStartDate1 AS dtmStartDate
		,@dtmEndDate1 AS dtmEndDate
		,'' AS strShiftName
		,L.dtmExpiryDate
		,LS.strSecondaryStatus
	FROM dbo.tblICLot L
	JOIN dbo.tblICInventoryLotTransaction LT ON L.intLotId = LT.intLotId
	JOIN dbo.tblICInventoryTransactionType LTT ON LT.intTransactionTypeId = LTT.intTransactionTypeId
	JOIN dbo.tblICLotStatus  LS on L.intLotStatusId =LS.intLotStatusId 
	JOIN dbo.tblICItem I ON L.intItemId = I.intItemId
	JOIN dbo.tblICItemUOM IU ON L.intItemUOMId = IU.intItemUOMId
	JOIN dbo.tblICStorageLocation SL ON L.intStorageLocationId = SL.intStorageLocationId
	JOIN dbo.tblICUnitMeasure UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
	WHERE LT.intTransactionTypeId = 9
		AND dtmDate >= @dtmStartDate
		AND dtmDate <= @dtmEndDate
		AND LT.dblQty < 0
	
	UNION
	
	SELECT L.strLotNumber
		,A.dtmAdjustmentDate
		,A.dtmAdjustmentDate
		,LTT.strName
		,I.strItemNo
		,I.strDescription
		,- AD.dblQuantity
		,UM.strUnitMeasure
		,SL.strName
		,@strCompanyName AS strCompanyName
		,@dtmStartDate1 AS dtmStartDate
		,@dtmEndDate1 AS dtmEndDate
		,'' AS strShiftName
		,L.dtmExpiryDate
		,LS.strSecondaryStatus
	FROM tblICInventoryAdjustment A
	JOIN tblICInventoryAdjustmentDetail AD ON A.intInventoryAdjustmentId = AD.intInventoryAdjustmentId
	JOIN tblICLot L ON AD.intLotId = L.intLotId
	JOIN dbo.tblICInventoryTransactionType LTT ON A.intAdjustmentType = LTT.intTransactionTypeId
	JOIN dbo.tblICLotStatus  LS on L.intLotStatusId =LS.intLotStatusId 
	JOIN dbo.tblICItem I ON L.intItemId = I.intItemId
	JOIN dbo.tblICItemUOM IU ON L.intItemUOMId = IU.intItemUOMId
	JOIN dbo.tblICStorageLocation SL ON L.intStorageLocationId = SL.intStorageLocationId
	JOIN dbo.tblICUnitMeasure UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
	WHERE A.intAdjustmentType = 15
		AND A.dtmAdjustmentDate >= @dtmStartDate
		AND A.dtmAdjustmentDate <= @dtmEndDate
	
	UNION
	
	SELECT L.strLotNumber
		,A.dtmAdjustmentDate
		,A.dtmAdjustmentDate
		,LTT.strName
		,I.strItemNo
		,I.strDescription
		,AD.dblQuantity
		,UM.strUnitMeasure
		,SL.strName
		,@strCompanyName AS strCompanyName
		,@dtmStartDate1 AS dtmStartDate
		,@dtmEndDate1 AS dtmEndDate
		,'' AS strShiftName
		,L.dtmExpiryDate
		,LS.strSecondaryStatus
	FROM tblICInventoryAdjustment A
	JOIN tblICInventoryAdjustmentDetail AD ON A.intInventoryAdjustmentId = AD.intInventoryAdjustmentId
	JOIN tblICLot L ON AD.intLotId = L.intLotId
	JOIN dbo.tblICInventoryTransactionType LTT ON A.intAdjustmentType = LTT.intTransactionTypeId
	JOIN dbo.tblICLotStatus  LS on L.intLotStatusId =LS.intLotStatusId 
	JOIN dbo.tblICItem I ON AD.intNewItemId = I.intItemId
	JOIN dbo.tblICItemUOM IU ON L.intItemUOMId = IU.intItemUOMId
	JOIN dbo.tblICStorageLocation SL ON L.intStorageLocationId = SL.intStorageLocationId
	JOIN dbo.tblICUnitMeasure UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
	WHERE A.intAdjustmentType = 15
		AND A.dtmAdjustmentDate >= @dtmStartDate
		AND A.dtmAdjustmentDate <= @dtmEndDate

	SELECT DP.*
		,(
			SELECT Count(DISTINCT DP1.strLotNumber)
			FROM #tblMFDailyProduction DP1
			) AS intNoOfPallets
	FROM #tblMFDailyProduction DP
	ORDER BY DP.dtmCreated

	EXEC sp_xml_removedocument @xmlDocumentId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFReportProductSpecification - ' + ERROR_MESSAGE()

	IF @xmlDocumentId <> 0
		EXEC sp_xml_removedocument @xmlDocumentId

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


