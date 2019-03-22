CREATE PROCEDURE uspMFSendNotificationEDI944
AS
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM tblMFEDI944Error
			WHERE ysnNotify = 1
				AND IsNULL(ysnSentEMail, 0) = 0
			)
	BEGIN
		RAISERROR (
				'No data.'
				,16
				,1
				)

		RETURN
	END

	SELECT strTransactionId
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
	FROM tblMFEDI944Error
	WHERE ysnNotify = 1
		AND IsNULL(ysnSentEMail, 0) = 0

	UPDATE tblMFEDI944Error
	SET ysnSentEMail = 1
	WHERE ysnNotify = 1
		AND IsNULL(ysnSentEMail, 0) = 0
END

