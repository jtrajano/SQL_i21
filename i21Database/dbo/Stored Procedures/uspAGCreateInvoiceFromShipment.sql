
CREATE PROCEDURE [dbo].[uspAGCreateInvoiceFromShipment]
	 @ShipmentId		   			AS INT
	,@UserId			   			AS INT
	,@NewInvoiceId		   			AS INT	= NULL OUTPUT		
	,@OnlyUseShipmentPrice 			AS BIT  = 0
	,@IgnoreNoAvailableItemError 	AS BIT  = 0
	,@dtmShipmentDate				AS DATETIME = NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

EXEC uspARCreateInvoiceFromShipment
    @ShipmentId = @ShipmentId,
    @UserId = @UserId,
    @NewInvoiceId = @NewInvoiceId OUTPUT

    
    

END