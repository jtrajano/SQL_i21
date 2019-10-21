
--This function will decrypt the encrypted  value
--Open symmetric key before calling this function and close it after

--======================Open symmetric code snnipet=====================
--OPEN SYMMETRIC KEY i21EncryptionSymKey
--       DECRYPTION BY CERTIFICATE i21EncryptionCert
--       WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

--======================Close symmetric code snnipet=====================
--CLOSE SYMMETRIC KEY i21EncryptionSymKey

CREATE FUNCTION [dbo].[fnAESDecrypt](@encryptedText AS NVARCHAR(MAX))
RETURNS NVARCHAR(max)
AS
BEGIN

DECLARE @decryptedText AS NVARCHAR(MAX)

	SELECT @decryptedText =  CONVERT(NVARCHAR(MAX),DecryptByKey(CAST(N'' as XML).value('xs:base64Binary(sql:variable(''@encryptedText''))', 'varbinary(128)')))

	RETURN @decryptedText
END