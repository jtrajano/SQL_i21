﻿CREATE PROCEDURE [dbo].[uspARApplyScaleTicketWeight]
	  @intSalesOrderId	INT
	, @intTicketId		INT
	, @intScaleUOMId    INT = NULL
	, @intUserId		INT = NULL	
	, @dblNetWeight		NUMERIC(18, 6) = 0
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
			UPDATE ID 
			SET ID.dblQtyShipped	= CASE WHEN ISNULL(ID.intContractDetailId, 0) <> 0 AND dbo.fnRoundBanker(@dblNetWeight * (ID.dblQtyOrdered / @dblTotalOrderedQty), 2) > ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, @intScaleUOMId, ID.dblQtyShipped), 0) THEN CASE WHEN ISNULL(ITEM.ysnUseWeighScales, 0) = 1  and ISNULL(ID.ysnAddonParent,1) <> 0 THEN CASE WHEN ( dbo.fnRoundBanker(@dblNetWeight * (ID.dblQtyOrdered / @dblTotalOrderedQty), 2) > ID.dblQtyOrdered + (CTD.dblQuantity - CTD.dblScheduleQty)) THEN ID.dblQtyOrdered + (CTD.dblQuantity - CTD.dblScheduleQty) ELSE dbo.fnRoundBanker(@dblNetWeight * (ID.dblQtyOrdered / @dblTotalOrderedQty), 2)/*(CTD.dblQuantity - CTD.dblScheduleQty)*/ END ELSE  ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, @intScaleUOMId, ID.dblQtyShipped), 0) END--FOR CONTRACT ITEMS 
											WHEN ISNULL(ITEM.ysnUseWeighScales, 0) = 1  and ISNULL(ID.ysnAddonParent,1) <> 0 THEN dbo.fnRoundBanker(@dblNetWeight * (ID.dblQtyOrdered / @dblTotalOrderedQty), 2) --FOR SCALE ITEMS
											WHEN ISNULL(ID.ysnAddonParent,0) = 0 THEN (CASE WHEN ParentAddon.dblQtyShipped IS NOT NULL THEN 
												(CASE WHEN ISNULL(ParentAddon.intContractDetailId, 0) <> 0 AND dbo.fnRoundBanker(@dblNetWeight * (ParentAddon.dblQtyOrdered / @dblTotalOrderedQty), 2) > ISNULL(dbo.fnCalculateQtyBetweenUOM(ParentAddon.intItemUOMId, @intScaleUOMId, ParentAddon.dblQtyShipped), 0) THEN CASE WHEN ISNULL(AddonItemParent.ysnUseWeighScales, 0) = 1  and ISNULL(ParentAddon.ysnAddonParent,1) <> 0 THEN  CASE WHEN ( dbo.fnRoundBanker(@dblNetWeight * (ParentAddon.dblQtyOrdered / @dblTotalOrderedQty), 2) > ParentAddon.dblQtyOrdered + (parentCTD.dblQuantity - parentCTD.dblScheduleQty)) THEN ParentAddon.dblQtyOrdered + (parentCTD.dblQuantity - parentCTD.dblScheduleQty) ELSE dbo.fnRoundBanker(@dblNetWeight * (ParentAddon.dblQtyOrdered / @dblTotalOrderedQty), 2) /*(parentCTD.dblQuantity - parentCTD.dblScheduleQty)*/ END ELSE ISNULL(dbo.fnCalculateQtyBetweenUOM(ParentAddon.intItemUOMId, @intScaleUOMId, ParentAddon.dblQtyShipped), 0) END --FOR CONTRACT ITEMS
													WHEN ISNULL(AddonItemParent.ysnUseWeighScales, 0) = 1  and ISNULL(ParentAddon.ysnAddonParent,1) <> 0 THEN dbo.fnRoundBanker(@dblNetWeight * (ParentAddon.dblQtyOrdered / @dblTotalOrderedQty), 2)
													ELSE ParentAddon.dblQtyShipped END
												)											
											 * AddOnQty.dblQuantity ELSE ParentAddon.dblQtyOrdered * AddOnQty.dblQuantity END) --FOR SCALE ITEMS ELSE ID.dblQtyShipped END)
									 ELSE ID.dblQtyShipped --REGULAR ITEMS
									 END
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
			LEFT JOIN tblCTContractDetail CTD
				ON CTD.intContractDetailId = ID.intContractDetailId
			LEFT JOIN tblCTContractDetail parentCTD
				ON parentCTD.intContractDetailId = ParentAddon.intContractDetailId
			WHERE ID.intInvoiceId = @intNewInvoiceId
	
			EXEC dbo.uspARUpdateContractOnInvoiceFromTicket @TransactionId = @intNewInvoiceId,@ForDelete = 0, @UserId = @intUserId

			IF(OBJECT_ID('tempdb..#CONTRACTLINEITEMS') IS NOT NULL)
			BEGIN
				DROP TABLE #CONTRACTLINEITEMS
			END
			IF(OBJECT_ID('tempdb..#SEQUENCEAVAILABLE') IS NOT NULL)
			BEGIN
				DROP TABLE #SEQUENCEAVAILABLE
			END
			IF(OBJECT_ID('tempdb..#OVERAGEINVOICELINE') IS NOT NULL)
			BEGIN
				DROP TABLE #OVERAGEINVOICELINE
			END

			SELECT DISTINCT  VCT.dblAvailableQty
				  , VCT.intContractSeq
				  , AID.intItemId
				  ,VCT.intContractHeaderId
				  ,VCT.intContractDetailId
			INTO #SEQUENCEAVAILABLE
			FROM tblARInvoiceDetail AID
			INNER JOIN tblCTContractDetail CCD
				ON CCD.intContractDetailId = AID.intContractDetailId
			LEFT JOIN vyuCTCustomerContract VCT
				ON VCT.intContractHeaderId = CCD.intContractHeaderId AND AID.intItemId = VCT.intItemId
			WHERE intInvoiceId = @intNewInvoiceId AND VCT.dblAvailableQty > 0

			SELECT VCT.dblAvailableQty, CASE WHEN dbo.fnRoundBanker(@dblNetWeight * (dblQtyOrdered / @dblTotalOrderedQty), 2) > ISNULL(dbo.fnCalculateQtyBetweenUOM(AID.intItemUOMId, @intScaleUOMId, dblQtyShipped), 0) THEN dbo.fnRoundBanker(@dblNetWeight * (dblQtyOrdered / @dblTotalOrderedQty), 2) - ISNULL(dbo.fnCalculateQtyBetweenUOM(AID.intItemUOMId, @intScaleUOMId, dblQtyShipped), 0) ELSE ISNULL(dbo.fnCalculateQtyBetweenUOM(AID.intItemUOMId, @intScaleUOMId, dblQtyShipped), 0) -  dbo.fnRoundBanker(@dblNetWeight * (dblQtyOrdered / @dblTotalOrderedQty), 2) END dblShipQty
				   , AID.intInvoiceDetailId
				   , AID.intInvoiceId
				   , AID.intItemId
				   , CCD.intContractHeaderId
				   , CCD.intContractDetailId 
			INTO #OVERAGEINVOICELINE
			FROM tblARInvoiceDetail AID
			INNER JOIN tblCTContractDetail CCD
				ON CCD.intContractDetailId = AID.intContractDetailId
			INNER JOIN vyuCTCustomerContract VCT
				ON VCT.intContractHeaderId = CCD.intContractHeaderId AND VCT.intContractDetailId = CCD.intContractDetailId
			WHERE intInvoiceId = @intNewInvoiceId AND VCT.dblAvailableQty = 0

			SELECT * FROM vyuCTCustomerContract WHERE intContractHeaderId = 8

			CREATE TABLE #CONTRACTLINEITEMS(
				Id INT IDENTITY(1,1),
				intInvoiceDetailId INT,
				intContractDetailId INT,
				intContractHeaderId INT,
				dblShippedQty NUMERIC(18,6)
			)

			DECLARE OverageInvoiceLines CURSOR
			FOR SELECT dblShipQty,intInvoiceDetailId,intInvoiceId,intItemId,intContractHeaderId,intContractDetailId FROM #OVERAGEINVOICELINE
			OPEN OverageInvoiceLines
			DECLARE @_dblShipQty NUMERIC(18,6),
					@_intInvoiceDetailId INT,
					@_intInvoiceId INT,
					@_intItemId INT,
					@_intContractHeaderId INT,
					@_intContractDetailId INT
			FETCH NEXT FROM OverageInvoiceLines
			INTO @_dblShipQty,@_intInvoiceDetailId,@_intInvoiceId,@_intItemId,@_intContractHeaderId,@_intContractDetailId

			WHILE(@@FETCH_STATUS = 0)
			BEGIN
				
				DECLARE SequenceAvailable CURSOR
				FOR SELECT dblAvailableQty,intContractSeq,intItemId,intContractHeaderId,intContractDetailId FROM #SEQUENCEAVAILABLE
				OPEN SequenceAvailable
				DECLARE @_dblAvailableQty NUMERIC(18,6),
						@_intContractSeq INT,
						@_intItemIdA INT,
						@_intContractHeaderIdA INT,
						@_intContractDetailIdA INT
				FETCH NEXT FROM SequenceAvailable
				INTO @_dblAvailableQty,@_intContractSeq,@_intItemIdA,@_intContractHeaderIdA,@_intContractDetailIdA 
				
				DECLARE @ysnExitInnerCursor BIT = 0
				WHILE @@FETCH_STATUS = 0 AND @ysnExitInnerCursor = 0
				BEGIN
					DECLARE @_overageQty NUMERIC(18,6)
					SET @_overageQty = CASE WHEN @_dblAvailableQty >=  @_dblShipQty THEN @_dblShipQty ELSE @_dblAvailableQty END 
					
					IF((SELECT @_dblShipQty - @_overageQty) = 0)
					BEGIN
						SET @_dblShipQty = 0;
						UPDATE #SEQUENCEAVAILABLE
						SET dblAvailableQty = dblAvailableQty - @_overageQty
						WHERE intContractSeq = @_intContractSeq AND intContractHeaderId = @_intContractHeaderIdA AND intContractDetailId = @_intContractDetailIdA

						INSERT INTO #CONTRACTLINEITEMS
						SELECT @_intInvoiceDetailId intInvoiceDetailId,@_intContractDetailIdA intContractDetailId,@_intContractHeaderIdA intContractHeaderId,@_overageQty dblShippedQty 

						SET @ysnExitInnerCursor = 1;
					END
					ELSE
						BEGIN
							SET @_dblShipQty = @_dblShipQty - @_dblAvailableQty;
							UPDATE #SEQUENCEAVAILABLE
							SET dblAvailableQty = dblAvailableQty - @_overageQty
							WHERE intContractSeq = @_intContractSeq AND intContractHeaderId = @_intContractHeaderIdA AND intContractDetailId = @_intContractDetailIdA

							INSERT INTO #CONTRACTLINEITEMS
							SELECT @_intInvoiceDetailId intInvoiceDetailId,@_intContractDetailIdA intContractDetailId,@_intContractHeaderIdA intContractHeaderId,@_overageQty dblShippedQty 
							
						END


					FETCH NEXT FROM SequenceAvailable
					INTO @_dblAvailableQty,@_intContractSeq,@_intItemIdA,@_intContractHeaderIdA,@_intContractDetailIdA 
				END	
				CLOSE SequenceAvailable
				DEALLOCATE SequenceAvailable	

				FETCH NEXT FROM OverageInvoiceLines
				INTO @_dblShipQty,@_intInvoiceDetailId,@_intInvoiceId,@_intItemId,@_intContractHeaderId,@_intContractDetailId
			END
			CLOSE OverageInvoiceLines
			DEALLOCATE OverageInvoiceLines

			INSERT INTO #CONTRACTLINEITEMS
			SELECT DISTINCT ID1.intInvoiceDetailId,ID1.intContractDetailId,ID1.intContractHeaderId,CAST(0 AS NUMERIC(18,6)) as dblShippedQty  FROM tblARInvoiceDetail ID
			INNER JOIN tblARInvoiceDetail ID1
				ON ID1.intInvoiceId = ID.intInvoiceId AND ID1.strAddonDetailKey = ID.strAddonDetailKey AND ID1.ysnAddonParent <> 1
			WHERE ID.intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM #CONTRACTLINEITEMS)

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