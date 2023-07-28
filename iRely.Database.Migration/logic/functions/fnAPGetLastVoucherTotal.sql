--liquibase formatted sql

-- changeset Von:fnAPGetLastVoucherTotal.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPGetLastVoucherTotal]
(
	
)
RETURNS @table TABLE
(
	intEntityVendorId INT NOT NULL,
	dblTotal DECIMAL(18,2),
	dtmDate DATETIME,
    PRIMARY KEY CLUSTERED ([intEntityVendorId] ASC)
)
AS
BEGIN
	DECLARE @lastVoucherAmount DECIMAL(18,2);

	WITH dataResult
	(
		intKey,
		intEntityVendorId,
		dtmDate,
		dblTotal
	)
	AS
	(
		SELECT
			CAST(ROW_NUMBER() OVER (PARTITION BY intEntityVendorId ORDER BY intBillId DESC) AS INT) AS intKey,
			A.intEntityVendorId,
			A.dtmDate,
			A.dblTotal
		FROM tblAPBill A
	)

	INSERT INTO @table
	SELECT 
		intEntityVendorId,
		dblTotal,
		dtmDate
	FROM dataResult
	WHERE intKey = 1 --only show result 1 row per vendor
	
	RETURN;
END



