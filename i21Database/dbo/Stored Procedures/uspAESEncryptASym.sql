CREATE PROCEDURE [dbo].[uspAESEncryptASym]
  @plainText VARCHAR(MAX),
  @encryptedText VARCHAR(MAX) = NULL OUTPUT 
AS
BEGIN

	 --For Encryption and Decryption
	--OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
	--DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
	--WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

	SELECT @encryptedText = dbo.fnAESEncryptASym(@plainText)
    
	--CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym
    
	RETURN

END