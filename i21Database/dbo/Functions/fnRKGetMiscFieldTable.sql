﻿CREATE FUNCTION [dbo].[fnRKGetMiscFieldTable]
(
	@MiscFields NVARCHAR(MAX)
)
RETURNS @returntable TABLE
(
	strFieldName NVARCHAR(100)
	, strValue NVARCHAR(100)
)
AS
BEGIN
	--DECLARE @@MiscFields NVARCHAR(MAX) = '{Customer ="strTest"}      {Helper ="new"   }  '

	IF (ISNULL(@MiscFields, '') != '')
	BEGIN
		DECLARE @strTemp NVARCHAR(MAX) = @MiscFields
		DECLARE @intBegin INT = CHARINDEX('{', @strTemp)
			, @intEnd INT
			, @Column NVARCHAR(100)
			, @colBegin INT
			, @colEnd INT
			, @Value NVARCHAR(100)
			, @valBegin INT
			, @valEnd INT
			, @statement NVARCHAR(250)

		WHILE (@intBegin > 0)
		BEGIN
			SET @intEnd = CHARINDEX('}', @strTemp)
		
			SET @statement = TRIM(SUBSTRING(@strTemp, @intBegin + 1, @intEnd - 2))
			SET @colEnd = CHARINDEX('=', @statement)
			SET @Column = TRIM(LEFT(@statement, @colEnd - 1))
		
			SET @valBegin = CHARINDEX('"', @statement, @colEnd) + 1
			SET @valEnd = CHARINDEX('"', @statement, @valBegin)
			SET @Value = TRIM(SUBSTRING(@statement, @valBegin, @valEnd - @valBegin))

			SET @strTemp = TRIM(RIGHT(@strTemp, LEN(@strTemp) - @intEnd))
			SET @intBegin = CHARINDEX('{', @strTemp)

			INSERT @returntable
			SELECT @Column, @Value
		END
	END

	RETURN
END
