GO
	PRINT ('*****BEGIN FIX VENDOR NUMBER*****')

	UPDATE a SET strVendorId = b.strEntityNo
	FROM tblAPVendor a
	INNER JOIN tblEMEntity b ON a.intEntityId = b.intEntityId
	WHERE strVendorId IS NULL

	PRINT ('*****END FIX VENDOR NUMBER*****')
GO
