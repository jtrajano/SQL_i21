CREATE PROCEDURE [dbo].[uspBBAddTransactionLinks]
	@strBuybackIds NVARCHAR(MAX),
	@intAction INT
AS

BEGIN
	IF @intAction = 1
	BEGIN
		DECLARE @TransactionLinks udtICTransactionLinks

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
			B.intBuybackId,
			B.strReimbursementNo,
			'Buybacks',
			'Buybacks',
			I.intInvoiceId,
			I.strInvoiceNumber,
			'Invoices',
			'Accounts Receivable',
			'Submit'
		FROM dbo.fnGetRowsFromDelimitedValues(@strBuybackIds) IDS
		INNER JOIN tblBBBuyback B ON B.intBuybackId = IDS.intID
		INNER JOIN tblBBBuybackDetail BD ON BD.intBuybackId = B.intBuybackId
		INNER JOIN tblARInvoiceDetail ID ON ID.intInvoiceDetailId = BD.intInvoiceDetailId
		INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId

		EXEC uspICAddTransactionLinks @TransactionLinks
	END
	ELSE
	BEGIN
		DECLARE @ID AS TABLE (intID INT)
		DECLARE @intSrcId INT, @strSrcTransactionNo NVARCHAR(100)

		INSERT INTO @ID
		SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strBuybackIds)

		WHILE EXISTS(SELECT TOP 1 1 FROM @ID)
		BEGIN
			SELECT TOP 1 @intSrcId = B.intBuybackId, @strSrcTransactionNo = B.strReimbursementNo
			FROM @ID ID
			INNER JOIN tblBBBuyback B ON B.intBuybackId = ID.intID

			EXEC uspICDeleteTransactionLinks @intSrcId, @strSrcTransactionNo, 'Buybacks', 'Buybacks'

			DELETE FROM @ID WHERE intID = @intSrcId
		END
	END
END