CREATE PROCEDURE [dbo].[uspAESDecrypt]
  @encryptedText NVARCHAR(MAX),
  @decryptedText NVARCHAR(MAX) = NULL OUTPUT 
AS
BEGIN

    OPEN MASTER KEY
        DECRYPTION BY PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

    OPEN SYMMETRIC KEY i21SymKey
        DECRYPTION BY CERTIFICATE i21Certificate

    SELECT @decryptedText =
        CONVERT(
            NVARCHAR(MAX),
            DecryptByKey(CAST(N'' as XML).value('xs:base64Binary(sql:variable(''@encryptedText''))', 'varbinary(128)'))
        )
    
    RETURN

END