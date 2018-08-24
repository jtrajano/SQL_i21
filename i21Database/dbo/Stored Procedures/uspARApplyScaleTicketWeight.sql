CREATE PROCEDURE [dbo].[uspARApplyScaleTicketWeight]
	  @intSalesOrderId	INT
	, @intTicketId		INT
	, @intScaleUOMId    INT = NULL
	, @intUserId		INT = NULL	
	, @dblNetWeight		NUMERIC(18,6) = 0
	, @intNewInvoiceId	INT = NULL OUTPUT
AS
BEGIN
	DECLARE @dblTotalOrderedQty		NUMERIC(18, 6) = 0
	DECLARE @dblContractMaxQty		NUMERIC(18,6) = 0

	SELECT @dblTotalOrderedQty = SUM(ISNULL(SOD.dblQtyOrdered, 0))
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT I.intItemId
		FROM dbo.tblICItem I WITH (NOLOCK)
		WHERE I.ysnUseWeighScales = 1
	) I ON SOD.intItemId = I.intItemId
	WHERE intSalesOrderId = @intSalesOrderId 

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
			UPDATE tblARInvoiceDetail
			SET dblQtyShipped = 0
			WHERE intInvoiceId = @intNewInvoiceId
			IF(OBJECT_ID('tempdb..#CONTRACTHEADER') IS NOT NULL)
			BEGIN
				DROP TABLE #CONTRACTLINEITEMS
			END
			
			CREATE TABLE #CONTRACTHEADER(
				Id INT IDENTITY(1,1),
				intContractHeaderId INT
			)
			INSERT INTO #CONTRACTHEADER
			SELECT DISTINCT intContractHeaderId  FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId

			DECLARE @cntH INT = 1
			DECLARE @cntHeaders INT = 0
			SELECT @cntHeaders = COUNT(1) FROM #CONTRACTHEADER
			WHILE @cntH <= @cntHeaders
			BEGIN
			DECLARE @intContractHeader AS INT
			SELECT @intContractHeader = intContractHeaderId FROM #CONTRACTHEADER WHERE Id = @cntH
			
				DECLARE SequenceAvailable CURSOR
				FOR SELECT ARID.intInvoiceDetailId,CTCC.intContractDetailId,ARID.dblQtyShipped,CTCC.dblAvailableQty + dblQtyOrdered Available FROM tblARInvoiceDetail ARID
							LEFT JOIN vyuCTCustomerContract CTCC
								ON ARID.intContractDetailId = CTCC.intContractDetailId
							WHERE intInvoiceId = @intNewInvoiceId AND ARID.intContractHeaderId = @intContractHeader
							ORDER BY CTCC.intContractSeq ASC
				OPEN SequenceAvailable
				DECLARE @__intInvoiceDetailId INT,
						@__intContractDetalIdA INT,
						@__dblQtyShipped NUMERIC(18,6),
						@__Available NUMERIC(18,6)
				FETCH NEXT FROM SequenceAvailable
				INTO @__intInvoiceDetailId,@__intContractDetalIdA,@__dblQtyShipped,@__Available
				
				DECLARE @ysnExitInnerCursor BIT = 0
				WHILE @@FETCH_STATUS = 0 AND @ysnExitInnerCursor = 0
				BEGIN
					UPDATE ID 
					SET ID.dblQtyShipped		= CASE WHEN ISNULL(ID.intContractDetailId, 0) <> 0 THEN  CASE WHEN dbo.fnRoundBanker(@dblNetWeight, 2) > (ID.dblQtyOrdered + CTCC.dblAvailableQty) THEN ID.dblQtyOrdered + CTCC.dblAvailableQty ELSE @dblNetWeight END --ELSE  ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, @intScaleUOMId, ID.dblQtyShipped), 0) END--FOR CONTRACT ITEMS 
												WHEN ISNULL(ITEM.ysnUseWeighScales, 0) = 1 THEN dbo.fnRoundBanker(@dblNetWeight * (ID.dblQtyOrdered / @dblTotalOrderedQty), 2) --FOR SCALE ITEMS
												ELSE ID.dblQtyShipped --REGULAR ITEMS
											END
						, ID.intItemUOMId		= CASE WHEN ITEM.ysnUseWeighScales = 1 THEN @intScaleUOMId ELSE ID.intItemUOMId END
						, ID.intTicketId		= @intTicketId
					FROM tblARInvoiceDetail ID
					INNER JOIN (
					SELECT intInvoiceId
							, intCompanyLocationId
					FROM dbo.tblARInvoice
					) INVOICE ON ID.intInvoiceId = INVOICE.intInvoiceId
					INNER JOIN (
					SELECT intItemId
							, ysnUseWeighScales	= ISNULL(ysnUseWeighScales, 0)
					FROM dbo.tblICItem
					) ITEM ON ID.intItemId = ITEM.intItemId
					LEFT JOIN vyuCTCustomerContract CTCC
					ON CTCC.intItemId = ID.intItemId AND ID.intContractDetailId = CTCC.intContractDetailId
					WHERE ID.intInvoiceDetailId = @__intInvoiceDetailId AND ISNULL(ysnAddonParent,1) = 1
					/*UPDATE addon Items*/

					UPDATE ID
					SET ID.dblQtyShipped =  AddOnQty.dblQuantity * ParentAddon.dblQtyShipped
					  , ID.intTicketId		= @intTicketId
					FROM tblARInvoiceDetail ID
					INNER JOIN (
						SELECT intInvoiceId
								, intCompanyLocationId
						FROM dbo.tblARInvoice
					) INVOICE ON ID.intInvoiceId = INVOICE.intInvoiceId
					INNER JOIN (
						SELECT intItemId
								, ysnUseWeighScales	= ISNULL(ysnUseWeighScales, 0)
						FROM dbo.tblICItem
					) ITEM ON ID.intItemId = ITEM.intItemId
					LEFT JOIN tblARInvoiceDetail ParentAddon
						ON ParentAddon.intInvoiceId =  @intNewInvoiceId and ParentAddon.strAddonDetailKey = ID.strAddonDetailKey AND ParentAddon.ysnAddonParent = 1
					LEFT JOIN tblICItem AddonItemParent
						ON AddonItemParent.intItemId = ParentAddon.intItemId
					LEFT JOIN vyuARGetAddOnItems AddOnQty
						ON (AddOnQty.intItemId = ParentAddon.intItemId AND AddOnQty.intComponentItemId = ID.intItemId) and AddOnQty.intCompanyLocationId = INVOICE.intCompanyLocationId
					WHERE ParentAddon.intInvoiceDetailId = @__intInvoiceDetailId and ISNULL(ID.ysnAddonParent,1) = 0 

					/* END */
					SELECT @dblNetWeight = CASE WHEN @dblNetWeight > dblQtyShipped THEN dbo.fnRoundBanker(@dblNetWeight,2) - dbo.fnRoundBanker(dblQtyShipped,2) ELSE dbo.fnRoundBanker(dblQtyShipped,2) - dbo.fnRoundBanker(@dblNetWeight,2) END FROM tblARInvoiceDetail WHERE intInvoiceDetailId = @__intInvoiceDetailId

					EXEC dbo.uspARUpdateContractOnInvoiceFromTicket @TransactionId = @intNewInvoiceId,@ForDelete = 0, @UserId = @intUserId

					IF @dblNetWeight <= 0
					BEGIN
						SET @ysnExitInnerCursor = 1;
					END
					FETCH NEXT FROM SequenceAvailable
					INTO @__intInvoiceDetailId,@__intContractDetalIdA,@__dblQtyShipped,@__Available
				END	
				CLOSE SequenceAvailable
				DEALLOCATE SequenceAvailable

			DELETE FROM #CONTRACTHEADER WHERE Id = @cntH
			SET @cntH = @cntH + 1;
			END 	

			UPDATE ID
			SET ID.dblQtyShipped		= CASE WHEN ISNULL(ITEM.ysnUseWeighScales, 0) = 1 THEN dbo.fnRoundBanker(@dblNetWeight * (ID.dblQtyOrdered / @dblTotalOrderedQty), 2) --FOR SCALE ITEMS
											ELSE ID.dblQtyShipped --REGULAR ITEMS
										END
				, ID.intItemUOMId		= CASE WHEN ITEM.ysnUseWeighScales = 1 THEN @intScaleUOMId ELSE ID.intItemUOMId END
				, ID.intTicketId		= @intTicketId
			FROM tblARInvoiceDetail ID
			INNER JOIN (
				SELECT intInvoiceId
						, intCompanyLocationId
				FROM dbo.tblARInvoice
			) INVOICE ON ID.intInvoiceId = INVOICE.intInvoiceId
			INNER JOIN (
				SELECT intItemId
						, ysnUseWeighScales	= ISNULL(ysnUseWeighScales, 0)
				FROM dbo.tblICItem
			) ITEM ON ID.intItemId = ITEM.intItemId
			WHERE ID.intInvoiceId = @intNewInvoiceId AND ID.intContractDetailId IS NULL
			

			UPDATE ID
			SET ID.dblQtyShipped =  AddOnQty.dblQuantity * ParentAddon.dblQtyShipped
			, ID.intTicketId		= @intTicketId
			FROM tblARInvoiceDetail ID
			INNER JOIN (
				SELECT intInvoiceId
						, intCompanyLocationId
				FROM dbo.tblARInvoice
			) INVOICE ON ID.intInvoiceId = INVOICE.intInvoiceId
			INNER JOIN (
				SELECT intItemId
						, ysnUseWeighScales	= ISNULL(ysnUseWeighScales, 0)
				FROM dbo.tblICItem
			) ITEM ON ID.intItemId = ITEM.intItemId
			LEFT JOIN tblARInvoiceDetail ParentAddon
				ON ParentAddon.intInvoiceId =  @intNewInvoiceId and ParentAddon.strAddonDetailKey = ID.strAddonDetailKey AND ParentAddon.ysnAddonParent = 1
			LEFT JOIN tblICItem AddonItemParent
				ON AddonItemParent.intItemId = ParentAddon.intItemId
			LEFT JOIN vyuARGetAddOnItems AddOnQty
				ON (AddOnQty.intItemId = ParentAddon.intItemId AND AddOnQty.intComponentItemId = ID.intItemId) and AddOnQty.intCompanyLocationId = INVOICE.intCompanyLocationId
			WHERE ParentAddon.intInvoiceId = @intNewInvoiceId AND ParentAddon.intContractDetailId IS NULL and ISNULL(ID.ysnAddonParent,1) = 0
						
			IF(OBJECT_ID('tempdb..#CONTRACTLINEITEMS') IS NOT NULL)
			BEGIN
				DROP TABLE #CONTRACTLINEITEMS
			END
			
			CREATE TABLE #CONTRACTLINEITEMS(
				Id INT IDENTITY(1,1),
				intInvoiceDetailId INT,
				intContractDetailId INT,
				intContractHeaderId INT,
				dblShippedQty NUMERIC(18,6)
			)
			IF(@dblNetWeight > 0)
			BEGIN
				INSERT INTO #CONTRACTLINEITEMS
				SELECT TOP 1 intInvoiceDetailId,NULL,NULL,@dblNetWeight FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId AND intContractDetailId IS NOT NULL
			END
			
			INSERT INTO #CONTRACTLINEITEMS					
			SELECT DISTINCT ID.intInvoiceDetailId,NULL,NULL,@dblNetWeight * AddOnQty.dblQuantity FROM tblARInvoiceDetail ID
			INNER JOIN (
				SELECT intInvoiceId
						, intCompanyLocationId
				FROM dbo.tblARInvoice
			) INVOICE ON ID.intInvoiceId = INVOICE.intInvoiceId
			INNER JOIN (
				SELECT intItemId
						, ysnUseWeighScales	= ISNULL(ysnUseWeighScales, 0)
				FROM dbo.tblICItem
			) ITEM ON ID.intItemId = ITEM.intItemId
			INNER JOIN tblARInvoiceDetail ParentAddon
				ON ParentAddon.intInvoiceId =  @intNewInvoiceId and ParentAddon.strAddonDetailKey = ID.strAddonDetailKey AND ParentAddon.ysnAddonParent = 1
			LEFT JOIN tblICItem AddonItemParent
				ON AddonItemParent.intItemId = ParentAddon.intItemId
			LEFT JOIN vyuARGetAddOnItems AddOnQty
				ON (AddOnQty.intItemId = ParentAddon.intItemId AND AddOnQty.intComponentItemId = ID.intItemId) and AddOnQty.intCompanyLocationId = INVOICE.intCompanyLocationId
			WHERE ISNULL(ID.ysnAddonParent,1) = 0 AND ParentAddon.intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM #CONTRACTLINEITEMS)
			
			DECLARE @cnt INT = 1
			DECLARE @cntLineItems INT = 0
			SELECT @cntLineItems = COUNT(1) FROM #CONTRACTLINEITEMS
			WHILE @cnt <= @cntLineItems 
				BEGIN
					DECLARE @ItemId						INT
						,@ItemPrepayTypeId				INT
						,@ItemPrepayRate				NUMERIC(18,6)
						,@ItemIsBlended					BIT				= 0
						,@ErrorMessage					NVARCHAR(250)
						,@RaiseError					BIT				= 0		
						,@ItemDocumentNumber			NVARCHAR(100)	= NULL			
						,@ItemDescription				NVARCHAR(500)	= NULL
						,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
						,@ItemOrderUOMId				INT				= NULL
						,@ItemPriceUOMId				INT				= NULL
						,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
						,@ItemUnitQuantity				NUMERIC(18,6)	= 1.000000
						,@ItemDiscount					NUMERIC(18,6)	= 0.000000
						,@ItemTermDiscount				NUMERIC(18,6)	= 0.000000
						,@ItemTermDiscountBy			NVARCHAR(50)	= NULL
						,@ItemUnitPrice					NUMERIC(18,6)	= 0.000000	
						,@ItemPrice						NUMERIC(18,6)	= 0.000000	
						,@ItemPricing					NVARCHAR(250)	= NULL
						,@ItemVFDDocumentNumber			NVARCHAR(100)	= NULL
						,@RefreshPrice					BIT				= 0
						,@ItemMaintenanceType			NVARCHAR(50)	= NULL
						,@ItemFrequency					NVARCHAR(50)	= NULL
						,@ItemMaintenanceDate			DATETIME		= NULL
						,@ItemMaintenanceAmount			NUMERIC(18,6)	= 0.000000
						,@ItemLicenseAmount				NUMERIC(18,6)	= 0.000000
						,@ItemTaxGroupId				INT				= NULL
						,@ItemStorageLocationId			INT				= NULL
						,@ItemCompanyLocationSubLocationId	INT			= NULL
						,@RecomputeTax					BIT				= 1
						,@ItemSCInvoiceId				INT				= NULL
						,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
						,@ItemInventoryShipmentItemId	INT				= NULL
						,@ItemInventoryShipmentChargeId	INT				= NULL
						,@ItemShipmentNumber			NVARCHAR(50)	= NULL
						,@ItemRecipeItemId				INT				= NULL
						,@ItemRecipeId					INT				= NULL
						,@ItemSublocationId				INT				= NULL
						,@ItemCostTypeId				INT				= NULL
						,@ItemMarginById				INT				= NULL
						,@ItemCommentTypeId				INT				= NULL
						,@ItemMargin					NUMERIC(18,6)	= NULL
						,@ItemRecipeQty					NUMERIC(18,6)	= NULL
						,@ItemSalesOrderDetailId		INT				= NULL												
						,@ItemSalesOrderNumber			NVARCHAR(50)	= NULL
						,@ItemContractHeaderId			INT				= NULL
						,@ItemContractDetailId			INT				= NULL			
						,@ItemShipmentId				INT				= NULL			
						,@ItemShipmentPurchaseSalesContractId	INT		= NULL	
						,@ItemWeightUOMId				INT				= NULL	
						,@ItemWeight					NUMERIC(18,6)	= 0.000000		
						,@ItemShipmentGrossWt			NUMERIC(18,6)	= 0.000000		
						,@ItemShipmentTareWt			NUMERIC(18,6)	= 0.000000		
						,@ItemShipmentNetWt				NUMERIC(18,6)	= 0.000000			
						,@ItemTicketId					INT				= NULL		
						,@ItemTicketHoursWorkedId		INT				= NULL	
						,@ItemCustomerStorageId			INT				= NULL		
						,@ItemSiteDetailId				INT				= NULL		
						,@ItemLoadDetailId				INT				= NULL			
						,@ItemLotId						INT				= NULL			
						,@ItemOriginalInvoiceDetailId	INT				= NULL		
						,@ItemConversionAccountId		INT				= NULL
						,@ItemSalesAccountId			INT				= NULL
						,@ItemSiteId					INT				= NULL												
						,@ItemBillingBy					NVARCHAR(200)	= NULL
						,@ItemPercentFull				NUMERIC(18,6)	= 0.000000
						,@ItemNewMeterReading			NUMERIC(18,6)	= 0.000000
						,@ItemPreviousMeterReading		NUMERIC(18,6)	= 0.000000
						,@ItemConversionFactor			NUMERIC(18,8)	= 0.00000000
						,@ItemPerformerId				INT				= NULL
						,@ItemLeaseBilling				BIT				= 0
						,@ItemVirtualMeterReading		BIT				= 0
						,@EntitySalespersonId			INT				= NULL
						,@ItemCurrencyExchangeRateTypeId	INT			= NULL
						,@ItemCurrencyExchangeRateId	INT				= NULL
						,@ItemCurrencyExchangeRate		NUMERIC(18,8)	= 1.000000
						,@ItemSubCurrencyId				INT				= NULL
						,@ItemSubCurrencyRate			NUMERIC(18,8)	= 1.000000
						,@ItemStorageScheduleTypeId		INT				= NULL
						,@ItemDestinationGradeId		INT				= NULL
						,@ItemDestinationWeightId		INT				= NULL
						,@intInvoiceDetailId			INT				= NULL
						,@intItemUOMId					INT				= NULL
						,@ysnContractHasAvailable		INT				= 0
						,@ysnContractOverage			BIT				= 0
						,@intContractHeaderId			INT				= NULL
						,@intContractDetailId			INT				= NULL
						,@dblShippedQty					NUMERIC(18,6)				= 0.000000

					
					SELECT  @intInvoiceDetailId = intInvoiceDetailId, @intContractDetailId = intContractDetailId, @intContractHeaderId = intContractHeaderId, @dblShippedQty = dblShippedQty FROM #CONTRACTLINEITEMS WHERE Id = @cnt

					SELECT TOP 1
							@ItemId						= intItemId
						,@ItemPrepayTypeId				= intPrepayTypeId
						,@ItemPrepayRate				= dblPrepayRate
						,@ItemIsBlended					= ysnBlended
						,@ItemDocumentNumber			= strDocumentNumber
						,@ItemDescription				= strItemDescription
						,@ItemQtyShipped				=  CASE WHEN ISNULL(dbo.fnCalculateQtyBetweenUOM(intItemUOMId, @intScaleUOMId, @dblShippedQty), 0)  > 0 THEN CAST(@dblShippedQty as NUMERIC(18,6)) ELSE (CASE WHEN dbo.fnRoundBanker(@dblNetWeight * (dblQtyOrdered / @dblTotalOrderedQty), 2) > ISNULL(dbo.fnCalculateQtyBetweenUOM(intItemUOMId, @intScaleUOMId, dblQtyShipped), 0) THEN dbo.fnRoundBanker(@dblNetWeight * (dblQtyOrdered / @dblTotalOrderedQty), 2) - ISNULL(dbo.fnCalculateQtyBetweenUOM(intItemUOMId, @intScaleUOMId, dblQtyShipped), 0) ELSE ISNULL(dbo.fnCalculateQtyBetweenUOM(intItemUOMId, @intScaleUOMId, dblQtyShipped), 0) -  dbo.fnRoundBanker(@dblNetWeight * (dblQtyOrdered / @dblTotalOrderedQty), 2) END) END
						,@ItemOrderUOMId				= NULL
						,@ItemPriceUOMId				= intPriceUOMId
						,@ItemQtyOrdered				= 0.00000000
						,@ItemUnitQuantity				= dblUnitQuantity
						,@ItemDiscount					= dblDiscount
						,@ItemTermDiscount				= dblItemTermDiscount
						,@ItemTermDiscountBy			= strItemTermDiscountBy
						,@ItemUnitPrice					= dblUnitPrice
						,@ItemPrice						= CASE WHEN intContractDetailId IS NOT NULL THEN 0 ELSE dblPrice END
						,@ItemPricing					= strPricing
						,@ItemVFDDocumentNumber			= strVFDDocumentNumber
						,@ItemMaintenanceType			= strMaintenanceType
						,@ItemFrequency					= strFrequency
						,@ItemMaintenanceDate			= dtmMaintenanceDate
						,@ItemMaintenanceAmount			= dblMaintenanceAmount
						,@ItemLicenseAmount				= dblLicenseAmount
						,@ItemTaxGroupId				= intTaxGroupId
						,@ItemStorageLocationId			= intStorageLocationId
						,@ItemCompanyLocationSubLocationId	= intCompanyLocationSubLocationId
						,@ItemSCInvoiceId				= intSCInvoiceId
						,@ItemSCInvoiceNumber			= strSCInvoiceNumber
						,@ItemInventoryShipmentItemId	= NULL
						,@ItemInventoryShipmentChargeId	= NULL
						,@ItemShipmentNumber			= strShipmentNumber
						,@ItemRecipeItemId				= intRecipeItemId
						,@ItemRecipeId					= intRecipeId
						,@ItemCostTypeId				= intCostTypeId
						,@ItemMarginById				= intMarginById
						,@ItemCommentTypeId				= intCommentTypeId
						,@ItemMargin					= dblMargin
						,@ItemSalesOrderDetailId		= NULL
						,@ItemSalesOrderNumber			= ''
						,@ItemContractHeaderId			= @intContractHeaderId
						,@ItemContractDetailId			= @intContractDetailId
						,@ItemShipmentId				= NULL
						,@ItemShipmentPurchaseSalesContractId	= NULL
						,@ItemWeight					= 1
						,@ItemShipmentGrossWt			= 0.000000
						,@ItemShipmentTareWt			= 0.000000
						,@ItemShipmentNetWt				= 0.000000		
						,@ItemTicketId					= @intTicketId
						,@ItemTicketHoursWorkedId		= NULL
						,@ItemCustomerStorageId			= intCustomerStorageId
						,@ItemSiteDetailId				= intSiteDetailId
						,@ItemLoadDetailId				= NULL
						,@ItemLotId						= NULL
						,@ItemOriginalInvoiceDetailId	= NULL
						,@ItemConversionAccountId		= NULL
						,@ItemSalesAccountId			= NULL
						,@ItemSiteId					= NULL
						,@ItemBillingBy					= ''
						,@ItemPercentFull				= 0.000000
						,@ItemNewMeterReading			= 0.000000
						,@ItemPreviousMeterReading		= 0.000000
						,@ItemConversionFactor			= 0.00000000
						,@ItemPerformerId				= NULL
						,@ItemLeaseBilling				= 0
						,@ItemVirtualMeterReading		= 0
						,@EntitySalespersonId			= NULL
						,@ItemCurrencyExchangeRateTypeId	= intCurrencyExchangeRateTypeId
						,@ItemCurrencyExchangeRateId	= intCurrencyExchangeRateId
						,@ItemCurrencyExchangeRate		= dblCurrencyExchangeRate
						,@ItemSubCurrencyId				= intSubCurrencyId
						,@ItemSubCurrencyRate			= dblSubCurrencyRate
						,@ItemStorageScheduleTypeId		= intStorageScheduleTypeId
						,@ItemDestinationGradeId		= intDestinationGradeId
						,@ItemDestinationWeightId		= intDestinationWeightId
						,@intItemUOMId					= intItemUOMId
					FROM tblARInvoiceDetail
					WHERE intInvoiceDetailId = @intInvoiceDetailId
					  AND intInvoiceId = @intNewInvoiceId
				
					EXEC [uspARAddItemToInvoice]
						 @InvoiceId						= @intNewInvoiceId
						,@ItemId						= @ItemId
						,@ItemPrepayTypeId				= @ItemPrepayTypeId
						,@ItemPrepayRate				= @ItemPrepayRate
						,@ItemIsBlended					= @ItemIsBlended
						,@RaiseError					= 1		
						,@ItemDocumentNumber			= @ItemDocumentNumber
						,@ItemDescription				= @ItemDescription
						,@ItemOrderUOMId				= @ItemOrderUOMId
						,@ItemPriceUOMId				= @ItemPriceUOMId
						,@ItemQtyOrdered				= @ItemQtyOrdered
						,@ItemUOMId						= @intItemUOMId
						,@ItemQtyShipped				= @ItemQtyShipped
						,@ItemUnitQuantity				= @ItemUnitQuantity
						,@ItemDiscount					= @ItemDiscount
						,@ItemTermDiscount				= @ItemTermDiscount
						,@ItemTermDiscountBy			= @ItemTermDiscountBy
						,@ItemPrice						= @ItemPrice
						,@ItemUnitPrice					= @ItemUnitPrice
						,@ItemPricing					= @ItemPricing
						,@ItemVFDDocumentNumber			= @ItemVFDDocumentNumber
						,@RefreshPrice					= 0
						,@ItemMaintenanceType			= @ItemMaintenanceType
						,@ItemFrequency					= @ItemFrequency
						,@ItemMaintenanceDate			= @ItemMaintenanceDate
						,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
						,@ItemLicenseAmount				= @ItemLicenseAmount
						,@ItemTaxGroupId				= @ItemTaxGroupId
						,@ItemStorageLocationId			= @ItemStorageLocationId
						,@ItemCompanyLocationSubLocationId	= @ItemCompanyLocationSubLocationId
						,@RecomputeTax					= 1
						,@ItemSCInvoiceId				= @ItemSCInvoiceId
						,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
						,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
						,@ItemInventoryShipmentChargeId	= @ItemInventoryShipmentChargeId
						,@ItemShipmentNumber			= @ItemShipmentNumber
						,@ItemRecipeItemId				= @ItemRecipeItemId
						,@ItemRecipeId					= @ItemRecipeId
						,@ItemSublocationId				= @ItemSublocationId
						,@ItemCostTypeId				= @ItemCostTypeId
						,@ItemMarginById				= @ItemMarginById
						,@ItemCommentTypeId				= @ItemCommentTypeId
						,@ItemMargin					= @ItemMargin
						,@ItemRecipeQty					= @ItemRecipeQty
						,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
						,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
						,@ItemContractHeaderId			= @ItemContractHeaderId
						,@ItemContractDetailId			= @ItemContractDetailId
						,@ItemShipmentId				= @ItemShipmentId
						,@ItemShipmentPurchaseSalesContractId = @ItemShipmentPurchaseSalesContractId
						,@ItemWeightUOMId				= @ItemWeightUOMId
						,@ItemWeight					= @ItemWeight
						,@ItemShipmentGrossWt			= @ItemShipmentGrossWt
						,@ItemShipmentTareWt			= @ItemShipmentTareWt
						,@ItemShipmentNetWt				= @ItemShipmentNetWt
						,@ItemTicketId					= @ItemTicketId
						,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
						,@ItemCustomerStorageId			= @ItemCustomerStorageId
						,@ItemSiteDetailId				= @ItemSiteDetailId
						,@ItemLoadDetailId				= @ItemLoadDetailId
						,@ItemLotId						= @ItemLotId
						,@ItemOriginalInvoiceDetailId	= @ItemOriginalInvoiceDetailId
						,@ItemConversionAccountId		= @ItemConversionAccountId
						,@ItemSalesAccountId			= @ItemSalesAccountId
						,@ItemSiteId					= @ItemSiteId
						,@ItemBillingBy					= @ItemBillingBy
						,@ItemPercentFull				= @ItemPercentFull
						,@ItemNewMeterReading			= @ItemNewMeterReading
						,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
						,@ItemConversionFactor			= @ItemConversionFactor
						,@ItemPerformerId				= @ItemPerformerId
						,@ItemLeaseBilling				= @ItemLeaseBilling
						,@ItemVirtualMeterReading		= @ItemVirtualMeterReading
						,@EntitySalespersonId			= @EntitySalespersonId
						,@ItemCurrencyExchangeRateTypeId= @ItemCurrencyExchangeRateTypeId
						,@ItemCurrencyExchangeRateId	= @ItemCurrencyExchangeRateId
						,@ItemCurrencyExchangeRate		= @ItemCurrencyExchangeRate
						,@ItemSubCurrencyId				= @ItemSubCurrencyId
						,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
						,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
						,@ItemDestinationGradeId		= @ItemDestinationGradeId
						,@ItemDestinationWeightId		= @ItemDestinationWeightId

					DELETE FROM #CONTRACTLINEITEMS WHERE Id = @cnt
					SET @cnt = @cnt + 1;
				END

			EXEC dbo.uspARUpdateInvoiceIntegrations @InvoiceId = @intNewInvoiceId, @UserId = @intUserId
			EXEC dbo.uspARReComputeInvoiceTaxes @intNewInvoiceId
			--EXEC dbo.uspARUpdateContractOnInvoiceFromTicket @TransactionId = @intNewInvoiceId,@ForDelete = 0, @UserId = @intUserId
			

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