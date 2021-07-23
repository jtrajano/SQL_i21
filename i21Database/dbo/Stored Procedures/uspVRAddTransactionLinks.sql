CREATE PROCEDURE [dbo].[uspVRAddTransactionLinks]
	@strRebateIds NVARCHAR(MAX),
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
			R.intRebateId,
			P.strProgram,
			'Rebate',
			'Vendor Rebates',
			'Submit'
		FROM dbo.fnGetRowsFromDelimitedValues(@strRebateIds) IDS
		INNER JOIN tblVRRebate R ON R.intRebateId = IDS.intID
		INNER JOIN tblVRProgram P ON P.intProgramId = R.intProgramId
		INNER JOIN tblARInvoiceDetail ID ON ID.intInvoiceDetailId = R.intInvoiceDetailId
		INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId

		EXEC uspICAddTransactionLinks @TransactionLinks
	END
	ELSE
	BEGIN
		DECLARE @ID AS TABLE (intID INT)
		DECLARE @intDestId INT, @strSrcTransactionNo NVARCHAR(100)

		INSERT INTO @ID
		SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strRebateIds)

		WHILE EXISTS(SELECT TOP 1 1 FROM @ID)
		BEGIN
			SELECT TOP 1 @intDestId = R.intRebateId, @strSrcTransactionNo = P.strProgram
			FROM @ID ID
			INNER JOIN tblVRRebate R ON R.intRebateId = ID.intID
			INNER JOIN tblVRProgram P ON P.intProgramId = R.intProgramId

			EXEC uspICDeleteTransactionLinks @intDestId, @strSrcTransactionNo, 'Rebate', 'Vendor Rebates'

			DELETE FROM @ID WHERE intID = @intDestId
		END
	END
END