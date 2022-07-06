CREATE PROCEDURE [dbo].[uspAPAddTransactionLinks]
	@intTransactionType INT,
	@strTransactionIds NVARCHAR(MAX),
	@intAction INT
AS

BEGIN
	DECLARE @TransactionLinks udtICTransactionLinks
	DECLARE @ID AS TABLE (intID INT)
	DECLARE @intDestId INT, @strDestTransactionNo NVARCHAR(100)

	IF NOT EXISTS(
		SELECT 1
		FROM tblAPBillDetail A
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) B ON A.intBillId = B.intID
		WHERE
			A.intInventoryReceiptItemId > 0
		OR A.intInventoryReceiptChargeId > 0
		OR A.intInventoryShipmentChargeId > 0
		OR A.intLoadDetailId > 0
		OR A.intLoadShipmentCostId > 0
		OR A.intSettleStorageId > 0
	)
	BEGIN
		RETURN;
	END

	--VOUCHER
	IF @intTransactionType = 1
	BEGIN
		IF @intAction = 1
		BEGIN
			INSERT INTO @TransactionLinks (
				intSrcId,
				strSrcTransactionNo,
				strSrcTransactionType,
				strSrcModuleName,
				intDestId,
				strDestTransactionNo,
				strDestTransactionType,
				strDestModuleName,
				strOperation
			)
			SELECT
				ST.intSourceTransactionId,
				ST.strSourceTransaction,
				ST.strSourceTransactionType,
				ST.strSourceModule,
				B.intBillId,
				B.strBillId,
				'Voucher',
				'Accounts Payable',
				'Create'
			FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) IDS
			INNER JOIN tblAPBill B ON B.intBillId = IDS.intID
			INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
			CROSS APPLY fnAPGetDetailSourceTransaction(BD.intInventoryReceiptItemId, BD.intInventoryReceiptChargeId, BD.intInventoryShipmentChargeId, BD.intLoadDetailId, BD.intLoadShipmentCostId, BD.intCustomerStorageId, BD.intSettleStorageId, BD.intBillId, BD.intItemId) ST

			EXEC uspICAddTransactionLinks @TransactionLinks
		END
		ELSE
		BEGIN
			INSERT INTO @ID
			SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds)

			WHILE EXISTS(SELECT TOP 1 1 FROM @ID)
			BEGIN
				SELECT TOP 1 @intDestId = B.intBillId, @strDestTransactionNo = B.strBillId
				FROM @ID ID
				INNER JOIN tblAPBill B ON B.intBillId = ID.intID

				IF @intDestId IS NULL
				BEGIN
					RAISERROR('Error occured while updating Voucher Traceability.', 16, 1);
					RETURN;
				END
				ELSE
				BEGIN
					EXEC uspICDeleteTransactionLinks @intDestId, @strDestTransactionNo, 'Voucher', 'Accounts Payable'
					DELETE FROM @ID WHERE intID = @intDestId
				END
			END
		END
	END

	--PAYMENT
	IF @intTransactionType = 2
	BEGIN
		IF @intAction = 1
		BEGIN
			INSERT INTO @TransactionLinks (
				intSrcId,
				strSrcTransactionNo,
				strSrcTransactionType,
				strSrcModuleName,
				intDestId,
				strDestTransactionNo,
				strDestTransactionType,
				strDestModuleName,
				strOperation
			)
			SELECT
				CASE WHEN I.intInvoiceId IS NOT NULL THEN I.intInvoiceId ELSE B.intBillId END,
				CASE WHEN I.intInvoiceId IS NOT NULL THEN I.strInvoiceNumber ELSE B.strBillId END,
				CASE WHEN I.intInvoiceId IS NOT NULL THEN 'Invoice' ELSE 'Voucher' END,
				'Accounts Payable',
				P.intPaymentId,
				P.strPaymentRecordNum,
				'Payment',
				'Accounts Payable',
				'Create'
			FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) IDS
			INNER JOIN tblAPPayment P ON P.intPaymentId = IDS.intID
			INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
			LEFT JOIN tblAPBill B ON B.intBillId = PD.intBillId
			LEFT JOIN tblARInvoice I ON I.intInvoiceId = PD.intInvoiceId

			EXEC uspICAddTransactionLinks @TransactionLinks
		END
		ELSE
		BEGIN
			INSERT INTO @ID
			SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds)

			WHILE EXISTS(SELECT TOP 1 1 FROM @ID)
			BEGIN
				SELECT TOP 1 @intDestId = P.intPaymentId, @strDestTransactionNo = P.strPaymentRecordNum
				FROM @ID ID
				INNER JOIN tblAPPayment P ON P.intPaymentId = ID.intID


				IF @intDestId IS NULL
				BEGIN
					RAISERROR('Error occured while updating Payment Traceability.', 16, 1);
					RETURN;
				END
				ELSE
				BEGIN
					EXEC uspICDeleteTransactionLinks @intDestId, @strDestTransactionNo, 'Payment', 'Accounts Payable'
					DELETE FROM @ID WHERE intID = @intDestId
				END
			END
		END
	END
END