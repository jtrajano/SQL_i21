CREATE FUNCTION [dbo].[fnAPGetVoucherAverageRate]
(
)
RETURNS @table TABLE(
	intBillId INT PRIMARY KEY,
	dblExchangeRate DECIMAL(18,6)
)
AS
BEGIN
	
	INSERT INTO @table
	SELECT
		A.intBillId
		,SUM(ISNULL(NULLIF(A.dblRate,0), 1)) / COUNT(*)
	FROM tblAPBillDetail A
	GROUP BY A.intBillId
	
	RETURN;
END
