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
	SELECT IR.intInventoryReceiptId
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
		,EDI.strShipmentId AS strShipmentId
		,EDI.dtmDate AS dtmShippedDate
		,[dbo].[fnRemoveTrailingZeroes](SUM(IRI.dblOpenReceive) OVER (PARTITION BY IR.intInventoryReceiptId)) dblTotalReceivedQty
		,I.strItemNo
		,I.strDescription
		,[dbo].[fnRemoveTrailingZeroes](IRI.dblOpenReceive) dblReceived
		,EDI.strUOM
	FROM dbo.tblICInventoryReceipt IR
	JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
		AND IR.ysnPosted = 1
	JOIN tblICItem I ON I.intItemId = IRI.intItemId
	LEFT JOIN tblMFEDI943Archive EDI ON EDI.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
		AND EDI.intEDI943Id IN (
			SELECT MAX(EDI1.intEDI943Id)
			FROM tblMFEDI943Archive EDI1
			WHERE EDI1.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
			)
	WHERE EXISTS (
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
