CREATE FUNCTION [dbo].[fnCCValidateAssociatedTransaction]
(
	@transactionIds NVARCHAR(MAX),
	@type INT, -- 1 = DCC
	@transaction NVARCHAR(MAX) = NULL --this will determine who calls the function
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(MAX),
	strTransactionType NVARCHAR(50),
	strTransactionNo NVARCHAR(50),
	intTransactionId INT
)
AS
BEGIN
	DECLARE @tmpTransactions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	)

	INSERT INTO @tmpTransactions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)
	--do not validate unposting if unposting calls by credit card module
	IF @transaction != 'Credit Card'
	BEGIN
		IF(@type = 1)
		BEGIN
			INSERT INTO @returntable
			SELECT	DISTINCT
					'This voucher was created from Dealer Credit Card - <strong>'+ A.strCcdReference +'</strong>. Unpost it from there.',
					'Voucher',
					D.strBillId,
					D.intBillId
			FROM tblCCSiteHeader A 
			INNER JOIN tblCCSiteDetail B ON B.intSiteHeaderId = A.intSiteHeaderId
			INNER JOIN tblAPBillDetail C ON C.intCCSiteDetailId = B.intSiteDetailId
			INNER JOIN tblAPBill D ON D.intBillId = C.intBillId
			WHERE D.intBillId IN (SELECT intTransactionId FROM @tmpTransactions) AND D.ysnPosted = 1
		END
	END
	RETURN
END
