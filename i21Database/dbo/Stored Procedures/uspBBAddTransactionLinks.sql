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
			I.intInvoiceId,
			I.strInvoiceNumber,
			'Invoice',
			'Accounts Receivable',
			B.intBuybackId,
			B.strReimbursementNo,
			'Buyback',
			'Buybacks',
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
		DECLARE @intDestId INT, @strDestTransactionNo NVARCHAR(100)

		INSERT INTO @ID
		SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strBuybackIds)

		WHILE EXISTS(SELECT TOP 1 1 FROM @ID)
		BEGIN
			SELECT TOP 1 @intDestId = B.intBuybackId, @strDestTransactionNo = B.strReimbursementNo
			FROM @ID ID
			INNER JOIN tblBBBuyback B ON B.intBuybackId = ID.intID

			EXEC uspICDeleteTransactionLinks @intDestId, @strDestTransactionNo, 'Buyback', 'Buybacks'

			DELETE FROM @ID WHERE intID = @intDestId
		END
	END
END