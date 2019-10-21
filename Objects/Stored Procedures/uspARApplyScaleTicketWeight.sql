CREATE PROCEDURE [dbo].[uspARApplyScaleTicketWeight]
	  @intSalesOrderId	INT
	, @intTicketId		INT
	, @intScaleUOMId    INT = NULL
	, @intUserId		INT = NULL	
	, @dblNetWeight		NUMERIC(18, 6) = 0
	, @intNewInvoiceId	INT = NULL OUTPUT
AS
BEGIN
	DECLARE @intUnitMeasureId 		INT = NULL
	DECLARE @strInvalidItem			NVARCHAR(MAX) = ''
	DECLARE @strUnitMeasure			NVARCHAR(100) = ''

	SELECT @intUnitMeasureId  = IUOM.intUnitMeasureId
		 , @strUnitMeasure    = UOM.strUnitMeasure
	FROM dbo.tblICItemUOM IUOM WITH (NOLOCK)
	INNER JOIN tblICUnitMeasure UOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE IUOM.intItemUOMId = @intScaleUOMId

	SELECT TOP 1 @strInvalidItem = I.strItemNo + ' - ' + I.strDescription
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT I.intItemId
		     , I.strItemNo
			 , I.strDescription
		FROM dbo.tblICItem I WITH (NOLOCK)
		LEFT JOIN dbo.tblICItemUOM IUOM ON I.intItemId = IUOM.intItemId AND IUOM.intUnitMeasureId = @intUnitMeasureId
		WHERE I.ysnUseWeighScales = 1
		  AND IUOM.intItemUOMId IS NULL
	) I ON SOD.intItemId = I.intItemId 
	WHERE intSalesOrderId = @intSalesOrderId

	IF ISNULL(@strInvalidItem, '') <> ''
		BEGIN
			DECLARE @strErrorMsg NVARCHAR(MAX) = 'Item ' + @strInvalidItem + ' doesn''t have UOM setup for ' + @strUnitMeasure + '.'

			RAISERROR(@strErrorMsg, 16, 1)
			RETURN;
		END
		
	IF ISNULL(@intSalesOrderId, 0) = 0
		BEGIN
			RAISERROR('Sales Order ID is required.', 16, 1)
			RETURN;
		END

	IF ISNULL(@intTicketId, 0) = 0
		BEGIN
			RAISERROR('Scale Ticket ID is required.', 16, 1)
			RETURN;
		END

	IF ISNULL(@dblNetWeight, 0) = 0
		BEGIN
			RAISERROR('Net Weight should not be zero.', 16, 1)
			RETURN;
		END

	IF NOT EXISTS (SELECT NULL FROM tblSOSalesOrder WHERE intSalesOrderId = @intSalesOrderId)
		BEGIN
			RAISERROR('Sales Order is not existing.', 16, 1)
			RETURN;
		END

	IF NOT EXISTS (SELECT TOP 1 NULL FROM tblSOSalesOrderDetail SOD INNER JOIN tblICItem I ON SOD.intItemId = I.intItemId AND I.ysnUseWeighScales = 1 WHERE intSalesOrderId = @intSalesOrderId)
		BEGIN
			RAISERROR('Sales Order doesn''t have scale item.', 16, 1)
			RETURN;
		END

	EXEC dbo.uspSOProcessToInvoice @SalesOrderId = @intSalesOrderId
								 , @UserId = @intUserId
								 , @NewInvoiceId = @intNewInvoiceId OUT

	IF ISNULL(@intNewInvoiceId, 0) = 0
		BEGIN
			RAISERROR('Failed to Create Invoice.', 16, 1)
			RETURN;
		END	
	ELSE
		BEGIN
			SELECT @intScaleUOMId = intItemUOMIdTo
				 , @dblNetWeight = dblNetUnits
			FROM vyuSCTicketScreenView 
			WHERE intTicketId = @intTicketId

			EXEC dbo.uspARUpdateOverageContracts @intInvoiceId 		= @intNewInvoiceId
											   , @intScaleUOMId		= @intScaleUOMId
											   , @intUserId			= @intUserId
											   , @dblNetWeight		= @dblNetWeight
											   , @ysnFromSalesOrder = 1
											   , @intTicketId		= @intTicketId
			
			UPDATE SO 
			SET SO.strOrderStatus = CASE WHEN SOD.dblQtyShipped >= SOD.dblQtyOrdered THEN 'Closed' ELSE 'Short Closed' END
			FROM tblSOSalesOrder SO
			CROSS APPLY (
				SELECT dblQtyOrdered = SUM(DETAIL.dblQtyOrdered)
					 , dblQtyShipped = SUM(DETAIL.dblQtyShipped)
				FROM tblSOSalesOrderDetail DETAIL
				WHERE DETAIL.intSalesOrderId = SO.intSalesOrderId
				GROUP BY DETAIL.intSalesOrderId
			) SOD
			WHERE SO.intSalesOrderId = @intSalesOrderId

		END
END