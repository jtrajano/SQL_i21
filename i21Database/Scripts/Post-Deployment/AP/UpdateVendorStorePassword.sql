UPDATE A
SET
	A.strStoreFTPPassword = dbo.fnAESEncryptASym(A.strStoreFTPPassword)
FROM tblAPVendor A
WHERE
	LEN(LTRIM(RTRIM(A.strStoreFTPPassword))) != 344
AND NULLIF(A.strStoreFTPPassword,'') IS NOT NULL