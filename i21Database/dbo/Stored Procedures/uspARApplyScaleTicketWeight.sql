CREATE PROCEDURE [dbo].[uspARApplyScaleTicketWeight]
	  @intSalesOrderId	INT
	, @intTicketId		INT
	, @intScaleUOMId    INT = NULL
	, @intUserId		INT = NULL	
	, @dblNetWeight		NUMERIC(18, 6) = 0
	, @intNewInvoiceId	INT = NULL OUTPUT
AS
BEGIN
	DECLARE @intUnitMeasureId 				INT = NULL
	DECLARE @intEntityCustomerId			INT = NULL	
	DECLARE @intShipToLocationId			INT = NULL
	DECLARE @intContractShipToLocationId	INT = NULL
	DECLARE @intExistingInvoiceId			INT = NULL
	DECLARE @strInvalidItem					NVARCHAR(MAX) = ''
	DECLARE @strUnitMeasure					NVARCHAR(100) = ''

	SELECT @intEntityCustomerId = intEntityCustomerId
		 , @intShipToLocationId	= intShipToLocationId
	FROM dbo.tblSOSalesOrder WITH (NOLOCK)
	WHERE intSalesOrderId = @intSalesOrderId

	SELECT @intUnitMeasureId  = IUOM.intUnitMeasureId
		 , @strUnitMeasure    = UOM.strUnitMeasure
	FROM dbo.tblICItemUOM IUOM WITH (NOLOCK)
	INNER JOIN tblICUnitMeasure UOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE IUOM.intItemUOMId = @intScaleUOMId

	SELECT @intScaleUOMId = intItemUOMIdTo
		 , @dblNetWeight = dblNetUnits
	FROM vyuSCTicketScreenView 
	WHERE intTicketId = @intTicketId

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

	--VALIDATIONS
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

	--GET EXISTING INVOICE FOR BATCH SCALE
	SELECT TOP 1 @intContractShipToLocationId = CD.intShipToId
	FROM tblSOSalesOrderDetail SO
	INNER JOIN tblCTContractDetail CD ON SO.intContractDetailId = CD.intContractDetailId
	WHERE SO.intSalesOrderId = @intSalesOrderId
	  AND CD.intContractDetailId IS NOT NULL
	  AND CD.intShipToId IS NOT NULL

	SET @intShipToLocationId = ISNULL(@intContractShipToLocationId, @intShipToLocationId)

	SELECT @intExistingInvoiceId = dbo.fnARGetInvoiceForBatch(@intEntityCustomerId, @intShipToLocationId)

	--CREATE INVOICE IF THERE's NONE
	IF ISNULL(@intExistingInvoiceId, 0) = 0
		BEGIN
			EXEC dbo.uspSOProcessToInvoice @SalesOrderId = @intSalesOrderId
										 , @UserId = @intUserId
										 , @intShipToLocationId = @intContractShipToLocationId
										 , @NewInvoiceId = @intNewInvoiceId OUT
		END
	ELSE
	--INSERT TO EXISTING INVOICE
		BEGIN
			DECLARE @tblInvoiceDetailEntries	InvoiceStagingTable

			INSERT INTO @tblInvoiceDetailEntries (
				  intInvoiceDetailId
				, strSourceTransaction
				, strSourceId
				, intEntityCustomerId
				, intCompanyLocationId
				, dtmDate
				, strDocumentNumber
				, strSalesOrderNumber
				, intEntityId
				, intInvoiceId
				, intItemId
				, strItemDescription
				, intOrderUOMId
				, dblQtyOrdered
				, intItemUOMId
				, intPriceUOMId
				, dblQtyShipped
				, dblPrice
				, dblUnitPrice
				, dblContractPriceUOMQty
				, intItemWeightUOMId
				, intContractDetailId
				, intContractHeaderId
				, intTicketId
				, intTaxGroupId
				, dblCurrencyExchangeRate
				, strAddonDetailKey
				, ysnAddonParent
				, intInventoryShipmentItemId
				, intStorageLocationId
				, intSubLocationId
				, intCompanyLocationSubLocationId
				, intSalesOrderDetailId
			)
			SELECT intInvoiceDetailId				= NULL
				, strSourceTransaction				= 'Direct'
				, strSourceId						= ''
				, intEntityCustomerId				= SO.intEntityCustomerId
				, intCompanyLocationId				= SO.intCompanyLocationId
				, dtmDate							= SO.dtmDate
				, strDocumentNumber					= SO.strSalesOrderNumber
				, strSalesOrderNumber				= SO.strSalesOrderNumber
				, intEntityId						= SO.intEntityId
				, intInvoiceId						= @intExistingInvoiceId
				, intItemId							= SOD.intItemId
				, strItemDescription				= SOD.strItemDescription
				, intOrderUOMId						= SOD.intItemUOMId
				, dblQtyOrdered						= SOD.dblQtyOrdered
				, intItemUOMId						= @intScaleUOMId
				, intPriceUOMId						= @intScaleUOMId
				, dblQtyShipped						= SOD.dblQtyShipped
				, dblPrice							= SOD.dblPrice
				, dblUnitPrice						= SOD.dblPrice
				, dblContractPriceUOMQty			= @dblNetWeight
				, intItemWeightUOMId				= SOD.intItemWeightUOMId
				, intContractDetailId				= SOD.intContractDetailId
				, intContractHeaderId				= SOD.intContractHeaderId
				, intTicketId						= @intTicketId
				, intTaxGroupId						= SOD.intTaxGroupId
				, dblCurrencyExchangeRate			= SOD.dblCurrencyExchangeRate
				, strAddonDetailKey					= SOD.strAddonDetailKey
				, ysnAddonParent					= SOD.ysnAddonParent
				, intInventoryShipmentItemId		= NULL
				, intStorageLocationId				= SOD.intStorageLocationId
				, intSubLocationId					= SOD.intSubLocationId
				, intCompanyLocationSubLocationId	= SOD.intSubLocationId
				, intSalesOrderDetailId				= SOD.intSalesOrderDetailId
			FROM tblSOSalesOrderDetail SOD
			INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
			WHERE SO.intSalesOrderId = @intSalesOrderId

			EXEC dbo.uspARAddItemToInvoices @InvoiceEntries		= @tblInvoiceDetailEntries
									  	  , @IntegrationLogId	= NULL
									  	  , @UserId				= @intUserId

			SET @intNewInvoiceId = @intExistingInvoiceId

			EXEC dbo.uspARUpdateInvoiceIntegrations @intExistingInvoiceId, 0, @intUserId
			EXEC dbo.uspARReComputeInvoiceTaxes @intExistingInvoiceId
		END

	IF ISNULL(@intNewInvoiceId, 0) = 0
		BEGIN
			RAISERROR('Failed to Create Invoice.', 16, 1)
			RETURN;
		END	
	ELSE
	--RECOMPUTE OVERAGE CONTRACTS
		BEGIN
			IF ISNULL(@intTicketId, 0) > 0
				BEGIN
					UPDATE ID
					SET intTicketId = @intTicketId
					FROM tblARInvoiceDetail ID
					INNER JOIN tblSOSalesOrderDetail SOD ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
					WHERE SOD.intSalesOrderId = @intSalesOrderId
				END
				
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