CREATE FUNCTION [dbo].[fnARFormatCustomerAddress]
(
	@strPhone NVARCHAR(25),
	@strEmail NVARCHAR(75),	
	@strLocationName NVARCHAR(50),
	@strAddress NVARCHAR(100),
	@strCity NVARCHAR(30),
	@strState NVARCHAR(50),
	@strZipCode NVARCHAR(12),
	@strCountry NVARCHAR(25)
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @fullAddress NVARCHAR(MAX)
	
	SET @strPhone = CASE WHEN @strPhone = '' THEN NULL ELSE @strPhone END
	SET @strEmail = CASE WHEN @strEmail = '' THEN NULL ELSE @strEmail END	
	SET @strLocationName = CASE WHEN @strLocationName = '' THEN NULL ELSE @strLocationName END
	SET @strAddress = CASE WHEN @strAddress = '' THEN NULL ELSE @strAddress END	
	SET @strCity = CASE WHEN @strCity = '' THEN NULL ELSE @strCity END
	SET @strState = CASE WHEN @strState = '' THEN NULL ELSE @strState END
	SET @strZipCode = CASE WHEN @strZipCode = '' THEN NULL ELSE @strZipCode END
	SET @strCountry = CASE WHEN @strCountry = '' THEN NULL ELSE @strCountry END

	SET @fullAddress = ISNULL(RTRIM(@strPhone) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strEmail) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strLocationName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strCity), '')
				 + ISNULL(', ' + RTRIM(@strState), '')
				 + ISNULL(', ' + RTRIM(@strZipCode), '')
				 + ISNULL(', ' + RTRIM(@strCountry), '')

	RETURN @fullAddress	
END