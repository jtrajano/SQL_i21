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
	EXEC uspAPDuplicateBill @billId, @userId, @billCreatedPrimaryKey OUTPUT

	UPDATE A
		SET A.dtmDate = @billDate
		,dtmDueDate = dbo.fnGetDueDateBasedOnTerm(@billDate, A.intTermsId)
		,intTransactionType = 1
	FROM tblAPBill A
	WHERE intBillId = @billCreatedPrimaryKey

	SET @newBillId = (SELECT strBillId FROM tblAPBill WHERE intBillId = @billCreatedPrimaryKey)

END