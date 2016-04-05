GO
--This script will do the following.
--1. Updating strName so that it will become Last Name first.
--2. Removed extra spaces.

--Make sure this will only run once.
--dbo.fnTrim only exists after this script executed.
IF EXISTS(SELECT TOP 1 1 FROM tblEMEntity WHERE CHARINDEX('     ',strName) >= 0)
BEGIN
  
	UPDATE tblEMEntity
		SET strName = CASE WHEN B.intVendorType = 0 THEN dbo.fnTrim(A.strName)
						ELSE 
							dbo.fnTrim(SUBSTRING(A.strName, DATALENGTH([dbo].[fnGetVendorLastName](A.strName)), DATALENGTH(A.strName)))
							+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](A.strName))
						END
	FROM tblEMEntity A
		INNER JOIN tblAPVendor B
			ON A.intEntityId = B.intEntityId

	UPDATE tblEMEntityLocation
		SET strLocationName = CASE WHEN B.intVendorType = 0 THEN dbo.fnTrim(A.strLocationName)
						ELSE 
							dbo.fnTrim(SUBSTRING(A.strLocationName, DATALENGTH([dbo].[fnGetVendorLastName](A.strLocationName)), DATALENGTH(A.strLocationName)))
							+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](A.strLocationName))
						END
	FROM tblEMEntityLocation A
		INNER JOIN tblAPVendor B
			ON A.intEntityLocationId = B.intDefaultLocationId

END
GO

