
--This function will encrypt value
--Open symmetric key before calling this function and close it after

--======================Open symmetric code snnipet=====================
--OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
--	DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
--	WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

--======================Close symmetric code snnipet=====================
--CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

CREATE FUNCTION [dbo].[fnAESEncryptASym](@plainText AS VARCHAR(MAX))
RETURNS VARCHAR(max)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @encryptedText AS VARCHAR(MAX)

	--DECLARE @binaryEncrypted VARBINARY(128) = EncryptByKey(Key_GUID('i21EncryptionSymKeyByASym'), @plainText)
	DECLARE @binaryEncrypted VARBINARY(256) = EncryptByCert(Cert_ID('iRelyi21Certificate'), @plainText)

	SELECT @encryptedText = CAST(N'' AS XML).value('xs:base64Binary(sql:variable(''@binaryEncrypted''))', 'varchar(max)')

	RETURN @encryptedText
END