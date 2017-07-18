CREATE FUNCTION [dbo].[fnAPGetVoucherTransactionType]()
	RETURNS @tblTransactionType  TABLE (  intId INT, strText NVARCHAR(50))
AS
BEGIN

	INSERT INTO @tblTransactionType
		SELECT 1, 'Voucher' UNION
		SELECT 2,'Vendor Prepayment' UNION
		SELECT 3,'Debit Memo' UNION
		SELECT 4,'Payable' UNION
		SELECT 5,'Purchase Order' UNION
		SELECT 6,'Bill Template' UNION
		SELECT 8,'Overpayment' UNION
		SELECT 9,'1099 Adjustment' UNION
		SELECT 10,'Patronage' UNION
		SELECT 11,'Claim'
	RETURN;
END
