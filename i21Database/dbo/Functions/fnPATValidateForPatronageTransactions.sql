CREATE FUNCTION [dbo].[fnPATValidateForPatronageTransactions]
(
	@transactionIds NVARCHAR(MAX),
	@transactionType NVARCHAR(50)
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(200),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	intTransactionId INT
)
AS
BEGIN
	
	DECLARE @tmpTransactions TABLE(
		[intIDs] [int] PRIMARY KEY,
	UNIQUE (intIDs)
	);
	INSERT INTO @tmpTransactions SELECT * FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	IF(@transactionType = 'Bill')
	BEGIN
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT DISTINCT
			'Amount and quantity for the item '''+ ISNULL(B.strMiscDescription,'') +''' should not be less than or equal to zero.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN tblICItem C ON B.intItemId = B.intItemId
		WHERE A.intBillId IN (SELECT intIDs FROM @tmpTransactions) AND (B.dblQtyOrdered <= 0 OR B.dblCost <= 0) AND C.intPatronageCategoryId IS NOT NULL
	END
	RETURN
END