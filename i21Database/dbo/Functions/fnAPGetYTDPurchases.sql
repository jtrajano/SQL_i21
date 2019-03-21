CREATE FUNCTION [dbo].[fnAPGetYTDPurchases]
(
	
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
	DECLARE @ytd DECIMAL(18,2);
	DECLARE @startDate DATETIME = '1/1/' + CAST(YEAR(GETDATE()) AS NVARCHAR)

	SELECT
		@ytd = SUM(A.dblTotal)
	FROM tblAPBill A
	WHERE 
		DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @startDate AND GETDATE()
	AND A.ysnPosted = 1

	RETURN @ytd;
END
