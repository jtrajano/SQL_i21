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

	SELECT 944 AS strTransactionId
		,'Wholesome Sweetners' AS strCustomerId
		,'J' AS strType
		,dtmReceiptDate dtmDate
		,strReceiptNumber strWarehouseReceiptNumber
		,strWarehouseRefNo strDepositorOrderNumber
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
		,SUm(dblReceived) OVER (PARTITION BY IR.intInventoryReceiptId) dblTotalReceivedQty
		,strItemNo
		,strDescription
		,dblReceived
		,I.strExternalGroup
	FROM dbo.tblICInventoryReceipt IR
	JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
	JOIN tblICItem I ON I.intItemId = IRI.intItemId
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
