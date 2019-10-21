CREATE FUNCTION [dbo].[fnAPValidatePostInvoice]
(
	@invoicesId AS Id READONLY,
	@post BIT
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(200),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	intTransactionId INT,
	intErrorKey INT
)
AS
BEGIN

	--Do not allow to applied claim or dm, if amount due exceeds on applied amount
	INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
	SELECT
		A.strBillId + ' invalid amount applied.',
		'Bill',
		A.strBillId,
		A.intBillId,
		23
	FROM tblAPBill A
	WHERE A.dblPayment > A.dblTotal
			OR A.dblAmountDue < 0
			OR A.dblAmountDue > A.dblTotal
			OR A.dblPayment < 0

	--making sure transaction type is correct
	INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
	SELECT
		A.strBillId + ' invalid transaction.',
		'Bill',
		A.strBillId,
		A.intBillId,
		24
	FROM tblAPBill A
	WHERE A.intTransactionType NOT IN (3, 11)

	RETURN;
END