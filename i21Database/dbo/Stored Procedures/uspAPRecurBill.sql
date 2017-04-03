CREATE PROCEDURE [dbo].[uspAPRecurBill]
	@billId INT,
	@billDate DATETIME,
	@userId INT,
	@newBillId NVARCHAR(50) OUTPUT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @billCreatedPrimaryKey INT;
	SET @userId = (SELECT TOP 1 [intEntityId] FROM dbo.tblSMUserSecurity WHERE [intEntityId] = @userId)
	EXEC uspAPDuplicateBill @billId, @userId, @billCreatedPrimaryKey OUTPUT

	UPDATE A
		SET A.dtmDate = @billDate
		,A.dtmBillDate = @billDate
		,A.dtmDueDate = dbo.fnGetDueDateBasedOnTerm(@billDate, A.intTermsId)
		,A.intTransactionType = 1
		,A.strVendorOrderNumber = A.strBillId
		,A.ysnRecurring = 0
		,A.strReference = RecurTran.strReference
	FROM tblAPBill A
	OUTER APPLY (
		SELECT 
			B.strReference
		FROM tblSMRecurringTransaction B
		WHERE intTransactionId = @billId AND strTransactionType = 'Voucher'
	) RecurTran
	WHERE intBillId = @billCreatedPrimaryKey

	SET @newBillId = (SELECT strBillId FROM tblAPBill WHERE intBillId = @billCreatedPrimaryKey)

END