CREATE PROCEDURE [dbo].[uspGRPostUnPricedSpotTicket]
	 @intUnPricedId INT
	,@ysnPosted BIT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @dtmDate AS DATETIME
	DECLARE @intUnitMeasureId INT
	DECLARE @intCreatedUserId INT
	DECLARE @intCreatedBillId AS INT
	DECLARE @strPriceTicket NVARCHAR(50)
	DECLARE @strTicketType NVARCHAR(50)
	DECLARE @intItemId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @dblFuturesPrice NUMERIC(18, 6)
	DECLARE @dblFuturesBasis NUMERIC(18, 6)
	DECLARE @dblCashPrice NUMERIC(18, 6)	
	DECLARE @intEntityKey INT
	DECLARE @intEntityId INT
	DECLARE @voucherDetailStorage AS [VoucherDetailStorage]
	DECLARE @success AS BIT
	DECLARE @detailCreated AS Id
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable
	DECLARE @ErrorMessage NVARCHAR(250)
	DECLARE @CreatedIvoices NVARCHAR(MAX)
	DECLARE @UpdatedIvoices NVARCHAR(MAX)
	DECLARE @InvoiceId INT
	DECLARE @UserEntityId INT
	DECLARE @intCurrencyId INT
	DECLARE @intDefaultCurrencyId INT
	DECLARE @intTermId INT
	DECLARE @ItemDescription NVARCHAR(100)
	DECLARE @intItemUOMId INT

	SET @dtmDate = GETDATE()

	SELECT @strTicketType = strTicketType
		,@strPriceTicket = strPriceTicket
		,@intCompanyLocationId = intCompanyLocationId
		,@intItemId = intItemId
		,@dblFuturesPrice = dblFuturesPrice
		,@dblFuturesBasis = dblFuturesBasis
		,@dblCashPrice = dblCashPrice
		,@intUnitMeasureId = intUnitMeasureId
		,@intCreatedUserId = intCreatedUserId
	FROM tblGRUnPriced
	WHERE intUnPricedId = @intUnPricedId

	SELECT 
		@ItemDescription = strItemNo
		, @intItemUOMId = UOM.intItemUOMId	
	FROM tblICItem IC
	INNER JOIN tblICItemUOM UOM 
		ON	UOM.intItemId = IC.intItemId 
			AND intUnitMeasureId = @intUnitMeasureId
	WHERE IC.intItemId = @intItemId

	DECLARE @tblEntity AS TABLE 
	(
		intEntityKey INT IDENTITY(1, 1)
		,intEntityId INT NULL
	)

	INSERT INTO @tblEntity (intEntityId)
	SELECT DISTINCT SC.intEntityId
	FROM tblSCTicket SC
	JOIN tblGRUnPricedSpotTicket SpotTicket 
		ON SpotTicket.intTicketId = SC.intTicketId
	WHERE SpotTicket.intUnPricedId = @intUnPricedId

	

	IF @ysnPosted = 1
	BEGIN
		IF @strTicketType = 'Inbound'
		BEGIN
			SELECT @intEntityKey = MIN(intEntityKey)
			FROM @tblEntity

			WHILE @intEntityKey > 0
			BEGIN
				SET @intEntityId = NULL

				SELECT @intEntityId = intEntityId
				FROM @tblEntity
				WHERE intEntityKey = @intEntityKey

				DELETE
				FROM @voucherDetailStorage

				INSERT INTO @voucherDetailStorage 
				(
					 [intScaleTicketId]
					,[intItemId]
					,[intAccountId]
					,[dblQtyReceived]
					,[strMiscDescription]
					,[dblCost]
					,[intContractHeaderId]
					,[intContractDetailId]
					,[intUnitOfMeasureId]
					,[dblWeightUnitQty]
					,[dblCostUnitQty]
					,[dblUnitQty]
					,[dblNetWeight]
				)
				--Inventory Item
				SELECT 
					 [intScaleTicketId]    = SpotTicket.intTicketId
					,[intItemId]           = @intItemId
					,[intAccountId]        = NULL
					,[dblQtyReceived]      = ROUND(dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,@intItemUOMId,dblUnits),2)--SpotTicket.dblUnits
					,[strMiscDescription]  = Item.strItemNo
					,[dblCost]			   = @dblCashPrice
					,[intContractHeaderId] = NULL
					,[intContractDetailId] = NULL
					,[intUnitOfMeasureId]  = @intItemUOMId--SC.intItemUOMIdTo
					,[dblWeightUnitQty]	   = 1
					,[dblCostUnitQty]      = 1
					,[dblUnitQty]	       = 1
					,[dblNetWeight]        = 0
				FROM tblGRUnPricedSpotTicket SpotTicket
				JOIN tblSCTicket SC 
					ON SC.intTicketId = SpotTicket.intTicketId
				JOIN tblICItem Item 
					ON Item.intItemId = SC.intItemId
				WHERE SpotTicket.intUnPricedId = @intUnPricedId
					AND SC.intEntityId = @intEntityId
				
				UNION
				--Discount Item
				SELECT 
					 [intScaleTicketId]    = SpotTicket.intTicketId
					,[intItemId]		   = DItem.intItemId
					,[intAccountId]        = NULL
					,[dblQtyReceived]      = 1--SpotTicket.dblUnits
					,[strMiscDescription]  = DItem.strItemNo
					,[dblCost]             = ROUND(dbo.fnSCCalculateDiscount(SpotTicket.intTicketId, QM.intTicketDiscountId, SpotTicket.dblUnits, @intItemUOMId, @dblCashPrice),2)--QM.dblDiscountDue
					,[intContractHeaderId] = NULL
					,[intContractDetailId] = NULL
					,[intUnitOfMeasureId]  = @intItemUOMId --SC.intItemUOMIdTo
					,[dblWeightUnitQty]	   = 1
					,[dblCostUnitQty]      = 1
					,[dblUnitQty]          = 1
					,[dblNetWeight]        = 0
				FROM tblGRUnPricedSpotTicket SpotTicket
				JOIN tblSCTicket SC 
					ON SC.intTicketId = SpotTicket.intTicketId
				JOIN tblICItem Item 
					ON Item.intItemId = SC.intItemId
				JOIN tblQMTicketDiscount QM 
					ON	QM.intTicketId = SC.intTicketId
						AND QM.strSourceType = 'Scale'
				JOIN tblGRDiscountScheduleCode a 
					ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
				JOIN tblICItem DItem 
					ON DItem.intItemId = a.intItemId
				WHERE SpotTicket.intUnPricedId = @intUnPricedId
					AND SC.intEntityId = @intEntityId
					AND ISNULL(QM.dblDiscountDue, 0) <> 0
				
				UNION
				
				--Fee Item
				SELECT [intScaleTicketId]  = SpotTicket.intTicketId
					,[intItemId]           = Item.intItemId
					,[intAccountId]        = NULL
					,[dblQtyReceived]      = 1--SpotTicket.dblUnits
					,[strMiscDescription]  = Item.strItemNo
					,[dblCost]			   = SC.dblTicketFees
					,[intContractHeaderId] = NULL
					,[intContractDetailId] = NULL
					,[intUnitOfMeasureId]  = @intItemUOMId --SC.intItemUOMIdTo
					,[dblWeightUnitQty]    = 1
					,[dblCostUnitQty]      = 1
					,[dblUnitQty]          = 1
					,[dblNetWeight]		   = 0
				FROM tblGRUnPricedSpotTicket SpotTicket
				JOIN tblSCTicket SC 
					ON SC.intTicketId = SpotTicket.intTicketId
				JOIN tblSCScaleSetup Setup 
					ON Setup.intScaleSetupId = SC.intScaleSetupId
				JOIN tblICItem Item 
					ON Item.intItemId = Setup.intDefaultFeeItemId
				WHERE SpotTicket.intUnPricedId = @intUnPricedId
					AND SC.intEntityId = @intEntityId
					AND ISNULL(SC.dblTicketFees, 0) <> 0

				EXEC [dbo].[uspAPCreateBillData] 
					 @userId = @intCreatedUserId
					,@vendorId = @intEntityId
					,@type = 1
					,@voucherDetailStorage = @voucherDetailStorage
					,@shipTo = @intCompanyLocationId
					,@vendorOrderNumber = NULL
					,@voucherDate = @dtmDate
					,@billId = @intCreatedBillId OUTPUT

				IF @intCreatedBillId IS NOT NULL
				BEGIN
					DELETE
					FROM @detailCreated

					INSERT INTO @detailCreated
					SELECT intBillDetailId
					FROM tblAPBillDetail
					WHERE intBillId = @intCreatedBillId

					EXEC [uspAPUpdateVoucherDetailTax] @detailCreated

					IF @@ERROR <> 0
						GOTO UnPriced_Exit;

					UPDATE bd
					SET bd.dblRate = CASE 
										 WHEN ISNULL(bd.dblRate, 0) = 0 THEN 1
										 ELSE bd.dblRate
									 END
					FROM tblAPBillDetail bd
					WHERE bd.intBillId = @intCreatedBillId

					UPDATE tblAPBill
					SET strVendorOrderNumber = @strPriceTicket
						,dblTotal = (
										SELECT ROUND(SUM(bd.dblTotal) + SUM(bd.dblTax), 2)
										FROM tblAPBillDetail bd
										WHERE bd.intBillId = @intCreatedBillId
									)
					WHERE intBillId = @intCreatedBillId

					IF @@ERROR <> 0
						GOTO UnPriced_Exit;

					EXEC [dbo].[uspAPPostBill] @post = 1
						,@recap = 0
						,@isBatch = 0
						,@param = @intCreatedBillId
						,@userId = @intCreatedUserId
						,@success = @success OUTPUT

					IF @@ERROR <> 0
						GOTO UnPriced_Exit;

					UPDATE SpotTicket
					SET intBillId = @intCreatedBillId
					FROM tblGRUnPricedSpotTicket SpotTicket
					JOIN tblSCTicket SC 
						ON SC.intTicketId = SpotTicket.intTicketId
					WHERE SpotTicket.intUnPricedId = @intUnPricedId 
						AND SC.intEntityId = @intEntityId

					UPDATE SC
					SET dblUnitPrice = @dblFuturesPrice
					   ,dblUnitBasis = @dblFuturesBasis
					FROM tblGRUnPricedSpotTicket SpotTicket
					JOIN tblSCTicket SC 
						ON SC.intTicketId = SpotTicket.intTicketId
					WHERE SpotTicket.intUnPricedId = @intUnPricedId 
						AND SC.intEntityId = @intEntityId

				END

				SELECT @intEntityKey = MIN(intEntityKey)
				FROM @tblEntity
				WHERE intEntityKey > @intEntityKey
			END
			
			UPDATE tblGRUnPriced
			SET ysnPosted = 1
			WHERE intUnPricedId = @intUnPricedId

		END
		ELSE
		BEGIN
			SELECT @intEntityKey = MIN(intEntityKey)
			FROM @tblEntity

			WHILE @intEntityKey > 0
			BEGIN
				SET @intEntityId = NULL

				SELECT @intEntityId = intEntityId
				FROM @tblEntity
				WHERE intEntityKey = @intEntityKey

				SELECT @intDefaultCurrencyId = intDefaultCurrencyId
				FROM tblSMCompanyPreference

				SET @UserEntityId = ISNULL((
							SELECT [intEntityId]
							FROM tblSMUserSecurity
							WHERE [intEntityId] = @intCreatedUserId
							), @intCreatedUserId)
				SET @intCurrencyId = ISNULL((
							SELECT intCurrencyId
							FROM tblAPVendor
							WHERE [intEntityId] = @intEntityId
							), @intDefaultCurrencyId)

				SELECT @intTermId = intTermsId
				FROM tblEMEntityLocation
				WHERE intEntityId = @intEntityId

				BEGIN TRANSACTION

				DELETE
				FROM @EntriesForInvoice

				INSERT INTO @EntriesForInvoice 
				(
					 [strTransactionType]
					,[strType]
					,[strSourceTransaction]
					,[intSourceId]
					,[strSourceId]
					,[intInvoiceId]
					,[intEntityCustomerId]
					,[intCompanyLocationId]
					,[intCurrencyId]
					,[intTermId]
					,[dtmDate]
					,[dtmDueDate]
					,[dtmShipDate]
					,[intEntitySalespersonId]
					,[intFreightTermId]
					,[intShipViaId]
					,[intPaymentMethodId]
					,[strInvoiceOriginId]
					,[strPONumber]
					,[strBOLNumber]
					--,[strDeliverPickup]
					,[strComments]
					,[intShipToLocationId]
					,[intBillToLocationId]
					,[ysnTemplate]
					,[ysnForgiven]
					,[ysnCalculated]
					,[ysnSplitted]
					,[intPaymentId]
					,[intSplitId]
					,[strActualCostId]
					,[intEntityId]
					,[ysnResetDetails]
					,[ysnPost]
					,[intInvoiceDetailId]
					,[intItemId]
					,[ysnInventory]
					,[strItemDescription]
					,[intOrderUOMId]
					,[intItemUOMId]
					,[dblQtyOrdered]
					,[dblQtyShipped]
					,[dblDiscount]
					,[dblPrice]
					,[ysnRefreshPrice]
					,[strMaintenanceType]
					,[strFrequency]
					,[dtmMaintenanceDate]
					,[dblMaintenanceAmount]
					,[dblLicenseAmount]
					,[intTaxGroupId]
					,[ysnRecomputeTax]
					,[intSCInvoiceId]
					,[strSCInvoiceNumber]
					,[intInventoryShipmentItemId]
					,[strShipmentNumber]
					,[intSalesOrderDetailId]
					,[strSalesOrderNumber]
					,[intContractHeaderId]
					,[intContractDetailId]
					,[intShipmentPurchaseSalesContractId]
					,[intTicketId]
					,[intTicketHoursWorkedId]
					,[intSiteId]
					,[strBillingBy]
					,[dblPercentFull]
					,[dblNewMeterReading]
					,[dblPreviousMeterReading]
					,[dblConversionFactor]
					,[intPerformerId]
					,[ysnLeaseBilling]
					,[ysnVirtualMeterReading]
					,[intCustomerStorageId]
				)
				SELECT 
				     [strTransactionType]					= 'Invoice'
					,[strType]								= 'Standard'
					,[strSourceTransaction]					= 'Zero Priced Spot Tickets'
					,[intSourceId]							= @intUnPricedId
					,[strSourceId]							= ''
					,[intInvoiceId]							= @InvoiceId --NULL Value will create new invoice
					,[intEntityCustomerId]					= @intEntityId
					,[intCompanyLocationId]					= @intCompanyLocationId
					,[intCurrencyId]						= @intCurrencyId
					,[intTermId]							= @intTermId
					,[dtmDate]								= GETDATE()
					,[dtmDueDate]							= NULL
					,[dtmShipDate]							= NULL
					,[intEntitySalespersonId]				= NULL
					,[intFreightTermId]						= NULL
					,[intShipViaId]							= NULL
					,[intPaymentMethodId]					= NULL
					,[strInvoiceOriginId]					= NULL --''
					,[strPONumber]							= NULL --''
					,[strBOLNumber]							= NULL --''
					--,[strDeliverPickup]						= NULL --''
					,[strComments]							= NULL --''
					,[intShipToLocationId]					= NULL
					,[intBillToLocationId]					= NULL
					,[ysnTemplate]							= 0
					,[ysnForgiven]							= 0
					,[ysnCalculated]						= 0
					,[ysnSplitted]							= 0
					,[intPaymentId]							= NULL
					,[intSplitId]							= NULL
					,[strActualCostId]						= NULL --''
					,[intEntityId]							= @UserEntityId
					,[ysnResetDetails]						= 0
					,[ysnPost]								= NULL
					,[intInvoiceDetailId]					= NULL
					,[intItemId]							= @intItemId
					,[ysnInventory]							= 1
					,[strItemDescription]					= @ItemDescription
					,[intOrderUOMId]						= @intItemUOMId --SC.intItemUOMIdTo
					,[intItemUOMId]							= @intItemUOMId --SC.intItemUOMIdTo
					,[dblQtyOrdered]						= dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,@intItemUOMId,dblUnits) --dblUnits
					,[dblQtyShipped]						= dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,@intItemUOMId,dblUnits) --dblUnits
					,[dblDiscount]							= 0
					,[dblPrice]							    = @dblCashPrice
					,[ysnRefreshPrice]						= 0
					,[strMaintenanceType]					= ''
					,[strFrequency]							= ''
					,[dtmMaintenanceDate]					= NULL
					,[dblMaintenanceAmount]					= NULL
					,[dblLicenseAmount]						= NULL
					,[intTaxGroupId]						= NULL
					,[ysnRecomputeTax]						= 1
					,[intSCInvoiceId]						= NULL
					,[strSCInvoiceNumber]					= ''
					,[intInventoryShipmentItemId]           = ISI.intInventoryShipmentItemId --NULL
					,[strShipmentNumber]					= ''
					,[intSalesOrderDetailId]				= NULL
					,[strSalesOrderNumber]					= ''
					,[intContractHeaderId]					= NULL
					,[intContractDetailId]					= NULL
					,[intShipmentPurchaseSalesContractId]   = NULL
					,[intTicketId]							= SC.intTicketId
					,[intTicketHoursWorkedId]				= NULL
					,[intSiteId]							= NULL
					,[strBillingBy]							= ''
					,[dblPercentFull]						= NULL
					,[dblNewMeterReading]					= NULL
					,[dblPreviousMeterReading]				= NULL
					,[dblConversionFactor]					= NULL
					,[intPerformerId]						= NULL
					,[ysnLeaseBilling]						= NULL
					,[ysnVirtualMeterReading]				= NULL
					,[intCustomerStorageId]					= NULL
				FROM tblGRUnPricedSpotTicket SpotTicket
				JOIN tblSCTicket SC 
					ON SC.intTicketId = SpotTicket.intTicketId
				LEFT JOIN tblICInventoryShipmentItem ISI 
					ON ISI.intSourceId = SC.intTicketId
				LEFT JOIN tblICInventoryShipment ICS 
					ON	ICS.intInventoryShipmentId = ISI.intInventoryShipmentId 
						AND ICS.intSourceType = 1
				JOIN tblICItem Item 
					ON Item.intItemId = SC.intItemId
				WHERE SpotTicket.intUnPricedId = @intUnPricedId
					AND SC.intEntityId = @intEntityId

				UNION

				--Discount Item
				SELECT 
					[strTransactionType]					= 'Invoice'
					,[strType]								= 'Standard'
					,[strSourceTransaction]					= 'Zero Priced Spot Tickets'
					,[intSourceId]							= @intUnPricedId
					,[strSourceId]							= ''
					,[intInvoiceId]							= @InvoiceId --NULL Value will create new invoice
					,[intEntityCustomerId]					= @intEntityId
					,[intCompanyLocationId]					= @intCompanyLocationId
					,[intCurrencyId]						= @intCurrencyId
					,[intTermId]							= @intTermId
					,[dtmDate]								= GETDATE()
					,[dtmDueDate]							= NULL
					,[dtmShipDate]							= NULL
					,[intEntitySalespersonId]				= NULL
					,[intFreightTermId]						= NULL
					,[intShipViaId]							= NULL
					,[intPaymentMethodId]					= NULL
					,[strInvoiceOriginId]					= NULL --''
					,[strPONumber]							= NULL --''
					,[strBOLNumber]							= NULL --''
					--,[strDeliverPickup]						= NULL --''
					,[strComments]							= NULL --''
					,[intShipToLocationId]					= NULL
					,[intBillToLocationId]					= NULL
					,[ysnTemplate]							= 0
					,[ysnForgiven]							= 0
					,[ysnCalculated]						= 0
					,[ysnSplitted]							= 0
					,[intPaymentId]							= NULL
					,[intSplitId]							= NULL
					,[strActualCostId]						= NULL --''
					,[intEntityId]							= @UserEntityId
					,[ysnResetDetails]						= 0
					,[ysnPost]								= NULL
					,[intInvoiceDetailId]					= NULL
					,[intItemId]							= DItem.intItemId
					,[ysnInventory]							= 1
					,[strItemDescription]					= DItem.strItemNo --@ItemDescription
					,[intOrderUOMId]						= @intItemUOMId --SC.intItemUOMIdTo
					,[intItemUOMId]							= @intItemUOMId --SC.intItemUOMIdTo
					,[dblQtyOrdered]						= 0 --dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,@intItemUOMId,dblUnits) --dblUnits
					,[dblQtyShipped]						= 1 --dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,@intItemUOMId,dblUnits) --dblUnits
					,[dblDiscount]							= 0
					,[dblPrice]							    = dbo.fnSCCalculateDiscount(SpotTicket.intTicketId, QM.intTicketDiscountId, SpotTicket.dblUnits, @intItemUOMId, @dblCashPrice) --@dblCashPrice
					,[ysnRefreshPrice]						= 0
					,[strMaintenanceType]					= ''
					,[strFrequency]							= ''
					,[dtmMaintenanceDate]					= NULL
					,[dblMaintenanceAmount]					= NULL
					,[dblLicenseAmount]						= NULL
					,[intTaxGroupId]						= NULL
					,[ysnRecomputeTax]						= 1
					,[intSCInvoiceId]						= NULL
					,[strSCInvoiceNumber]					= ''
					,[intInventoryShipmentItemId]           = ISI.intInventoryShipmentItemId --NULL
					,[strShipmentNumber]					= ''
					,[intSalesOrderDetailId]				= NULL
					,[strSalesOrderNumber]					= ''
					,[intContractHeaderId]					= NULL
					,[intContractDetailId]					= NULL
					,[intShipmentPurchaseSalesContractId]   = NULL
					,[intTicketId]							= SpotTicket.intTicketId
					,[intTicketHoursWorkedId]				= NULL
					,[intSiteId]							= NULL
					,[strBillingBy]							= ''
					,[dblPercentFull]						= NULL
					,[dblNewMeterReading]					= NULL
					,[dblPreviousMeterReading]				= NULL
					,[dblConversionFactor]					= NULL
					,[intPerformerId]						= NULL
					,[ysnLeaseBilling]						= NULL
					,[ysnVirtualMeterReading]				= NULL
					,[intCustomerStorageId]					= NULL
				FROM tblGRUnPricedSpotTicket SpotTicket
				JOIN tblSCTicket SC 
					ON SC.intTicketId = SpotTicket.intTicketId
				JOIN tblICItem Item 
					ON Item.intItemId = SC.intItemId
				JOIN tblQMTicketDiscount QM 
					ON	QM.intTicketId = SC.intTicketId
						AND QM.strSourceType = 'Scale'
				JOIN tblGRDiscountScheduleCode a 
					ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
				JOIN tblICItem DItem 
					ON DItem.intItemId = a.intItemId
				LEFT JOIN tblICInventoryShipmentItem ISI 
					ON ISI.intSourceId = SC.intTicketId
				LEFT JOIN tblICInventoryShipment ICS 
					ON	ICS.intInventoryShipmentId = ISI.intInventoryShipmentId 
						AND ICS.intSourceType = 1
				WHERE SpotTicket.intUnPricedId = @intUnPricedId
					AND SC.intEntityId = @intEntityId
					AND ISNULL(QM.dblDiscountDue, 0) <> 0
				
				UNION
				
				--Fee Item
				SELECT [strTransactionType]					= 'Invoice'
					,[strType]								= 'Standard'
					,[strSourceTransaction]					= 'Zero Priced Spot Tickets'
					,[intSourceId]							= @intUnPricedId
					,[strSourceId]							= ''
					,[intInvoiceId]							= @InvoiceId --NULL Value will create new invoice
					,[intEntityCustomerId]					= @intEntityId
					,[intCompanyLocationId]					= @intCompanyLocationId
					,[intCurrencyId]						= @intCurrencyId
					,[intTermId]							= @intTermId
					,[dtmDate]								= GETDATE()
					,[dtmDueDate]							= NULL
					,[dtmShipDate]							= NULL
					,[intEntitySalespersonId]				= NULL
					,[intFreightTermId]						= NULL
					,[intShipViaId]							= NULL
					,[intPaymentMethodId]					= NULL
					,[strInvoiceOriginId]					= NULL --''
					,[strPONumber]							= NULL --''
					,[strBOLNumber]							= NULL --''
					--,[strDeliverPickup]						= NULL --''
					,[strComments]							= NULL --''
					,[intShipToLocationId]					= NULL
					,[intBillToLocationId]					= NULL
					,[ysnTemplate]							= 0
					,[ysnForgiven]							= 0
					,[ysnCalculated]						= 0
					,[ysnSplitted]							= 0
					,[intPaymentId]							= NULL
					,[intSplitId]							= NULL
					,[strActualCostId]						= NULL --''
					,[intEntityId]							= @UserEntityId
					,[ysnResetDetails]						= 0
					,[ysnPost]								= NULL
					,[intInvoiceDetailId]					= NULL
					,[intItemId]							= Item.intItemId
					,[ysnInventory]							= 1
					,[strItemDescription]					= Item.strItemNo
					,[intOrderUOMId]						= @intItemUOMId --SC.intItemUOMIdTo
					,[intItemUOMId]							= @intItemUOMId --SC.intItemUOMIdTo
					,[dblQtyOrdered]						= 0--dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,@intItemUOMId,dblUnits) --dblUnits
					,[dblQtyShipped]						= 1--dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,@intItemUOMId,dblUnits) --dblUnits
					,[dblDiscount]							= 0
					,[dblPrice]							    = SC.dblTicketFees--@dblCashPrice
					,[ysnRefreshPrice]						= 0
					,[strMaintenanceType]					= ''
					,[strFrequency]							= ''
					,[dtmMaintenanceDate]					= NULL
					,[dblMaintenanceAmount]					= NULL
					,[dblLicenseAmount]						= NULL
					,[intTaxGroupId]						= NULL
					,[ysnRecomputeTax]						= 1
					,[intSCInvoiceId]						= NULL
					,[strSCInvoiceNumber]					= ''
					,[intInventoryShipmentItemId]           = ISI.intInventoryShipmentItemId --NULL
					,[strShipmentNumber]					= ''
					,[intSalesOrderDetailId]				= NULL
					,[strSalesOrderNumber]					= ''
					,[intContractHeaderId]					= NULL
					,[intContractDetailId]					= NULL
					,[intShipmentPurchaseSalesContractId]   = NULL
					,[intTicketId]							= SC.intTicketId
					,[intTicketHoursWorkedId]				= NULL
					,[intSiteId]							= NULL
					,[strBillingBy]							= ''
					,[dblPercentFull]						= NULL
					,[dblNewMeterReading]					= NULL
					,[dblPreviousMeterReading]				= NULL
					,[dblConversionFactor]					= NULL
					,[intPerformerId]						= NULL
					,[ysnLeaseBilling]						= NULL
					,[ysnVirtualMeterReading]				= NULL
					,[intCustomerStorageId]					= NULL
					--[intScaleTicketId]  = SpotTicket.intTicketId
					----,[intItemId]           = Item.intItemId
					--,[intAccountId]        = NULL
					--,[dblQtyReceived]      = SpotTicket.dblUnits
					----,[strMiscDescription]  = Item.strItemNo
					--,[dblCost]			   = SC.dblTicketFees
					--,[intContractHeaderId] = NULL
					--,[intContractDetailId] = NULL
					--,[intUnitOfMeasureId]  = SC.intItemUOMIdTo
					--,[dblWeightUnitQty]    = 1
					--,[dblCostUnitQty]      = 1
					--,[dblUnitQty]          = 1
					--,[dblNetWeight]		   = 0
				FROM tblGRUnPricedSpotTicket SpotTicket
				JOIN tblSCTicket SC 
					ON SC.intTicketId = SpotTicket.intTicketId
				JOIN tblSCScaleSetup Setup 
					ON Setup.intScaleSetupId = SC.intScaleSetupId
				JOIN tblICItem Item 
					ON Item.intItemId = Setup.intDefaultFeeItemId
				LEFT JOIN tblICInventoryShipmentItem ISI 
					ON ISI.intSourceId = SC.intTicketId
				LEFT JOIN tblICInventoryShipment ICS 
					ON	ICS.intInventoryShipmentId = ISI.intInventoryShipmentId 
						AND ICS.intSourceType = 1
				WHERE SpotTicket.intUnPricedId = @intUnPricedId
					AND SC.intEntityId = @intEntityId
					AND ISNULL(SC.dblTicketFees, 0) <> 0

				EXEC [dbo].[uspARProcessInvoices] 
					 @InvoiceEntries = @EntriesForInvoice
					,@LineItemTaxEntries = @TaxDetails
					,@UserId = @intCreatedUserId
					,@GroupingOption = 11
					,@RaiseError = 1
					,@ErrorMessage = @ErrorMessage OUTPUT
					,@CreatedIvoices = @CreatedIvoices OUTPUT
					,@UpdatedIvoices = @UpdatedIvoices OUTPUT

				IF (@ErrorMessage IS NULL)
				BEGIN
					COMMIT TRANSACTION

					UPDATE SpotTicket
					SET intInvoiceId = CONVERT(INT,@CreatedIvoices)
					FROM tblGRUnPricedSpotTicket SpotTicket
					JOIN tblSCTicket SC ON SC.intTicketId = SpotTicket.intTicketId
					WHERE SpotTicket.intUnPricedId = @intUnPricedId AND SC.intEntityId = @intEntityId

					UPDATE SC
					SET dblUnitPrice = @dblFuturesPrice
					   ,dblUnitBasis = @dblFuturesBasis
					FROM tblGRUnPricedSpotTicket SpotTicket
					JOIN tblSCTicket SC ON SC.intTicketId = SpotTicket.intTicketId
					WHERE SpotTicket.intUnPricedId = @intUnPricedId AND SC.intEntityId = @intEntityId

				END
				ELSE
				BEGIN
					RAISERROR (@ErrorMessage,16,1);
					ROLLBACK TRANSACTION
				END

				SELECT @intEntityKey = MIN(intEntityKey)
				FROM @tblEntity
				WHERE intEntityKey > @intEntityKey
			END

			UPDATE tblGRUnPriced
			SET ysnPosted = 1
			WHERE intUnPricedId = @intUnPricedId
		END
	END

	UnPriced_Exit:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

