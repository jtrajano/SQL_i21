CREATE PROCEDURE [dbo].[uspRKStringDateValidate]
(
	@strDate NVARCHAR(100),
	@isValid BIT OUTPUT
)
AS
BEGIN
	DECLARE @strDateTimeFormat NVARCHAR(100),
		@strDateRegex NVARCHAR(100) = '',
		@intConvertYear int,
		@tempDate datetime;
	
	SET @isValid = 0;

	SELECT @strDateTimeFormat = REPLACE(LEFT(LTRIM(RTRIM(strDateTimeFormat)),10), ' ', '-') FROM tblRKCompanyPreference;

	SET @strDateRegex = CASE 
		WHEN @strDateTimeFormat = 'MM-DD-YYYY' THEN '[0-1][0-9][^0-9][0-3][0-9][^0-9][0-9][0-9][0-9][0-9]'
		WHEN @strDateTimeFormat = 'DD-MM-YYYY' THEN '[0-3][0-9][^0-9][0-1][0-9][^0-9][0-9][0-9][0-9][0-9]'
		WHEN @strDateTimeFormat = 'YYYY-MM-DD' THEN '[0-9][0-9][0-9][0-9][^0-9][0-1][0-9][^0-9][0-3][0-9]'
		WHEN @strDateTimeFormat = 'YYYY-DD-MM' THEN '[0-9][0-9][0-9][0-9][^0-9][0-3][0-9][^0-9][0-1][0-9]'
	END

	IF(PATINDEX (@strDateRegex,@strDate) = 1)
	BEGIN
		SET @intConvertYear = CASE
			WHEN @strDateTimeFormat = 'MM-DD-YYYY' OR @strDateTimeFormat = 'YYYY-MM-DD' THEN 101
			WHEN @strDateTimeFormat = 'DD-MM-YYYY' OR @strDateTimeFormat = 'YYYY-DD-MM' THEN 103
		END

		BEGIN TRY
			SELECT @tempDate=convert(datetime, @strDate, @intConvertYear) 
			SET @isValid = 1
		END TRY
		BEGIN CATCH
			SET @isValid = 0
		END CATCH
	END

	RETURN
END
