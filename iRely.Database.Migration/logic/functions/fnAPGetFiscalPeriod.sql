--liquibase formatted sql

-- changeset Von:fnAPGetFiscalPeriod.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPGetFiscalPeriod](@date AS DATETIME)
RETURNS NVARCHAR(255)
AS
BEGIN
	DECLARE @fiscalPeriod AS NVARCHAR(255)

	SELECT @fiscalPeriod = strPeriod FROM tblGLFiscalYearPeriod FP WHERE @date BETWEEN FP.dtmStartDate AND FP.dtmEndDate OR @date = FP.dtmStartDate OR @date = FP.dtmEndDate
	
	RETURN @fiscalPeriod
END



