CREATE FUNCTION [dbo].[fnAPGetVoucherAmountMultiplier]
(
	@TransactionType	NVARCHAR(25)
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	
	IF @TransactionType IN (3)
		RETURN -1.000000
	
	RETURN 1.000000
END

GO