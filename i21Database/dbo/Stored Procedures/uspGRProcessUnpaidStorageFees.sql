CREATE PROCEDURE [dbo].[uspGRProcessUnpaidStorageFees]
(	
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
	DECLARE @UserKey INT
	DECLARE @intCustomerStorageId INT
	DECLARE @EntityId INT
	DECLARE @LocationId INT
	DECLARE @ItemId INT
	DECLARE @dblOpenBalance DECIMAL(24, 10)
	DECLARE @dblTotalFeeUnpaid DECIMAL(24, 10)
	DECLARE @intCurrencyId INT
	DECLARE @intDefaultCurrencyId INT
	DECLARE @intTermId INT
	DECLARE @UserEntityId INT
	DECLARE @dtmDate AS DATETIME
	DECLARE @InvoiceId INT
	DECLARE @ErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable
	DECLARE @intBillFeeKey INT

	SET @dtmDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	DECLARE @BillFees AS TABLE 
	(
		 intBillFeeKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,intEntityId INT
		,intItemId INT
		,intCompanyLocationId INT
		,dblOpenBalance DECIMAL(24, 10)
		,dblFeesDue DECIMAL(24, 10)
		,dblFeesPaid DECIMAL(24, 10)
		,dblFeesUnpaid DECIMAL(24, 10)
		,dblFeesTotal DECIMAL(24, 10)
		,IsProcessed BIT
	)

	SELECT @UserKey = intCreatedUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (intCreatedUserId INT)

	SELECT @intDefaultCurrencyId = intDefaultCurrencyId
	FROM tblSMCompanyPreference

	INSERT INTO @BillFees 
	(
		 intCustomerStorageId
		,intEntityId
		,intItemId
		,intCompanyLocationId
		,dblOpenBalance
		,dblFeesDue
		,dblFeesPaid
		,dblFeesUnpaid
		,dblFeesTotal
		,IsProcessed
	)
	SELECT 
		 intCustomerStorageId
		,intEntityId
		,intItemId
		,intCompanyLocationId
		,dblOpenBalance
		,dblFeesDue
		,dblFeesPaid
		,dblFeesUnpaid
		,dblFeesTotal
		,0
	FROM OPENXML(@idoc, 'root/billfees', 2) 
	WITH 
	(
			intCustomerStorageId INT
			,intEntityId INT
			,intItemId INT
			,intCompanyLocationId INT
			,dblOpenBalance DECIMAL(24, 10)
			,dblFeesDue DECIMAL(24, 10)
			,dblFeesPaid DECIMAL(24, 10)
			,dblFeesUnpaid DECIMAL(24, 10)
			,dblFeesTotal DECIMAL(24, 10)
	)

	SELECT @intBillFeeKey = MIN(intBillFeeKey)
	FROM @BillFees
	WHERE IsProcessed = 0

	WHILE @intBillFeeKey > 0
	BEGIN
		SET @intCustomerStorageId = NULL
		SET @EntityId = NULL
		SET @LocationId = NULL
		SET @dblOpenBalance = NULL

		SELECT 
			 @intCustomerStorageId = intCustomerStorageId
			,@EntityId = intEntityId
			,@LocationId = intCompanyLocationId
			,@dblOpenBalance = dblOpenBalance
		FROM @BillFees
		WHERE intBillFeeKey = @intBillFeeKey

		SELECT @dblTotalFeeUnpaid = SUM(ISNULL(dblFeesUnpaid, 0))
		FROM @BillFees
		WHERE intEntityId = @EntityId AND intCompanyLocationId = @LocationId

		IF @dblTotalFeeUnpaid > 0
		BEGIN
			SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserKey), @UserKey)
			SET @intCurrencyId = ISNULL((SELECT intCurrencyId FROM tblAPVendor WHERE [intEntityId] = @EntityId), @intDefaultCurrencyId)

			SELECT @intTermId = intTermsId
			FROM tblEMEntityLocation
			WHERE intEntityId = @EntityId

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
			SELECT DISTINCT 
				 [strTransactionType] = 'Invoice'
				,[strType] = 'Standard'
				,[strSourceTransaction] = 'Process Grain Storage'
				,[intSourceId] = NULL
				,[strSourceId] = ''
				,[intInvoiceId] = @InvoiceId --NULL Value will create new invoice    
				,[intEntityCustomerId] = @EntityId
				,[intCompanyLocationId] = @LocationId
				,[intCurrencyId] = @intCurrencyId
				,[intTermId] = @intTermId
				,[dtmDate] = GETDATE()
				,[dtmDueDate] = NULL
				,[dtmShipDate] = NULL
				,[intEntitySalespersonId] = NULL
				,[intFreightTermId] = NULL
				,[intShipViaId] = NULL
				,[intPaymentMethodId] = NULL
				,[strInvoiceOriginId] = NULL --''    
				,[strPONumber] = NULL --''    
				,[strBOLNumber] = NULL --''    
				--,[strDeliverPickup] = NULL --''    
				,[strComments] = NULL --''    
				,[intShipToLocationId] = NULL
				,[intBillToLocationId] = NULL
				,[ysnTemplate] = 0
				,[ysnForgiven] = 0
				,[ysnCalculated] = 0
				,[ysnSplitted] = 0
				,[intPaymentId] = NULL
				,[intSplitId] = NULL
				,[strActualCostId] = NULL --''    
				,[intEntityId] = @UserEntityId
				,[ysnResetDetails] = 0
				,[ysnPost] = NULL
				,[intInvoiceDetailId] = NULL
				,[intItemId] = Item.intItemId
				,[ysnInventory] = 1
				,[strItemDescription] = Item.strItemNo
				,[intOrderUOMId] = ItemUOM.intItemUOMId
				,[intItemUOMId] = ItemUOM.intItemUOMId
				,[dblQtyOrdered] = BD.dblOpenBalance
				,[dblQtyShipped] = BD.dblOpenBalance
				,[dblDiscount] = 0
				,[dblPrice] = BD.dblFeesUnpaid
				,[ysnRefreshPrice] = 0
				,[strMaintenanceType] = ''
				,[strFrequency] = ''
				,[dtmMaintenanceDate] = NULL
				,[dblMaintenanceAmount] = NULL
				,[dblLicenseAmount] = NULL
				,[intTaxGroupId] = NULL
				,[ysnRecomputeTax] = 1
				,[intSCInvoiceId] = NULL
				,[strSCInvoiceNumber] = ''
				,[intInventoryShipmentItemId] = NULL
				,[strShipmentNumber] = ''
				,[intSalesOrderDetailId] = NULL
				,[strSalesOrderNumber] = ''
				,[intContractHeaderId] = NULL
				,[intContractDetailId] = NULL
				,[intShipmentPurchaseSalesContractId] = NULL
				,[intTicketId] = NULL
				,[intTicketHoursWorkedId] = NULL
				,[intSiteId] = NULL
				,[strBillingBy] = ''
				,[dblPercentFull] = NULL
				,[dblNewMeterReading] = NULL
				,[dblPreviousMeterReading] = NULL
				,[dblConversionFactor] = NULL
				,[intPerformerId] = NULL
				,[ysnLeaseBilling] = NULL
				,[ysnVirtualMeterReading] = NULL
				,[intCustomerStorageId] = BD.intCustomerStorageId
			FROM @BillFees BD
			JOIN tblGRCustomerStorage CS ON CS.intItemId = BD.intItemId AND CS.intCustomerStorageId = BD.intCustomerStorageId
			JOIN tblSCTicket SC ON SC.intTicketId = CS.intTicketId
			JOIN tblSCScaleSetup ScaleSetup ON ScaleSetup.intScaleSetupId = SC.intScaleSetupId
			JOIN tblICItem Item ON Item.intItemId = ScaleSetup.intDefaultFeeItemId
			JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
			JOIN tblICItemUOM ItemUOM ON ItemUOM.intUnitMeasureId = CU.intUnitMeasureId AND ItemUOM.intItemId = BD.intItemId
			WHERE BD.intEntityId = @EntityId AND BD.intCompanyLocationId = @LocationId AND BD.IsProcessed = 0

			EXEC [dbo].[uspARProcessInvoices] 
				 @InvoiceEntries = @EntriesForInvoice
				,@LineItemTaxEntries = @TaxDetails
				,@UserId = @UserKey
				,@GroupingOption = 11
				,@RaiseError = 1
				,@ErrorMessage = @ErrorMessage OUTPUT
				,@CreatedIvoices = @CreatedIvoices OUTPUT
				,@UpdatedIvoices = @UpdatedIvoices OUTPUT

			IF (@ErrorMessage IS NULL)
			BEGIN
				COMMIT TRANSACTION

				INSERT INTO [dbo].[tblGRStorageHistory] 
				(
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intInvoiceId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strType]
					,[strUserName]
				)
				SELECT 
					 [intConcurrencyId] = 1
					,[intCustomerStorageId] = ARD.intCustomerStorageId
					,[intInvoiceId] = AR.intInvoiceId
					,[dblUnits] = dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ARD.dblQtyOrdered)
					,[dtmHistoryDate] = GetDATE()
					,[dblPaidAmount] = ARD.dblPrice
					,[strType] = 'Generated Fee Invoice'
					,[strUserName] = (SELECT strUserName FROM tblSMUserSecurity WHERE [intEntityId] = @UserKey)
				FROM tblARInvoice AR
				JOIN tblARInvoiceDetail ARD ON ARD.intInvoiceId = AR.intInvoiceId
				JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = ARD.intCustomerStorageId
				JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
				WHERE AR.intInvoiceId = CONVERT(INT, @CreatedIvoices)

				UPDATE CS
				SET CS.dblFeesPaid = CS.dblFeesDue
				FROM tblGRCustomerStorage CS
				JOIN @BillFees BD ON BD.intCustomerStorageId = CS.intCustomerStorageId
				WHERE BD.IsProcessed = 0 AND BD.intEntityId = @EntityId AND BD.intCompanyLocationId = @LocationId
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				RAISERROR (@ErrorMessage,16,1);
			END;
		END

		UPDATE @BillFees
		SET IsProcessed = 1
		WHERE intEntityId = @EntityId AND intCompanyLocationId = @LocationId

		SELECT @intBillFeeKey = MIN(intBillFeeKey)
		FROM @BillFees
		WHERE intBillFeeKey > @intBillFeeKey AND IsProcessed = 0
	END

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	
	SET @ErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

END CATCH
