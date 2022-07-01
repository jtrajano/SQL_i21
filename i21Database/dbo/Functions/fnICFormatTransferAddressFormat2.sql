﻿CREATE FUNCTION [dbo].[fnICFormatTransferAddressFormat2]
(
	@strPhone		 NVARCHAR(25)  = NULL,
	@strFax			NVARCHAR(25)   = NULL,
	@strEmail		 NVARCHAR(75)  = NULL,	
	@strLocationName NVARCHAR(50)  = NULL,
	@strAddress		 NVARCHAR(100) = NULL,
	@strCity		 NVARCHAR(30)  = NULL,
	@strState		 NVARCHAR(50)  = NULL,
	@strZipCode		 NVARCHAR(12)  = NULL,
	@strCountry		 NVARCHAR(25)  = NULL
)
RETURNS NVARCHAR(1000) AS
BEGIN
	DECLARE @fullAddress NVARCHAR(1000)
	DECLARE @tempAddress NVARCHAR(1000)


	SET @strPhone = CASE WHEN @strPhone = '' THEN NULL ELSE @strPhone END COLLATE Latin1_General_CI_AS
	SET @strEmail = CASE WHEN @strEmail = '' THEN NULL ELSE @strEmail END COLLATE Latin1_General_CI_AS
	SET @strLocationName = CASE WHEN @strLocationName = '' THEN NULL ELSE @strLocationName END COLLATE Latin1_General_CI_AS
	SET @strAddress = CASE WHEN @strAddress = '' THEN NULL ELSE @strAddress END	COLLATE Latin1_General_CI_AS
	SET @strCity = CASE WHEN @strCity = '' THEN NULL ELSE @strCity END COLLATE Latin1_General_CI_AS
	SET @strState = CASE WHEN @strState = '' THEN NULL ELSE @strState END COLLATE Latin1_General_CI_AS
	SET @strZipCode = CASE WHEN @strZipCode = '' THEN NULL ELSE @strZipCode END COLLATE Latin1_General_CI_AS
	SET @strCountry = CASE WHEN @strCountry = '' THEN NULL ELSE @strCountry END COLLATE Latin1_General_CI_AS

	SET @tempAddress = '';

	SET @tempAddress +=
		+ ISNULL(RTRIM(@strLocationName) + CHAR(13) + CHAR(10), '')
		+ ISNULL(RTRIM(@strAddress) + CHAR(13) + CHAR(10), '')
		+ ISNULL(RTRIM(@strCity), '')
		+ CASE WHEN @strCity IS NOT NULL THEN ISNULL(', ' + RTRIM(@strState), '') ELSE ISNULL('' + RTRIM(@strState), '') END 
		+ CASE WHEN @strState IS NOT NULL THEN ISNULL(', ' + RTRIM(@strZipCode), '') ELSE ISNULL('' + RTRIM(@strZipCode), '') END 
		+ CASE 
			WHEN @strZipCode IS NOT NULL THEN ISNULL(', ' + RTRIM(@strCountry), '') 
			WHEN @strState IS NOT NULL THEN ISNULL(', ' + RTRIM(@strCountry), '')
			WHEN @strCity IS NOT NULL THEN ISNULL(', ' + RTRIM(@strCountry), '')
			ELSE ISNULL('' + RTRIM(@strCountry), '')
		END 
		+ CHAR(13) + CHAR(10)
		+ ISNULL('Tel: ' + RTRIM(@strPhone) + ' ', '')
		+ ISNULL('Fax: ' + RTRIM(@strFax) + ' ', '')
		+ CASE WHEN @strPhone IS NOT NULL OR @strFax IS NOT NULL THEN CHAR(13) + CHAR(10) ELSE '' END 
		+ ISNULL('E-mail: ' + RTRIM(@strEmail) + CHAR(13) + char(10), '') COLLATE Latin1_General_CI_AS
		
	SET @fullAddress = RTRIM(LTRIM(@tempAddress)) COLLATE Latin1_General_CI_AS
	RETURN @fullAddress	 COLLATE Latin1_General_CI_AS
END