CREATE PROCEDURE [dbo].[uspEncrypt]
  @plainText NVARCHAR(MAX),
  @encryptedText NVARCHAR(MAX) = NULL OUTPUT 
AS
BEGIN

	OPEN MASTER KEY
		DECRYPTION BY PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

	OPEN SYMMETRIC KEY i21SymKey
		DECRYPTION BY CERTIFICATE i21Certificate

	DECLARE @binaryEncrypted VARBINARY(128) = EncryptByKey(Key_GUID('i21SymKey'), @plainText)

	SELECT @encryptedText =
		CAST(N'' AS XML).value('xs:base64Binary(sql:variable(''@binaryEncrypted''))', 'nvarchar(max)')
	
	RETURN

END