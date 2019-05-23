CREATE FUNCTION [dbo].[fnAPGetYTDPurchases]
(
	
)
RETURNS @table TABLE
(
	intEntityVendorId INT NOT NULL,
	dblTotal DECIMAL(18,2),
    PRIMARY KEY CLUSTERED ([intEntityVendorId] ASC)
)
AS
BEGIN
	DECLARE @ytd DECIMAL(18,2);
	DECLARE @startDate DATETIME = '1/1/' + CAST(YEAR(GETDATE()) AS NVARCHAR);

	WITH result
	(
		intEntityVendorId,
		dblTotal
	)
	AS
	(
		SELECT
			A.intEntityVendorId,
			SUM(A.dblTotal)
		FROM tblAPBill A
		WHERE 
			DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @startDate AND GETDATE()
		AND A.ysnPosted = 1
		GROUP BY A.intEntityVendorId
	)

	INSERT INTO @table
	SELECT * FROM result

	RETURN;
END
