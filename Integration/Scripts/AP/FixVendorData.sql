GO
--THIS SCRIPT WILL REMOVE EXTRA SPACES ON EXISTING DATA OF VENDOR, THOSE WHO ALREADY DONE IMPORTING

--Make sure this will only run once.
--dbo.fnTrim only exists after this script executed.
IF EXISTS(SELECT TOP 1 1 FROM tblEntity WHERE CHARINDEX('     ',strName) >= 0)
BEGIN
  
	UPDATE tblEntity
		SET strName = CASE WHEN B.intVendorType = 0 THEN dbo.fnTrim(A.strName)
						ELSE 
							dbo.fnTrim(SUBSTRING(A.strName, DATALENGTH([dbo].[fnGetVendorLastName](A.strName)), DATALENGTH(A.strName)))
							+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](A.strName))
						END
	FROM tblEntity A
		INNER JOIN tblAPVendor B
			ON A.intEntityId = B.intEntityId

	UPDATE tblEntityLocation
		SET strLocationName = CASE WHEN B.intVendorType = 0 THEN dbo.fnTrim(A.strLocationName)
						ELSE 
							dbo.fnTrim(SUBSTRING(A.strLocationName, DATALENGTH([dbo].[fnGetVendorLastName](A.strLocationName)), DATALENGTH(A.strLocationName)))
							+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](A.strLocationName))
						END
	FROM tblEntityLocation A
		INNER JOIN tblAPVendor B
			ON A.intEntityLocationId = B.intDefaultLocationId

END
GO

