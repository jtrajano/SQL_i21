CREATE FUNCTION [dbo].[fnARFormatCustomerAddress]
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
RETURNS NVARCHAR(1000) AS
BEGIN
	DECLARE @fullAddress NVARCHAR(1000)
	DECLARE @tempAddress NVARCHAR(1000)


	SET @strBillToName = CASE WHEN @strBillToName = '' THEN NULL ELSE @strBillToName END
	SET @strPhone = CASE WHEN @strPhone = '' THEN NULL ELSE @strPhone END
	SET @strEmail = CASE WHEN @strEmail = '' THEN NULL ELSE @strEmail END	
	SET @strLocationName = CASE WHEN @strLocationName = '' THEN NULL ELSE @strLocationName END
	SET @strAddress = CASE WHEN @strAddress = '' THEN NULL ELSE @strAddress END	
	SET @strCity = CASE WHEN @strCity = '' THEN NULL ELSE @strCity END
	SET @strState = CASE WHEN @strState = '' THEN NULL ELSE @strState END
	SET @strZipCode = CASE WHEN @strZipCode = '' THEN NULL ELSE @strZipCode END
	SET @strCountry = CASE WHEN @strCountry = '' THEN NULL ELSE @strCountry END
	SET @ysnIncludeEntityName = CASE WHEN @ysnIncludeEntityName IS NULL THEN 0 ELSE @ysnIncludeEntityName END

	if @ysnIncludeEntityName = 0
		SET @strBillToName = NULL

    

	IF @strBillToName IS NOT NULL
			SET @tempAddress =  ISNULL(RTRIM(@strBillToName) + CHAR(13) + char(10), '')
    ELSE
	        SET @tempAddress = '';


	SET @tempAddress = @tempAddress
				 + ISNULL(RTRIM(@strPhone) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strEmail) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strLocationName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(@strCity), '')
			
    --- Validate City if not null then it will concatenate the comma---
	IF @strCity is Not Null
	    SET @tempAddress = @tempAddress + ISNULL(', ' + RTRIM(@strState), '')
	ELSE 
	    SET @tempAddress = @tempAddress + ISNULL('' + RTRIM(@strState), '')


    --- Validate State if not null then it will concatenate the comma---
    IF @strState is Not Null
	    SET @tempAddress = @tempAddress + ISNULL(', ' + RTRIM(@strZipCode), '')
	ELSE 
	   BEGIN
			IF(@strCity is Not Null)
				SET @tempAddress = @tempAddress + ISNULL(', ' + RTRIM(@strZipCode), '')
			ELSE
				SET @tempAddress = @tempAddress + ISNULL('' + RTRIM(@strZipCode), '')
	   END

    --- Validate ZipCode if not null then it will concatenate the comma---
    IF @strZipCode is Not Null
	    SET @tempAddress = @tempAddress + ISNULL(', ' + RTRIM(@strCountry), '')
	ELSE
	   BEGIN 
			 IF @strState is Not Null
				SET @tempAddress = @tempAddress + ISNULL(', ' + RTRIM(@strCountry), '')
			 ELSE 
			   BEGIN
					IF(@strCity is Not Null)
						SET @tempAddress = @tempAddress + ISNULL(', ' + RTRIM(@strCountry), '')
					ELSE
						SET @tempAddress = @tempAddress + ISNULL('' + RTRIM(@strCountry), '')
			   END
       END

	SET @fullAddress = @tempAddress


	RETURN @fullAddress	
END