CREATE PROCEDURE uspMFGetProductionDetail (@intWorkOrderId INT)
AS
BEGIN
	DECLARE @strColumn1 NVARCHAR(100)
		,@strColumn2 NVARCHAR(100)
		,@strColumn3 NVARCHAR(100)
		,@strColumn4 NVARCHAR(100)
		,@strColumn5 NVARCHAR(100)
		,@strColumn6 NVARCHAR(100)
		,@strColumn7 NVARCHAR(100)
		,@strColumn8 NVARCHAR(100)
		,@strColumn9 NVARCHAR(100)
		,@strColumn10 NVARCHAR(100)
		,@dtmOrderDate DATETIME
		,@intItemId INT
		,@intManufacturingProcessId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@strProcessName NVARCHAR(50)
		,@strDescription NVARCHAR(250)
		,@strTargetItemNo NVARCHAR(50)
		,@strTargetDescription NVARCHAR(250)

	SELECT @strColumn1 = ''
		,@strColumn2 = ''
		,@strColumn3 = ''
		,@strColumn4 = ''
		,@strColumn5 = ''
		,@strColumn6 = ''
		,@strColumn7 = ''
		,@strColumn8 = ''
		,@strColumn9 = ''
		,@strColumn10 = ''

	DECLARE @tblMFCustomTable TABLE (
		intRecordId INT identity(1, 1)
		,strFieldName NVARCHAR(50)
		)

	INSERT INTO @tblMFCustomTable (strFieldName)
	SELECT TD.intCustomTabDetailId
	FROM tblSMScreen S
	JOIN tblSMCustomTab T ON T.intScreenId = S.intScreenId
		AND S.strNamespace = 'Manufacturing.view.ProcessProductionProduce'
	JOIN tblSMCustomTabDetail TD ON TD.intCustomTabId = T.intCustomTabId
		AND TD.strFieldName <> 'Id'
	ORDER BY TD.intCustomTabDetailId

	SELECT @strColumn1 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 1

	SELECT @strColumn2 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 2

	SELECT @strColumn3 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 3

	SELECT @strColumn4 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 4

	SELECT @strColumn5 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 5

	SELECT @strColumn6 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 6

	SELECT @strColumn7 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 7

	SELECT @strColumn8 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 8

	SELECT @strColumn9 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 9

	SELECT @strColumn10 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 10

	DECLARE @tblMFCustomValue TABLE (
		intWorkOrderProducedLotId INT
		,strColumn1 NVARCHAR(100)
		,strColumn2 NVARCHAR(100)
		,strColumn3 NVARCHAR(100)
		,strColumn4 NVARCHAR(100)
		,strColumn5 NVARCHAR(100)
		,strColumn6 NVARCHAR(100)
		,strColumn7 NVARCHAR(100)
		,strColumn8 NVARCHAR(100)
		,strColumn9 NVARCHAR(100)
		,strColumn10 NVARCHAR(100)
		)

	INSERT INTO @tblMFCustomValue (
		intWorkOrderProducedLotId
		,strColumn1
		,strColumn2
		,strColumn3
		,strColumn4
		,strColumn5
		,strColumn6
		,strColumn7
		,strColumn8
		,strColumn9
		,strColumn10
		)
	SELECT intWorkOrderProducedLotId
		,strColumn1
		,strColumn2
		,strColumn3
		,strColumn4
		,strColumn5
		,strColumn6
		,strColumn7
		,strColumn8
		,strColumn9
		,strColumn10
	FROM (
		SELECT a.intWorkOrderProducedLotId
			,Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(a.intCustomTabDetailId, @strColumn1, 'strColumn1'), @strColumn2, 'strColumn2'), @strColumn3, 'strColumn3'), @strColumn4, 'strColumn4'), @strColumn5, 'strColumn5'), @strColumn6, 'strColumn6'), @strColumn7, 'strColumn7'), @strColumn8, 'strColumn8'), @strColumn9, 'strColumn9'), @strColumn10, 'strColumn10') AS strFieldName
			,a.strValue
		FROM tblMFCustomFieldValue a
		JOIN tblMFWorkOrderProducedLot WP ON WP.intWorkOrderProducedLotId = a.intWorkOrderProducedLotId
			AND WP.intWorkOrderId = @intWorkOrderId
		WHERE a.intWorkOrderProducedLotId IS NOT NULL
		) AS SourceTable
	PIVOT(MAX(strValue) FOR strFieldName IN (
				strColumn1
				,strColumn2
				,strColumn3
				,strColumn4
				,strColumn5
				,strColumn6
				,strColumn7
				,strColumn8
				,strColumn9
				,strColumn10
				)) AS PivotTable

	SELECT @intItemId = intItemId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@strWorkOrderNo = strWorkOrderNo
		,@dtmOrderDate = dtmOrderDate
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strProcessName = strProcessName
		,@strDescription = strDescription
	FROM tblMFManufacturingProcess
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	SELECT @strTargetItemNo = strItemNo
		,@strTargetDescription = strDescription
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT W.intWorkOrderProducedLotId
		,L.intLotId
		,L.strLotNumber
		,I.strItemNo
		,I.strDescription
		,W.dblQuantity
		,W.dblQuantity + W.dblTareWeight AS dblGrossWeight
		,W.dblTareWeight
		,W.dblWeightPerUnit
		,IU.intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,W.dblPhysicalCount AS dblPack
		,IU1.intItemUOMId intPackItemUOMId
		,U1.intUnitMeasureId intPackUnitMeasureId
		,U1.strUnitMeasure strPackUOM
		,W.dtmProductionDate
		,W.dtmCreated
		,W.intCreatedUserId
		,US.strUserName
		,W.intWorkOrderId
		,SL.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,CSL.strSubLocationName
		,ISNULL(W.intMachineId, 0) AS intMachineId
		,ISNULL(M.strName, '') AS strMachineName
		,W.ysnProductionReversed
		,W.strReferenceNo
		,C.intContainerId
		,C.strContainerId
		,S.intShiftId
		,S.strShiftName
		,W.intBatchId
		,L.intParentLotId
		,W.strBatchId
		,W.ysnFillPartialPallet
		,I.intCategoryId
		,LS.strSecondaryStatus AS strLotStatus
		,W.strParentLotNumber
		,L1.strLotNumber AS strSpecialPalletId
		,LS.strBackColor
		,W.ysnReleased
		,CV.strColumn1
		,CV.strColumn2
		,CV.strColumn3
		,CV.strColumn4
		,CV.strColumn5
		,CV.strColumn6
		,CV.strColumn7
		,CV.strColumn8
		,CV.strColumn9
		,CV.strColumn10
		,@strProcessName AS strProcessName
		,@strDescription AS strProcessDescription
		,@strWorkOrderNo AS strWorkOrderNo
		,@dtmOrderDate AS strWorkOrderDate
		,@strTargetItemNo AS strTargetItemNo
		,@strTargetDescription AS strTargetDescription
		,L.dblLastCost 
		,W.dblItemValue 
	FROM dbo.tblMFWorkOrderProducedLot W
	LEFT JOIN dbo.tblICLot L ON L.intLotId = W.intLotId
	--LEFT JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = W.intPhysicalItemUOMId
	JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU1.intUnitMeasureId
	JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = W.intCreatedUserId
	LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = W.intMachineId
	LEFT JOIN dbo.tblICContainer C ON C.intContainerId = W.intContainerId
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intShiftId
	LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	LEFT JOIN dbo.tblICLot L1 ON L1.intLotId = W.intSpecialPalletLotId
	LEFT JOIN @tblMFCustomValue CV ON CV.intWorkOrderProducedLotId = W.intWorkOrderProducedLotId
	WHERE intWorkOrderId = @intWorkOrderId
	ORDER BY W.intWorkOrderProducedLotId
END
