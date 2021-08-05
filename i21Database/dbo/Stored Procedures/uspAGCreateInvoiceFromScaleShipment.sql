CREATE PROCEDURE [dbo].[uspAGCreateInvoiceFromScaleShipment]
	@intWorkOrderId			AS INT
   ,@UserId					AS INT 
   ,@NewInvoiceId			AS INT OUTPUT
   

AS

BEGIN

  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  


IF  OBJECT_ID('tempdb..#tmpAGShipment') IS NOT NULL
	DROP TABLE #tmpAGShipment

CREATE TABLE #tmpAGShipment
(
	[id]							INT IDENTITY(1,1)
	,[intTicketId]					INT
	,[intWorkOrderId]				INT
	,[intSourceId]					INT
	,[intInventoryShipmentId]		INT
	--,[intInventoryShipmentItemId]	INT
	,[ysnPosted]					BIT DEFAULT(0)
)


INSERT INTO #tmpAGShipment
SELECT SC.intTicketId, 
	WO.intWorkOrderId, 
	ICSHIPMENT.intSourceId, 
	ICSHIPMENT.intInventoryShipmentId, 
	--ICSHIPMENT.intInventoryShipmentItemId, 
	ICSHIPMENT.ysnPosted 
FROM tblSCTicket SC
INNER JOIN tblAGWorkOrder WO ON WO.intWorkOrderId = SC.intAGWorkOrderId
INNER JOIN (
	SELECT IC.intInventoryShipmentId, 
		ICS.intInventoryShipmentItemId, 
		ICS.intSourceId,
		IC.intSourceType, 
		IC.ysnPosted  
		FROM tblICInventoryShipmentItem ICS
			INNER JOIN tblICInventoryShipment IC ON IC.intInventoryShipmentId = ICS.intInventoryShipmentId
) ICSHIPMENT on ICSHIPMENT.intSourceId = SC.intTicketId
WHERE 
WO.intWorkOrderId = @intWorkOrderId 
	AND  ICSHIPMENT.ysnPosted = 1 AND ICSHIPMENT.intSourceType = 1 --SCALE



/*****CREATE INVOICE FROM IS*****/
--TODO: ON MULTIPLE IS TO SINGLE INVOICE


DECLARE @newInvoiceIds NVARCHAR(MAX) = N'';
DECLARE @newIvoiceId   INT


IF EXISTS (SELECT TOP 1 1 FROM #tmpAGShipment)
BEGIN

DECLARE @id INT = NULL
DECLARE @intInventoryShipmentId INT = NULL

	SELECT TOP 1 @id = id
				,@intInventoryShipmentId = intInventoryShipmentId
	 FROM #tmpAGShipment

	 --create invoice
		EXEC uspAGCreateInvoiceFromShipment
				@ShipmentId		 = @intInventoryShipmentId
				,@UserId		 = @UserId
				,@intAGWorkOrderId = @intWorkOrderId
				,@NewInvoiceId	 = @NewInvoiceId OUTPUT
	 	

	 DELETE FROM #tmpAGShipment --WHERE id = @id
END

SELECT @NewInvoiceId

END