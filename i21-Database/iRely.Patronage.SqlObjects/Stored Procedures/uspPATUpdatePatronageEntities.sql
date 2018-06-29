CREATE PROCEDURE [dbo].[uspPATUpdatePatronageEntities]
	@entityIds AS NVARCHAR(MAX),
	@stockStatus AS NVARCHAR(50),
	@accountStatus AS NVARCHAR(MAX),
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

DECLARE @entityTable TABLE(
	[intEntityId] INT NOT NULL
);

DECLARE @customerAccountStatusUpdate TABLE(
	[intEntityId] INT NOT NULL,
	[intAccountStatusId] INT NOT NULL
);

DECLARE @accountStatusList TABLE(
	[intAccountStatusId] INT NOT NULL
);

INSERT INTO @entityTable
SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@entityIds);

BEGIN TRY

	IF(ISNULL(@stockStatus,'') != '')
	BEGIN
		UPDATE tblARCustomer SET strStockStatus = @stockStatus
		WHERE intEntityId IN (SELECT [intEntityId] FROM @entityTable);
	END

	IF(ISNULL(@accountStatus,'') != '')
	BEGIN
		INSERT INTO @accountStatusList
		SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@accountStatus);

		INSERT INTO @customerAccountStatusUpdate
		SELECT	ET.intEntityId, ASL.intAccountStatusId
		FROM @entityTable ET
		CROSS APPLY @accountStatusList ASL

		INSERT INTO tblARCustomerAccountStatus([intEntityCustomerId], [intAccountStatusId], [intConcurrencyId])
		SELECT	intEntityId = CASUpdate.intEntityId,
				intAccountStatusId = CASUpdate.intAccountStatusId,
				intConcurrencyId = 1
		FROM @customerAccountStatusUpdate CASUpdate
		LEFT JOIN tblARCustomerAccountStatus CAS
			ON CAS.intEntityCustomerId = CASUpdate.intEntityId AND CAS.intAccountStatusId =  CASUpdate.intAccountStatusId
		WHERE CAS.intCustomerAccountStatusId IS NULL
	END

	SELECT @rowsProcessed = COUNT([intEntityId]) FROM @entityTable;

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