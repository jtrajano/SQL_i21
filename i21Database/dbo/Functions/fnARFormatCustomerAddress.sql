﻿CREATE FUNCTION [dbo].[fnARFormatCustomerAddress]
(
	@strPhone		 NVARCHAR(25)  = NULL,
	@strEmail		 NVARCHAR(75)  = NULL,	
	@strLocationName NVARCHAR(50)  = NULL,
	@strAddress		 NVARCHAR(100) = NULL,
	@strCity		 NVARCHAR(30)  = NULL,
	@strState		 NVARCHAR(50)  = NULL,
	@strZipCode		 NVARCHAR(12)  = NULL,
	@strCountry		 NVARCHAR(25)  = NULL,
	@strBillToName   NVARCHAR(100) = NULL,
	@ysnIncludeEntityName BIT = NULL
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @fullAddress NVARCHAR(MAX)
	
	SET @strBillToName = CASE WHEN @strBillToName = '' THEN NULL ELSE @strBillToName END
	SET @strPhone = CASE WHEN @strPhone = '' THEN NULL ELSE @strPhone END
	SET @strEmail = CASE WHEN @strEmail = '' THEN NULL ELSE @strEmail END	
	SET @strLocationName = CASE WHEN @strLocationName = '' THEN NULL ELSE @strLocationName END
	SET @strAddress = CASE WHEN @strAddress = '' THEN NULL ELSE @strAddress END	
	SET @strCity = CASE WHEN @strCity = '' THEN NULL ELSE @strCity END
	SET @strState = CASE WHEN @strState = '' THEN NULL ELSE @strState END
	SET @strZipCode = CASE WHEN @strZipCode = '' THEN NULL ELSE @strZipCode END
	SET @strCountry = CASE WHEN @strCountry = '' THEN NULL ELSE @strCountry END
	SET @ysnIncludeEntityName = CASE WHEN @ysnIncludeEntityName is null THEN 0 ELSE @ysnIncludeEntityName END

	if @ysnIncludeEntityName = 0
		SET @strBillToName = null

	IF @strBillToName IS NULL
		BEGIN
			SET @fullAddress = ISNULL(RTRIM(@strPhone) + CHAR(13) + char(10), '')
					 + ISNULL(RTRIM(@strEmail) + CHAR(13) + char(10), '')
					 + ISNULL(RTRIM(@strLocationName) + CHAR(13) + char(10), '')
					 + ISNULL(RTRIM(@strAddress) + CHAR(13) + char(10), '')
					 + ISNULL(RTRIM(@strCity), '')
					 + ISNULL(', ' + RTRIM(@strState), '')
					 + ISNULL(', ' + RTRIM(@strZipCode), '')
					 + ISNULL(', ' + RTRIM(@strCountry), '')
		END
	ELSE
		BEGIN
			SET @fullAddress = ISNULL(RTRIM(@strBillToName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strPhone) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strEmail) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strLocationName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strCity), '')
				 + ISNULL(', ' + RTRIM(@strState), '')
				 + ISNULL(', ' + RTRIM(@strZipCode), '')
				 + ISNULL(', ' + RTRIM(@strCountry), '')
		END	

	RETURN @fullAddress	
END