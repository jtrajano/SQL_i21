CREATE FUNCTION [dbo].[fnAPGetVoucherTransactionType2](@transactionTypeId INT)
RETURNS NVARCHAR(255)
AS
BEGIN
	DECLARE @fiscalPeriod AS NVARCHAR(255)

	SET @fiscalPeriod = CASE
							WHEN @transactionTypeId = 1 THEN 'Voucher'
							WHEN @transactionTypeId = 2 THEN 'Vendor Prepayment'
							WHEN @transactionTypeId = 3 THEN 'Debit Memo'
							WHEN @transactionTypeId = 4 THEN 'Payable'
							WHEN @transactionTypeId = 5 THEN 'Purchase Order'
							WHEN @transactionTypeId = 6 THEN 'Bill Template'
							WHEN @transactionTypeId = 8 THEN 'Overpayment'
							WHEN @transactionTypeId = 9 THEN '1099 Adjustment'
							WHEN @transactionTypeId = 10 THEN 'Patronage'
							WHEN @transactionTypeId = 11 THEN 'Claim'
						END

	RETURN @fiscalPeriod
END