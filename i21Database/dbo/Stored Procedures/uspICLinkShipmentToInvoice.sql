CREATE PROCEDURE [dbo].[uspICLinkShipmentToInvoice]
	@intShipmentId int,
	@intInvoiceId int
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON

--Begin Transaction
BEGIN TRAN InventoryTransactionLink
SAVE TRAN InventoryTransactionLink

--Start Try Statement
BEGIN TRY

--User Define Type Variable
DECLARE @TransactionLink udtICTransactionLinks

--Transaction Variables
DECLARE @strShipmentNumber AS NVARCHAR(100)
DECLARE @strInvoiceNumber AS NVARCHAR(100)

--Set Transaction Numbers
SELECT TOP 1 @strInvoiceNumber = strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId
SELECT TOP 1 @strShipmentNumber = strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intShipmentId

IF @strInvoiceNumber IS NOT NULL AND @strShipmentNumber IS NOT NULL
BEGIN

INSERT INTO @TransactionLink (
	strOperation, -- Operation
	intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
	intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
)
VALUES 
(
	'Create',
	@intShipmentId, @strShipmentNumber, 'Inventory', 'Inventory Shipment',
	@intInvoiceId, @strInvoiceNumber, 'Sales (A/R)', 'Invoice'
)

EXEC dbo.uspICAddTransactionLinks @TransactionLink

END

GOTO Link_Exit

END TRY

--Catch Errors and Rollback
BEGIN CATCH

	--Rollback Exit
	GOTO Link_Rollback_Exit

END CATCH

--Rollback Transaction
Link_Rollback_Exit:
BEGIN 
	ROLLBACK TRAN InventoryTransactionLink
END

Link_Exit:
BEGIN
	COMMIT TRAN InventoryTransactionLink
END