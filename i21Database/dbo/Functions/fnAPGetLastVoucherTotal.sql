CREATE FUNCTION [dbo].[fnAPGetLastVoucherTotal]
(
	
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
	DECLARE @lastVoucherAmount DECIMAL(18,2)

	SELECT
		@lastVoucherAmount
	FROM tblAPBill A

	RETURN @lastVoucherAmount;
END
