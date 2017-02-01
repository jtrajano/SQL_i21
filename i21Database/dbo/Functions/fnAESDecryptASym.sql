﻿
--This function will decrypt the encrypted  value
--You can use it directly into you select statement


CREATE FUNCTION [dbo].[fnAESDecryptASym](@encryptedText AS VARCHAR(MAX))
RETURNS VARCHAR(max)
AS
BEGIN

DECLARE @decryptedText AS VARCHAR(MAX)

	DECLARE @binaryEncrypted NVARCHAR(MAX)  = CONVERT(NVARCHAR(MAX),CAST(N'' as XML).value('xs:base64Binary(sql:variable(''@encryptedText''))', 'varbinary(128)'))

	SELECT @decryptedText =  CONVERT(VARCHAR(MAX),DECRYPTBYKEYAUTOASYMKEY(ASYMKEY_ID('i21EncryptionASymKeyPwd'),  N'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=', @binaryEncrypted))

	RETURN @decryptedText
END
