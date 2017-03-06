﻿CREATE PROCEDURE [dbo].[uspGLGetNewID]
	-- Add the parameters for the stored procedure here
	(@i INT,@strID NVARCHAR(100) OUTPUT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @strPrefix VARCHAR(10),@intNumber INT
    -- Insert statements for procedure here
	SELECT @strPrefix = strPrefix ,@intNumber = intNumber FROM tblSMStartingNumber WHERE intStartingNumberId = @i
		
	UPDATE tblSMStartingNumber SET intNumber = intNumber+1 WHERE intStartingNumberId = @i
	SELECT @strID = @strPrefix + '-' + CONVERT(VARCHAR(10),@intNumber)
END
