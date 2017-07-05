CREATE PROCEDURE [dbo].[uspPATUpdatePatronageEntities]
	@entityIds AS NVARCHAR(MAX),
	@stockStatus AS NVARCHAR(50),
	@rowsProcessed AS INT = 0 OUTPUT,
	@bitSuccess AS BIT = 1 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

DECLARE @error NVARCHAR(100);

BEGIN TRANSACTION

BEGIN TRY

	UPDATE tblARCustomer SET strStockStatus = @stockStatus
	WHERE intEntityId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@entityIds));

	SELECT @rowsProcessed = COUNT([intID]) FROM [dbo].[fnGetRowsFromDelimitedValues](@entityIds);

END TRY

BEGIN CATCH
	SET @error = @@ERROR;
	RAISERROR(@error,16, 1);
	ROLLBACK TRANSACTION;
	SET @bitSuccess = 0;
	SET @rowsProcessed = 0;
	RETURN;
END CATCH

COMMIT TRANSACTION

END