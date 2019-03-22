
--This function will encrypt value
--Open symmetric key before calling this function and close it after

--======================Open symmetric code snnipet=====================
--OPEN SYMMETRIC KEY i21EncryptionSymKey
--       DECRYPTION BY CERTIFICATE i21EncryptionCert
--       WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

--======================Close symmetric code snnipet=====================
--CLOSE SYMMETRIC KEY i21EncryptionSymKey

CREATE FUNCTION [dbo].[fnAESEncrypt](@plainText AS NVARCHAR(MAX))
RETURNS NVARCHAR(max)
AS
BEGIN

DECLARE @encryptedText AS NVARCHAR(MAX)

	DECLARE @binaryEncrypted VARBINARY(128) = EncryptByKey(Key_GUID('i21EncryptionSymKey'), @plainText)

	SELECT @encryptedText = CAST(N'' AS XML).value('xs:base64Binary(sql:variable(''@binaryEncrypted''))', 'nvarchar(max)')

	RETURN @encryptedText
END