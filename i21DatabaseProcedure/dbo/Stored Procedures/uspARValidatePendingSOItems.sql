CREATE PROCEDURE [dbo].[uspARValidatePendingSOItems]
	@salesOrderId INT,
	@isValid BIT OUTPUT
AS

BEGIN	
	DECLARE @salesOrderNo NVARCHAR(25)
	SET @isValid = 1
	SELECT @salesOrderNo = strSalesOrderNumber FROM tblSOSalesOrder WHERE intSalesOrderId = @salesOrderId
	
	IF EXISTS (SELECT NULL FROM tblICInventoryShipment WHERE strReferenceNumber = @salesOrderNo)
	BEGIN
		SET @isValid = 0
	END

	IF EXISTS (SELECT NULL FROM tblICInventoryShipmentItem WHERE intOrderId = @salesOrderId)
	BEGIN
		SET @isValid = 0
	END	

	IF EXISTS (SELECT NULL FROM tblSOSalesOrderDetail SOD 
				INNER JOIN tblARInvoiceDetail ID ON SOD.intSalesOrderDetailId = ID.intSalesOrderDetailId
				WHERE ID.intSalesOrderDetailId IS NOT NULL AND SOD.intSalesOrderId = @salesOrderId)
	BEGIN
		SET @isValid = 0
	END	
END