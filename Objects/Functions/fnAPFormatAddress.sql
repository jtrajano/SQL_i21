CREATE FUNCTION [dbo].[fnAPFormatAddress]
(
	@strVendorName NVARCHAR(100),
	@strCompanyName  NVARCHAR(100),
	@strShipToAttn  NVARCHAR(100),
	@strAddress NVARCHAR(100),
	@strCity NVARCHAR(30),
	@strState NVARCHAR(50),
	@strZipCode NVARCHAR(12),
	@strCountry NVARCHAR(25),
	@strPhone NVARCHAR(25)

)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @fullAddress NVARCHAR(MAX)
	
	SET @strVendorName = CASE WHEN @strVendorName = '' THEN NULL ELSE @strVendorName END	
	SET @strCompanyName = CASE WHEN @strCompanyName = '' THEN NULL ELSE @strCompanyName END	
	SET @strShipToAttn = CASE WHEN @strShipToAttn = '' THEN NULL ELSE @strShipToAttn END	
	SET @strAddress = CASE WHEN @strAddress = '' THEN NULL ELSE @strAddress END	
	SET @strCity = CASE WHEN @strCity = '' THEN NULL ELSE @strCity END
	SET @strState = CASE WHEN @strState = '' THEN NULL ELSE @strState END
	SET @strZipCode = CASE WHEN @strZipCode = '' THEN NULL ELSE @strZipCode END
	SET @strCountry = CASE WHEN @strCountry = '' THEN NULL ELSE @strCountry END
	SET @strPhone = CASE WHEN @strPhone = '' THEN NULL ELSE @strPhone END  

	SET @fullAddress = 
				 + ISNULL(RTRIM(@strVendorName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strCompanyName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strShipToAttn) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strCity), '')
				 + ISNULL(', ' + RTRIM(@strState), '')
				 + ISNULL('' + RTRIM(@strZipCode)+ CHAR(13) + char(10), '')
				 + ISNULL('' + RTRIM(@strCountry) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strPhone)+ CHAR(13) + char(10), '')
	RETURN @fullAddress	
END