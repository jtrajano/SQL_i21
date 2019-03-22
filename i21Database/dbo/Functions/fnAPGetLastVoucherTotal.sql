CREATE FUNCTION [dbo].[fnAPGetLastVoucherTotal]
(
	
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
	DECLARE @lastVoucherAmount DECIMAL(18,2)

	SELECT TOP 1
		@lastVoucherAmount = dblTotal
	FROM tblAPBill A
	ORDER BY intBillId DESC

	RETURN @lastVoucherAmount;
END
