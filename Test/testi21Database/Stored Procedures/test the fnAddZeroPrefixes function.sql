﻿CREATE PROCEDURE testi21Database.[test the fnAddZeroPrefixes function]
AS 
BEGIN
	-- Arrange
	DECLARE @value AS NVARCHAR(20); 
	SET @value = '39588'

	DECLARE @prefixCount AS INT;
	SET @prefixCount = 8

	DECLARE @Expected AS NVARCHAR(20);
	SET @Expected = '00039588'

	DECLARE @actual AS NVARCHAR(20);

	-- Act
	SELECT @actual = dbo.fnAddZeroPrefixes(@value,@prefixCount);

	-- Assert
	EXEC tSQLt.AssertEquals @Expected, @actual;
END