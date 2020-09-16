CREATE PROCEDURE uspMFProcessEDI944 (@strReceiptNumber NVARCHAR(50) = NULL)
AS
BEGIN
	DECLARE @tblMFOrderNo TABLE (
		intInventoryReceiptId INT
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @intCustomerId INT
		,@strType NVARCHAR(1)
		,@strOrderStatus NVARCHAR(2)
		,@strName NVARCHAR(50)
		,@strOrderNo NVARCHAR(50)
		,@strShipmentId NVARCHAR(50)
		,@dtmDate DATETIME
		,@strError NVARCHAR(MAX)

	--IF @strReceiptNumber = ''
	--BEGIN
	--	INSERT INTO @tblMFOrderNo (
	--		intInventoryReceiptId
	--		,strOrderNo
	--		,strReceiptNumber
	--		)
	--	SELECT TOP 1 IR.intInventoryReceiptId
	--		,IR.strWarehouseRefNo
	--		,IR.strReceiptNumber
	--	FROM tblICInventoryReceipt IR
	--	WHERE ysnPosted = 1
	--		AND EXISTS (
	--			SELECT *
	--			FROM tblMFEDI943Archive EDI943
	--			WHERE EDI943.strDepositorOrderNumber = IR.strWarehouseRefNo
	--			)
	--		AND NOT EXISTS (
	--			SELECT *
	--			FROM tblMFEDI944 EDI944
	--			WHERE EDI944.ysnStatus = 1
	--				AND EDI944.intInventoryReceiptId = IR.intInventoryReceiptId
	--			)
	--	ORDER BY IR.intInventoryReceiptId
	--END
	--ELSE
	--BEGIN
	--	INSERT INTO @tblMFOrderNo (
	--		intInventoryReceiptId
	--		,strOrderNo
	--		,strReceiptNumber
	--		)
	--	SELECT TOP 1 IR.intInventoryReceiptId
	--		,IR.strWarehouseRefNo
	--		,IR.strReceiptNumber
	--	FROM tblICInventoryReceipt IR
	--	WHERE ysnPosted = 1
	--		AND EXISTS (
	--			SELECT *
	--			FROM tblMFEDI943Archive EDI943
	--			WHERE EDI943.strDepositorOrderNumber = IR.strWarehouseRefNo
	--			)
	--		AND IR.strReceiptNumber = @strReceiptNumber
	--	ORDER BY IR.intInventoryReceiptId
	--END
	IF @strReceiptNumber IS NULL
	BEGIN
		INSERT INTO @tblMFOrderNo (
			intInventoryReceiptId
			,strOrderNo
			,strReceiptNumber
			)
		SELECT TOP 1 IR.intInventoryReceiptId
			,IR.strWarehouseRefNo
			,IR.strReceiptNumber
		FROM tblMFEDIStage944 EDI
		JOIN tblICInventoryReceipt IR ON EDI.intInventoryReceiptId = IR.intInventoryReceiptId
		WHERE IR.ysnPosted = 1
			AND EDI.intStatusId = 0
		ORDER BY IR.intInventoryReceiptId

		IF NOT EXISTS (
				SELECT *
				FROM @tblMFOrderNo
				)
		BEGIN
			INSERT INTO @tblMFOrderNo (
				intInventoryReceiptId
				,strOrderNo
				,strReceiptNumber
				)
			SELECT TOP 1 IR.intInventoryReceiptId
				,IR.strWarehouseRefNo
				,IR.strReceiptNumber
			FROM tblMFEDIStage944 EDI
			JOIN tblICInventoryReceipt IR ON EDI.intInventoryReceiptId = IR.intInventoryReceiptId
			WHERE IR.ysnPosted = 1
			ORDER BY IR.intInventoryReceiptId
		END
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFOrderNo (
			intInventoryReceiptId
			,strOrderNo
			,strReceiptNumber
			)
		SELECT TOP 1 IR.intInventoryReceiptId
			,IR.strWarehouseRefNo
			,IR.strReceiptNumber
		FROM tblICInventoryReceipt IR
		WHERE ysnPosted = 1
			AND EXISTS (
				SELECT *
				FROM tblMFEDI943Archive EDI943
				WHERE EDI943.strDepositorOrderNumber = IR.strWarehouseRefNo
				)
			AND IR.strReceiptNumber = @strReceiptNumber
		ORDER BY IR.intInventoryReceiptId
	END

	IF NOT EXISTS (
			SELECT *
			FROM @tblMFOrderNo
			)
	BEGIN
		RAISERROR (
				'No data to export.'
				,16
				,1
				)

		RETURN
	END

	DECLARE @tblMFEDI944 TABLE (
		intRecordId INT
		,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strCustomerId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strType CHAR(1) COLLATE Latin1_General_CI_AS
		,dtmDate DATETIME
		,strWarehouseReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strDepositorOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strShipmentId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmShippedDate DATETIME
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
		,dblReceived NUMERIC(38, 20)
		,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	SELECT @intCustomerId = intCustomerId
		,@strType = strType
	FROM tblMFEDIPreference
	WHERE strTransactionId = '944'

	IF @strType IS NULL
	BEGIN
		SELECT @strType = ''
	END

	SELECT @strName = strName
	FROM tblEMEntity
	WHERE intEntityId = @intCustomerId

	IF @strName IS NULL
	BEGIN
		SELECT @strName = ''
	END

	SELECT @strOrderNo = strOrderNo
	FROM @tblMFOrderNo

	SELECT TOP 1 @strShipmentId = strShipmentId
		,@dtmDate = dtmDate
	FROM tblMFEDI943Archive
	WHERE strDepositorOrderNumber = @strOrderNo
	ORDER BY intEDI943Id DESC

	INSERT INTO @tblMFEDI944 (
		intRecordId
		,strTransactionId
		,strCustomerId
		,strType
		,dtmDate
		,strWarehouseReceiptNumber
		,strDepositorOrderNumber
		,strShipmentId
		,dtmShippedDate
		,strItemNo
		,strDescription
		,dblReceived
		,strUOM
		,strParentLotNumber
		)
	SELECT IRI.intInventoryReceiptItemId
		,944 AS strTransactionId
		,@strName AS strCustomerId
		,@strType AS strType
		,IR.dtmReceiptDate AS dtmDate
		,IR.strReceiptNumber strWarehouseReceiptNumber
		,IR.strWarehouseRefNo strDepositorOrderNumber
		,IsNULL(EDI.strShipmentId, @strShipmentId) AS strShipmentId
		,IsNULL(EDI.dtmDate, @dtmDate) AS dtmShippedDate
		,I.strItemNo
		,I.strDescription
		,SUM(CASE 
				WHEN IsNULL(UM.strUnitType, '') = 'Weight'
					THEN IsNULL(IRL.dblGrossWeight, 0) - IsNULL(IRL.dblTareWeight, 0)
				ELSE IRL.dblQuantity
				END) dblReceived
		,IsNULL(IsNULL(EDI.strUOM, (
					SELECT TOP 1 Arc.strUOM
					FROM tblMFEDI943Archive Arc
					WHERE Arc.strVendorItemNumber = I.strItemNo
					)), I.strMask3) AS strUOM
		,IRL.strParentLotNumber
	FROM dbo.tblICInventoryReceipt IR
	JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
	JOIN dbo.tblICInventoryReceiptItemLot IRL ON IRL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
		AND IR.ysnPosted = 1
	JOIN tblICItem I ON I.intItemId = IRI.intItemId
	LEFT JOIN tblMFEDI943Archive EDI ON EDI.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
		AND EDI.intEDI943Id IN (
			SELECT MAX(EDI1.intEDI943Id)
			FROM tblMFEDI943Archive EDI1
			WHERE EDI1.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
			)
	LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = EDI.strUOM
	LEFT JOIN tblICItemUOM IU ON UM.intUnitMeasureId = IU.intUnitMeasureId
		AND I.intItemId = IU.intItemId
	WHERE EXISTS (
			SELECT *
			FROM @tblMFOrderNo O
			WHERE O.strOrderNo = IR.strWarehouseRefNo
			)
	GROUP BY IR.dtmReceiptDate
		,IR.strReceiptNumber
		,IR.strWarehouseRefNo
		,EDI.strShipmentId
		,EDI.dtmDate
		,I.strItemNo
		,I.strDescription
		,EDI.strUOM
		,IRL.strParentLotNumber
		,IRI.intInventoryReceiptItemId
		,I.strMask3
	ORDER BY IRI.intInventoryReceiptItemId

	IF EXISTS (
			SELECT *
			FROM @tblMFEDI944 EDI
			WHERE strUOM IS NULL
				OR LTRIM(RTRIM(strUOM)) = ''
			)
	BEGIN
		INSERT INTO tblMFEDI944Error (
			strTransactionId
			,strCustomerId
			,strType
			,dtmDate
			,strWarehouseReceiptNumber
			,strDepositorOrderNumber
			,strShipmentId
			,dtmShippedDate
			,dblTotalReceivedQty
			,strItemNo
			,strDescription
			,dblReceived
			,strUOM
			,strParentLotNumber
			,ysnNotify
			,ysnSentEMail
			)
		SELECT strTransactionId
			,strCustomerId
			,strType
			,rtrim(Convert(CHAR, dtmDate, 101)) AS dtmDate
			,strWarehouseReceiptNumber
			,strDepositorOrderNumber
			,strShipmentId
			,rtrim(Convert(CHAR, dtmShippedDate, 101)) AS dtmShippedDate
			,[dbo].[fnRemoveTrailingZeroes](SUM(dblReceived) OVER (PARTITION BY strWarehouseReceiptNumber)) dblTotalReceivedQty
			,strItemNo
			,strDescription
			,[dbo].[fnRemoveTrailingZeroes](dblReceived) AS dblReceived
			,strUOM
			,strParentLotNumber
			,1
			,0
		FROM @tblMFEDI944
		ORDER BY intRecordId

		SELECT @strReceiptNumber = strReceiptNumber
		FROM @tblMFOrderNo

		SELECT @strError = 'UOM is missing for the inventory receipt # ' + @strReceiptNumber

		RAISERROR (
				@strError
				,16
				,1
				)

		RETURN
	END

	SELECT strTransactionId
		,strCustomerId
		,strType
		,rtrim(Convert(CHAR, dtmDate, 101)) AS dtmDate
		,strWarehouseReceiptNumber
		,strDepositorOrderNumber
		,strShipmentId
		,rtrim(Convert(CHAR, dtmShippedDate, 101)) AS dtmShippedDate
		,[dbo].[fnRemoveTrailingZeroes](SUM(dblReceived) OVER (PARTITION BY strWarehouseReceiptNumber)) dblTotalReceivedQty
		,strItemNo
		,strDescription
		,[dbo].[fnRemoveTrailingZeroes](dblReceived) AS dblReceived
		,strUOM
		,strParentLotNumber
	FROM @tblMFEDI944
	ORDER BY intRecordId

	INSERT INTO tblMFEDI944 (
		intInventoryReceiptId
		,strDepositorOrderNumber
		,ysnStatus
		)
	SELECT intInventoryReceiptId
		,strOrderNo
		,1
	FROM @tblMFOrderNo

	DELETE EDI
	FROM tblMFEDIStage944 EDI
	JOIN @tblMFOrderNo O ON EDI.intInventoryReceiptId = O.intInventoryReceiptId
END
