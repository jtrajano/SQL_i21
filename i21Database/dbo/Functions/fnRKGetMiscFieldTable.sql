CREATE FUNCTION [dbo].[fnRKGetMiscFieldTable]
(
	@MiscFields NVARCHAR(MAX)
)
RETURNS @returntable TABLE
(
	strFieldName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strValue NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
		
			SET @statement = dbo.fnTrim(SUBSTRING(@strTemp, @intBegin + 1, @intEnd - 2))
			SET @colEnd = CHARINDEX('=', @statement)
			SET @Column = dbo.fnTrim(LEFT(@statement, @colEnd - 1))
		
			SET @valBegin = CHARINDEX('"', @statement, @colEnd) + 1
			SET @valEnd = CHARINDEX('"', @statement, @valBegin)
			SET @Value = dbo.fnTrim(SUBSTRING(@statement, @valBegin, @valEnd - @valBegin))

			SET @strTemp = dbo.fnTrim(RIGHT(@strTemp, LEN(@strTemp) - @intEnd))
			SET @intBegin = CHARINDEX('{', @strTemp)

			INSERT @returntable
			SELECT @Column, @Value
		END
	END

	RETURN
END
