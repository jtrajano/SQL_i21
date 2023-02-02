CREATE PROCEDURE [dbo].[uspARAddItemToInvoices]
	 @InvoiceEntries	InvoiceStagingTable	READONLY
	,@IntegrationLogId	INT					= NULL
	,@UserId			INT
	,@RaiseError		BIT					= 0
	,@ErrorMessage		NVARCHAR(250)		= NULL	OUTPUT
	,@SkipRecompute     BIT                 = 0
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON
	
DECLARE  @ZeroDecimal		NUMERIC(18, 6)
		,@AddDetailError	NVARCHAR(MAX)
		,@InitTranCount		INT
		,@Savepoint			NVARCHAR(32)

SET @ZeroDecimal = 0.000000
SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddItemToInvoices' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@RaiseError,0) = 0
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

DECLARE @Inventory InvoiceStagingTable
DELETE FROM @Inventory
INSERT INTO @Inventory
SELECT *
FROM
	@InvoiceEntries
WHERE
	--ISNULL([ysnInventory],0) = 1
	--OR  
	[dbo].[fnIsStockTrackingItem]([intItemId]) = 1

IF EXISTS(SELECT TOP 1 NULL FROM @Inventory)
BEGIN
	BEGIN TRY		

	EXEC [dbo].[uspARAddInventoryItemToInvoices]
			 @InvoiceEntries	= @Inventory
			,@IntegrationLogId	= @IntegrationLogId
			,@UserId			= @UserId
			,@RaiseError		= @RaiseError
			,@ErrorMessage		= @AddDetailError OUTPUT
			,@SkipRecompute		= @SkipRecompute

	IF LEN(ISNULL(@AddDetailError,'')) > 0
		BEGIN
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = @AddDetailError;
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		END

		SET @ErrorMessage = ERROR_MESSAGE();
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH
END

DECLARE @NonInventory InvoiceStagingTable
DELETE FROM @NonInventory
INSERT INTO @NonInventory
SELECT *
FROM
	@InvoiceEntries
WHERE
	[dbo].[fnIsStockTrackingItem]([intItemId]) = 0
	AND ISNULL([intItemId], 0) <> 0
	AND ISNULL([intCommentTypeId], 0) = 0


IF EXISTS(SELECT TOP 1 NULL FROM @NonInventory)
	BEGIN
		BEGIN TRY		

		EXEC [dbo].[uspARAddNonInventoryItemToInvoices]
				 @InvoiceEntries	= @NonInventory
				,@IntegrationLogId	= @IntegrationLogId
				,@UserId			= @UserId
				,@RaiseError		= @RaiseError
				,@ErrorMessage		= @AddDetailError OUTPUT
				,@SkipRecompute		= @SkipRecompute

		IF LEN(ISNULL(@AddDetailError,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
				BEGIN
					IF @InitTranCount = 0
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION
					ELSE
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION @Savepoint
				END

				SET @ErrorMessage = @AddDetailError;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
		END TRY
		BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH
	END

DECLARE @MiscItem InvoiceStagingTable
DELETE FROM @MiscItem
INSERT INTO @MiscItem
SELECT *
FROM
	@InvoiceEntries
WHERE
	[dbo].[fnIsStockTrackingItem]([intItemId]) = 0
	AND NOT (ISNULL([intItemId], 0) <> 0 AND ISNULL([intCommentTypeId], 0) = 0)
	AND (LEN(RTRIM(LTRIM([strItemDescription]))) > 0 OR ISNULL([dblPrice], @ZeroDecimal) <> 0 )
	AND ISNULL([intCommentTypeId], 0) IN (0,1,3)



IF EXISTS(SELECT TOP 1 NULL FROM @MiscItem)
	BEGIN		
		BEGIN TRY
		EXEC [dbo].[uspARAddMiscItemToInvoices]
				 @InvoiceEntries	= @MiscItem
				,@IntegrationLogId	= @IntegrationLogId
				,@UserId			= @UserId
				,@RaiseError		= @RaiseError
				,@ErrorMessage		= @AddDetailError OUTPUT
				,@SkipRecompute		= @SkipRecompute

			IF LEN(ISNULL(@AddDetailError,'')) > 0
				BEGIN
					IF ISNULL(@RaiseError,0) = 0
					BEGIN
						IF @InitTranCount = 0
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION
						ELSE
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION @Savepoint
					END

					SET @ErrorMessage = @AddDetailError;
					IF ISNULL(@RaiseError,0) = 1
						RAISERROR(@ErrorMessage, 16, 1);
					RETURN 0;
				END
		END TRY
		BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH	
	END

DECLARE @strInvoiceIds NVARCHAR(MAX) = NULL
DECLARE @strSessionId NVARCHAR(200) = NEWID()

SELECT @strInvoiceIds = LEFT(intInvoiceId, LEN(intInvoiceId) - 1)
FROM (
	SELECT DISTINCT CAST(intInvoiceId AS VARCHAR(200))  + ', '
	FROM @InvoiceEntries
	FOR XML PATH ('')
) C (intInvoiceId)

EXEC [dbo].[uspARPopulateInvoiceDetailForPosting] @Param = @strInvoiceIds, @strSessionId = @strSessionId
EXEC [dbo].[uspARPopulateInvoiceAccountForPosting] @Post = 1, @strSessionId = @strSessionId
EXEC [dbo].[uspARUpdateTransactionAccountOnPost] @strSessionId = @strSessionId

DELETE FROM tblARPostInvoiceHeader WHERE strSessionId = @strSessionId
DELETE FROM tblARPostInvoiceDetail WHERE strSessionId = @strSessionId
DELETE FROM tblARPostInvoiceItemAccount WHERE strSessionId = @strSessionId

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END

SET @ErrorMessage = NULL;
RETURN 1;
	
	
END