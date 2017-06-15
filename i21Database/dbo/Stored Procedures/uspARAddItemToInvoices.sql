CREATE PROCEDURE [dbo].[uspARAddItemToInvoices]
	 @InvoiceEntries	InvoiceStagingTable	READONLY
	,@IntegrationLogId	INT					= NULL
	,@UserId			INT
	,@RaiseError		BIT					= 0
	,@ErrorMessage		NVARCHAR(250)		= NULL	OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
	
DECLARE  @ZeroDecimal		NUMERIC(18, 6)
		,@AddDetailError	NVARCHAR(MAX) 
SET @ZeroDecimal = 0.000000

IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION

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

	IF LEN(ISNULL(@AddDetailError,'')) > 0
		BEGIN
			IF ISNULL(@RaiseError,0) = 0
				ROLLBACK TRANSACTION
			SET @ErrorMessage = @AddDetailError;
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION
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

		IF LEN(ISNULL(@AddDetailError,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
					ROLLBACK TRANSACTION
				SET @ErrorMessage = @AddDetailError;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
		END TRY
		BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
				ROLLBACK TRANSACTION
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

			IF LEN(ISNULL(@AddDetailError,'')) > 0
				BEGIN
					IF ISNULL(@RaiseError,0) = 0
						ROLLBACK TRANSACTION
					SET @ErrorMessage = @AddDetailError;
					IF ISNULL(@RaiseError,0) = 1
						RAISERROR(@ErrorMessage, 16, 1);
					RETURN 0;
				END
		END TRY
		BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
				ROLLBACK TRANSACTION
			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH	
	END
	
		
--UPDATE tblARInvoiceDetail SET intStorageScheduleTypeId = ABC.intStorageScheduleTypeId, intCompanyLocationSubLocationId = ABC.intSubLocationId, intStorageLocationId = ABC.intStorageLocationId
--FROM 
--(SELECT intInvoiceId FROM tblARInvoiceDetail) ARID
--INNER JOIN
--(
--SELECT intInvoiceId, intStorageScheduleTypeId, intStorageLocationId, intSubLocationId FROM tblICInventoryShipment ICIS WITH (NOLOCK)
--INNER JOIN (SELECT intInventoryShipmentId, intItemId, intItemUOMId, intOrderId, intStorageLocationId, intSubLocationId FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI ON ICIS.intInventoryShipmentId = ICISI.intInventoryShipmentId
--INNER JOIN (SELECT SO.intSalesOrderId, SO.strSalesOrderNumber, intStorageScheduleTypeId, intItemId, intItemUOMId FROM tblSOSalesOrder SO  WITH (NOLOCK)
--			INNER JOIN (SELECT intSalesOrderId, intStorageScheduleTypeId, intItemId, intItemUOMId  FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOD ON SO.intSalesOrderId = SOD.intSalesOrderId) SO ON ICIS.strReferenceNumber = SO.strSalesOrderNumber AND ICISI.intItemId = SO.intItemId AND ICISI.intItemUOMId = SO.intItemUOMId
--INNER JOIN (SELECT ARI.intInvoiceId, ARID.strDocumentNumber, strInvoiceNumber, intItemId, intItemUOMId FROM tblARInvoice ARI   WITH (NOLOCK)
--			INNER JOIN (SELECT intInvoiceId, strDocumentNumber, intItemId, intItemUOMId FROM tblARInvoiceDetail WITH (NOLOCK)) ARID ON ARI.intInvoiceId = ARID.intInvoiceId 
--						WHERE strDocumentNumber IS NOT NULL AND ISNULL(strDocumentNumber,'') <> '' AND ARI.intInvoiceId = @InvoiceId ) ARI ON ICIS.strShipmentNumber = ARI.strDocumentNumber AND ICISI.intItemId = ARI.intItemId AND ICISI.intItemUOMId = ARI.intItemUOMId
--) ABC ON ARID.intInvoiceId = ABC.intInvoiceId
--WHERE ARID.intInvoiceId = @InvoiceId


--EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION

SET @ErrorMessage = NULL;
RETURN 1;
	
	
END