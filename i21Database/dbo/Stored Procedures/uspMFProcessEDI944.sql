CREATE PROCEDURE uspMFProcessEDI944
AS
BEGIN
	DECLARE @tblMFOrderNo TABLE (
		intInventoryReceiptId INT
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @tblMFOrderNo (
		intInventoryReceiptId
		,strOrderNo
		)
	SELECT TOP 1 IR.intInventoryReceiptId
		,IR.strWarehouseRefNo
	FROM tblICInventoryReceipt IR
	WHERE ysnPosted = 1
		AND EXISTS (
			SELECT *
			FROM tblMFEDI943Archive EDI943
			WHERE EDI943.strDepositorOrderNumber = IR.strWarehouseRefNo
			)
		AND NOT EXISTS (
			SELECT *
			FROM tblMFEDI944 EDI944
			WHERE EDI944.intInventoryReceiptId = IR.intInventoryReceiptId
			)
	ORDER BY IR.intInventoryReceiptId

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

	SELECT 944 AS strTransactionId
		,'Wholesome Sweetners' AS strCustomerId
		,'J' AS strType
		,IR.dtmReceiptDate dtmDate
		,IR.strReceiptNumber strWarehouseReceiptNumber
		,IR.strWarehouseRefNo strDepositorOrderNumber
		,(
			SELECT TOP 1 strShipmentId
			FROM tblMFEDI943Archive EDI943
			WHERE EDI943.intInventoryReceiptId = IR.intInventoryReceiptId
			) AS strShipmentId
		,(
			SELECT TOP 1 dtmDate
			FROM tblMFEDI943Archive EDI943
			WHERE EDI943.intInventoryReceiptId = IR.intInventoryReceiptId
			) AS dtmShippedDate
		,[dbo].[fnRemoveTrailingZeroes](SUM(IRI.dblOpenReceive) OVER (PARTITION BY IR.intInventoryReceiptId)) dblTotalReceivedQty
		,I.strItemNo
		,I.strDescription
		,[dbo].[fnRemoveTrailingZeroes](IRI.dblOpenReceive) dblReceived
		,UM.strUnitMeasure strUOM
	FROM dbo.tblICInventoryReceipt IR
	JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
		AND IR.ysnPosted = 1
	JOIN tblICItem I ON I.intItemId = IRI.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = IRI.intUnitMeasureId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		AND EXISTS (
			SELECT *
			FROM @tblMFOrderNo O
			WHERE O.strOrderNo = IR.strWarehouseRefNo
			)

	INSERT INTO tblMFEDI944 (
		intInventoryReceiptId
		,strDepositorOrderNumber
		)
	SELECT intInventoryReceiptId
		,strOrderNo
	FROM @tblMFOrderNo
END
