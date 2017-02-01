CREATE PROCEDURE [dbo].[uspAESDecryptASym]
  @encryptedText VARCHAR(MAX),
  @decryptedText VARCHAR(MAX) = NULL OUTPUT 
AS
BEGIN

	SELECT @decryptedText = dbo.fnAESDecrypt(@encryptedText)

    RETURN

END