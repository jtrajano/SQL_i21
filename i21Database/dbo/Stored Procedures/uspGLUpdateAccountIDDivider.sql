-- =============================================
-- Author:		Trajano, Jeffrey
-- Create date: 12-11-2014
-- Description:	Updates the GL account divider
-- =============================================
CREATE PROCEDURE [dbo].[uspGLUpdateAccountIDDivider] 
	@divider varchar(3)
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @cnt INT
	DECLARE @strMask VARCHAR(3)
	SELECT @strMask=strMask FROM tblGLAccountStructure WHERE strType = 'Divider'
	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE tblGLAccount SET strAccountId = REPLACE (strAccountId,@divider,@strMask)
		COMMIT TRANSACTION
		SELECT 'success'
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
  
END