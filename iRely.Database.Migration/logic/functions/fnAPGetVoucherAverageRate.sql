--liquibase formatted sql

-- changeset Von:fnAPGetVoucherAverageRate.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPGetVoucherAverageRate]
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



