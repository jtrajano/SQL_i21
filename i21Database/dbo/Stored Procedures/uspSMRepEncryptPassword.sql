
CREATE PROCEDURE [dbo].[uspSMRepEncryptPassword] 
	@strPassword nvarchar(max),
	@strEnryptedPassword nvarchar(max) OUT
AS
BEGIN
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	--======================Open symmetric code snnipet=====================
		OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
		DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
		WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='


		SET @strEnryptedPassword = dbo.fnAESEncryptASym(@strPassword)

	    CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

END

GO
-----Encrypt Password-----



