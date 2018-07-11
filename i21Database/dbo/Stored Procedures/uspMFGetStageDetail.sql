CREATE PROCEDURE uspMFGetStageDetail (@intWorkOrderId INT)
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
		AND S.strNamespace = 'Manufacturing.view.ProcessProductionConsume'
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
		intWorkOrderInputLotId INT
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
		intWorkOrderInputLotId
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
	SELECT intWorkOrderInputLotId
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
		SELECT a.intWorkOrderInputLotId
			,Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(a.intCustomTabDetailId, @strColumn1, 'strColumn1'), @strColumn2, 'strColumn2'), @strColumn3, 'strColumn3'), @strColumn4, 'strColumn4'), @strColumn5, 'strColumn5'), @strColumn6, 'strColumn6'), @strColumn7, 'strColumn7'), @strColumn8, 'strColumn8'), @strColumn9, 'strColumn9'), @strColumn10, 'strColumn10') AS strFieldName
			,a.strValue
		FROM tblMFCustomFieldValue a
		JOIN tblMFWorkOrderInputLot WI ON WI.intWorkOrderInputLotId = a.intWorkOrderInputLotId
			AND WI.intWorkOrderId = @intWorkOrderId
		WHERE a.intWorkOrderInputLotId IS NOT NULL
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

	SELECT W.intWorkOrderInputLotId
		,L.intLotId
		,L.strLotNumber
		,I.strItemNo
		,I.strDescription
		,W.dblEnteredQty AS dblQuantity
		,IU.intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,W.dtmProductionDate AS dtmCreated
		,W.intCreatedUserId
		,US.strUserName
		,W.intWorkOrderId
		,SL.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,CSL.strSubLocationName
		,IsNULL(W.intMachineId, 0) AS intMachineId
		,IsNULL(M.strName, '') AS strMachineName
		,W.ysnConsumptionReversed
		,W.strReferenceNo
		,W.dtmActualInputDateTime
		,C.intContainerId
		,C.strContainerId
		,S.intShiftId
		,S.strShiftName
		,L.intParentLotId
		,'STAGE' AS strTransactionName
		,PL.strParentLotNumber
		,1 AS intDisplayOrder
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
	FROM dbo.tblMFWorkOrderInputLot W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intEnteredItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = W.intCreatedUserId
	LEFT JOIN dbo.tblICLot L ON L.intLotId = W.intLotId
	LEFT JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = W.intMachineId
	LEFT JOIN dbo.tblICContainer C ON C.intContainerId = W.intContainerId
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intShiftId
	LEFT JOIN @tblMFCustomValue CV ON CV.intWorkOrderInputLotId = W.intWorkOrderInputLotId
	WHERE intWorkOrderId = @intWorkOrderId
	
	UNION
	
	SELECT W.intWorkOrderConsumedLotId AS intWorkOrderInputLotId
		,IsNULL(L.intLotId, 0) AS intLotId
		,IsNULL(L.strLotNumber, '') AS strLotNumber
		,I.strItemNo
		,I.strDescription
		,W.dblQuantity
		,IU.intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,W.dtmCreated
		,W.intCreatedUserId
		,US.strUserName
		,W.intWorkOrderId
		,SL.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,CSL.strSubLocationName
		,ISNULL(W.intMachineId, 0) intMachineId
		,ISNULL(M.strName, '') AS strMachineName
		,W.ysnConsumptionReversed
		,W.strReferenceNo
		,W.dtmActualInputDateTime
		,C.intContainerId
		,C.strContainerId
		,S.intShiftId
		,S.strShiftName
		,IsNULL(L.intParentLotId, 0) AS intParentLotId
		,CASE 
			WHEN intSequenceNo = 9999
				THEN 'YIELD ADJUST '
			ELSE 'CONSUME'
			END AS strTransactionName
		,PL.strParentLotNumber
		,2 AS intDisplayOrder
		,NULL AS strColumn1
		,NULL AS strColumn2
		,NULL AS strColumn3
		,NULL AS strColumn4
		,NULL AS strColumn5
		,NULL AS strColumn6
		,NULL AS strColumn7
		,NULL AS strColumn8
		,NULL AS strColumn9
		,NULL AS strColumn10
	FROM dbo.tblMFWorkOrderConsumedLot W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = W.intCreatedUserId
	LEFT JOIN dbo.tblICLot L ON L.intLotId = W.intLotId
	LEFT JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	LEFT JOIN dbo.tblMFMachine M ON M.intMachineId = W.intMachineId
	LEFT JOIN dbo.tblICContainer C ON C.intContainerId = W.intContainerId
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intShiftId
	WHERE intWorkOrderId = @intWorkOrderId
	ORDER BY intDisplayOrder
		,W.intWorkOrderInputLotId
END
