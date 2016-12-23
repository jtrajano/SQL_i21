﻿CREATE FUNCTION [dbo].[fnPATValidateAssociatedTransaction]
(
	@transactionIds NVARCHAR(MAX),
	@type INT -- 2 = Retired Stock
)
RETURNS @returnTable TABLE
(
	strError NVARCHAR(MAX),
	strTransactionType NVARCHAR(50),
	strTransactionNo NVARCHAR(50),
	intTransactionId INT
)
BEGIN
	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);

	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	IF(@type = 2)
	BEGIN
		INSERT INTO @returnTable
		SELECT	'Voucher('+ APB.strBillId +') for Retired Stock is already paid.',
				'Retired Stock',
				APB.strBillId,
				APB.intBillId
		FROM tblPATCustomerStock CS
		INNER JOIN tblAPBill APB
			ON APB.intBillId = CS.intBillId
		WHERE APB.ysnPaid = 1 AND CS.strActivityStatus = 'Retired' AND CS.intCustomerStockId IN (SELECT * FROM @tmpTransacions)
	END

	RETURN
END