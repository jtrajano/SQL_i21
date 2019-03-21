CREATE FUNCTION [dbo].[fnAPGetLYPurchases]
(

)
RETURNS DECIMAL(18, 2)
AS
BEGIN
	DECLARE @ly DECIMAL(18,2);
	DECLARE @lastYear NVARCHAR(8) = CAST(YEAR(GETDATE())-1 AS NVARCHAR(8));
	DECLARE @startDate DATETIME = '1/1/' + @lastYear
	DECLARE @endDate DATETIME = '12/31/' + @lastYear

	SELECT
		@ly = SUM(A.dblTotal)
	FROM tblAPBill A
	WHERE 
		DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @startDate AND GETDATE()
	AND A.ysnPosted = 1

	RETURN @ly;
END
