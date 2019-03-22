CREATE PROCEDURE [dbo].[uspAESDecrypt]
  @encryptedText NVARCHAR(MAX),
  @decryptedText NVARCHAR(MAX) = NULL OUTPUT 
AS
BEGIN

    OPEN SYMMETRIC KEY i21EncryptionSymKey
        DECRYPTION BY CERTIFICATE i21EncryptionCert
        WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

    SELECT @decryptedText =
        CONVERT(
            NVARCHAR(MAX),
            DecryptByKey(CAST(N'' as XML).value('xs:base64Binary(sql:variable(''@encryptedText''))', 'varbinary(128)'))
        )
    
        CLOSE SYMMETRIC KEY i21EncryptionSymKey

    RETURN

END