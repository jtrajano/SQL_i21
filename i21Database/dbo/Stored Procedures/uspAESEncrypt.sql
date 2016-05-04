CREATE PROCEDURE [dbo].[uspAESEncrypt]
  @plainText NVARCHAR(MAX),
  @encryptedText NVARCHAR(MAX) = NULL OUTPUT 
AS
BEGIN

    OPEN SYMMETRIC KEY i21EncryptionSymKey
        DECRYPTION BY CERTIFICATE i21EncryptionCert
        WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

    DECLARE @binaryEncrypted VARBINARY(128) = EncryptByKey(Key_GUID('i21EncryptionSymKey'), @plainText)

    SELECT @encryptedText =
        CAST(N'' AS XML).value('xs:base64Binary(sql:variable(''@binaryEncrypted''))', 'nvarchar(max)')

    CLOSE SYMMETRIC KEY i21EncryptionSymKey
    
    RETURN

END