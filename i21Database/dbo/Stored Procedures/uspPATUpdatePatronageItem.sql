CREATE PROCEDURE [dbo].[uspPATUpdatePatronageItem]
	@itemIds AS NVARCHAR(MAX),
	@patronageCategory AS INT = NULL,
	@directSale AS INT = NULL,
	@rowsProcessed AS INT = 0 OUTPUT,
	@bitSuccess AS BIT = 0OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @error NVARCHAR(100);

BEGIN TRANSACTION

BEGIN TRY
	IF (@patronageCategory IS NOT NULL)
	BEGIN
		UPDATE tblICItem SET intPatronageCategoryId = @patronageCategory
		WHERE intItemId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@itemIds));
	END

	IF(@directSale IS NOT NULL)
	BEGIN
		UPDATE tblICItem SET intPatronageCategoryDirectId = @directSale
		WHERE intItemId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@itemIds));
	END

	SELECT @rowsProcessed = COUNT([intID]) FROM [dbo].[fnGetRowsFromDelimitedValues](@itemIds);

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