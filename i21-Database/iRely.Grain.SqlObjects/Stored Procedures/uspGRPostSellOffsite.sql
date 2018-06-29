CREATE PROCEDURE [dbo].[uspGRPostSellOffsite]
	 @intSellOffsiteId INT
	,@ysnPosted BIT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @SellOffsiteId INT
	DECLARE @EntityId INT
	DECLARE @LocationId INT
	DECLARE @ItemId INT
	DECLARE @intUnitMeasureId INT
	DECLARE @CommodityStockUomId INT
	DECLARE @intCompanyLocationSubLocationId INT
	DECLARE @intSaleEntityId INT
	DECLARE @strOffsiteTicket NVARCHAR(20)
	DECLARE @intSourceItemUOMId INT
	DECLARE @UserKey INT
	DECLARE @UserName NVARCHAR(100)
	DECLARE @SellOffsiteKey INT
	DECLARE @CurrentItemOpenBalance DECIMAL(24, 10)
	DECLARE @intCustomerStorageId INT
	DECLARE @dblStorageUnits DECIMAL(24, 10)
	DECLARE @dblNegativeStorageUnits DECIMAL(24, 10)
	DECLARE @dblOpenBalance DECIMAL(24, 10)
	DECLARE @strStorageTicketNumber NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
	DECLARE @intStorageTypeId INT
	DECLARE @intStorageScheduleId INT
	DECLARE @ContractDetailId INT
	DECLARE @SellContractKey INT
	DECLARE @intContractDetailId INT
	DECLARE @intContractHeaderId INT
	DECLARE @dblContractUnits DECIMAL(24, 10)
	DECLARE @dblNegativeContractUnits DECIMAL(24, 10)
	DECLARE @ContractEntityId INT
	DECLARE @dblCashPrice DECIMAL(24, 10)
	DECLARE @dblSpotUnits DECIMAL(24, 10)
	DECLARE @dblSpotPrice DECIMAL(24, 10)
	DECLARE @dblSpotBasis DECIMAL(24, 10)
	DECLARE @dblSpotCashPrice DECIMAL(24, 10)
	DECLARE @InventoryStockUOMKey INT
	DECLARE @InventoryStockUOM NVARCHAR(50)
	DECLARE @intExternalId INT
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
	
	DECLARE @SellOffsite AS TABLE 
	(
		intSellOffsiteKey INT IDENTITY(1, 1)
		,intSellOffsiteTicketId INT
		,intCustomerStorageId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblRemainingUnits DECIMAL(24, 10)
		,dblOpenBalance DECIMAL(24, 10)
		,strStorageTicketNumber NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intCompanyLocationId INT
		,intStorageTypeId INT
		,intStorageScheduleId INT
	)
	
	DECLARE @SellContract AS TABLE 
	(
		intSellContractKey INT IDENTITY(1, 1)
		,intSellContractId INT
		,intContractDetailId INT
		,dblContractUnits DECIMAL(24, 10)
		,ContractEntityId INT
		,dblCashPrice DECIMAL(24, 10)
	)
	
	DECLARE @OffSiteInvoiceCreate AS TABLE 
	(
		intCustomerStorageId INT
		,intContractHeaderId INT NULL
		,intContractDetailId INT NULL
		,dblUnits DECIMAL(24, 10)
		,dblCashPrice DECIMAL(24, 10)
	)

	SELECT 
		 @UserKey = intCreatedUserId
		,@ItemId = intItemId
		,@intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
		,@intSaleEntityId = intEntityId
		,@strOffsiteTicket = strOffsiteTicket
	FROM tblGRSellOffsite WHERE intSellOffsiteId=@intSellOffsiteId

	SELECT @UserName = strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityId] = @UserKey

	SELECT @intUnitMeasureId = a.intUnitMeasureId
	FROM tblICCommodityUnitMeasure a
	JOIN tblICItem b ON b.intCommodityId = a.intCommodityId
	WHERE b.intItemId = @ItemId
		AND a.ysnStockUnit = 1

	IF @intUnitMeasureId IS NULL
	BEGIN
		RAISERROR ('The stock UOM of the commodity must be set for item',16,1);
		RETURN;
	END

	IF NOT EXISTS ( SELECT 1 FROM tblICItemUOM WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId)
	BEGIN
		RAISERROR ('The stock UOM of the commodity must exist in the conversion table of the item',16,1);
	END

	SELECT @intSourceItemUOMId = intItemUOMId
	FROM tblICItemUOM UOM
	WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId

	SELECT @ItemDescription = strItemNo
	FROM tblICItem
	WHERE intItemId = @ItemId

	IF @ysnPosted = 1
	BEGIN
		INSERT INTO @SellOffsite 
		(
			 intSellOffsiteTicketId
			,intCustomerStorageId
			,dblStorageUnits
			,dblRemainingUnits
			,dblOpenBalance
			,strStorageTicketNumber
			,intCompanyLocationId
			,intStorageTypeId
			,intStorageScheduleId
		)
		SELECT 
			 intSellOffsiteTicketId = SST.intSellOffsiteTicketId
			,intCustomerStorageId = SST.intCustomerStorageId
			,dblStorageUnits = SST.dblUnits
			,dblRemainingUnits = SST.dblUnits
			,dblOpenBalance = SSV.dblOpenBalance
			,strStorageTicketNumber = SSV.strStorageTicketNumber
			,intCompanyLocationId = SSV.intCompanyLocationId
			,intStorageTypeId = SSV.intStorageTypeId
			,intStorageScheduleId = SSV.intStorageScheduleId
		FROM tblGRSellOffsiteTicket SST
		JOIN vyuGROffSiteSearchView SSV ON SSV.intCustomerStorageId = SST.intCustomerStorageId
		WHERE SST.intSellOffsiteId = @intSellOffsiteId AND SST.dblUnits > 0
		ORDER BY SST.intSellOffsiteTicketId

		INSERT INTO @SellContract 
		(
			intSellContractId
			,intContractDetailId
			,dblContractUnits
			,ContractEntityId
			,dblCashPrice
		)
		SELECT 
			 intSellContractId = SSC.intSellContractId
			,intContractDetailId = SSC.intContractDetailId
			,dblContractUnits = SSC.dblUnits
			,ContractEntityId = CD.intEntityId
			,dblCashPrice = CD.dblCashPriceInCommodityStockUOM
		FROM tblGRSellContract SSC
		JOIN vyuGRGetContracts CD ON CD.intContractDetailId = SSC.intContractDetailId
		WHERE intSellOffsiteId = @intSellOffsiteId AND SSC.dblUnits > 0
		ORDER BY SSC.intSellContractId
	END

	SELECT @SellOffsiteKey = MIN(intSellOffsiteKey)
	FROM @SellOffsite
	WHERE dblRemainingUnits > 0

	SET @intCustomerStorageId = NULL
	SET @dblStorageUnits = NULL
	SET @dblOpenBalance = NULL
	SET @strStorageTicketNumber = NULL
	SET @intCompanyLocationId = NULL
	SET @intStorageTypeId = NULL
	SET @intStorageScheduleId = NULL
	SET @CurrentItemOpenBalance = NULL
	SET @ContractDetailId = NULL

	WHILE @SellOffsiteKey > 0
	BEGIN
		SELECT @intCustomerStorageId = intCustomerStorageId
			,@dblStorageUnits = dblStorageUnits
			,@dblOpenBalance = dblOpenBalance
			,@strStorageTicketNumber = strStorageTicketNumber
			,@intCompanyLocationId = intCompanyLocationId
			,@intStorageTypeId = intStorageTypeId
			,@intStorageScheduleId = intStorageScheduleId
		FROM @SellOffsite
		WHERE intSellOffsiteKey = @SellOffsiteKey

		IF EXISTS (
				SELECT 1
				FROM @SellContract
				WHERE dblContractUnits > 0
				)
		BEGIN
			SELECT @SellContractKey = MIN(intSellContractKey)
			FROM @SellContract
			WHERE dblContractUnits > 0

			SET @intContractDetailId = NULL
			SET @dblContractUnits = NULL
			SET @ContractEntityId = NULL
			SET @dblCashPrice = NULL
			SET @intContractHeaderId = NULL
			SET @dblNegativeContractUnits = NULL

			WHILE @SellContractKey > 0
			BEGIN
				SELECT @intContractDetailId = intContractDetailId
					,@dblContractUnits = dblContractUnits
					,@ContractEntityId = ContractEntityId
					,@dblCashPrice = dblCashPrice
				FROM @SellContract
				WHERE intSellContractKey = @SellContractKey

				SELECT @intContractHeaderId = intContractHeaderId
				FROM tblCTContractDetail
				WHERE intContractDetailId = @intContractDetailId

				IF @dblStorageUnits <= @dblContractUnits
				BEGIN
					UPDATE @SellContract
					SET dblContractUnits = dblContractUnits - @dblStorageUnits
					WHERE intSellContractKey = @SellContractKey

					UPDATE tblGRCustomerStorage
					SET dblOpenBalance = dblOpenBalance - @dblStorageUnits
					WHERE intCustomerStorageId = @intCustomerStorageId

					INSERT INTO [dbo].[tblGRStorageHistory] (
						[intConcurrencyId]
						,[intCustomerStorageId]
						,[intInvoiceId]
						,[intContractHeaderId]
						,[dblUnits]
						,[dtmHistoryDate]
						,[strType]
						,[strUserName]
						,[intEntityId]
						,[strSettleTicket]
						)
					VALUES (
						1
						,@intCustomerStorageId
						,NULL
						,@intContractHeaderId
						,@dblStorageUnits
						,GETDATE()
						,'Settlement'
						,@UserName
						,@ContractEntityId
						,@strOffsiteTicket
						)

					INSERT INTO @OffSiteInvoiceCreate (
						intCustomerStorageId
						,intContractHeaderId
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						)
					SELECT @intCustomerStorageId
						,@intContractHeaderId
						,@intContractDetailId
						,@dblStorageUnits
						,@dblCashPrice

					BREAK;
				END
				ELSE
				BEGIN
					UPDATE @SellContract
					SET dblContractUnits = dblContractUnits - @dblContractUnits
					WHERE intSellContractKey = @SellContractKey

					UPDATE @SellOffsite
					SET dblRemainingUnits = dblRemainingUnits - @dblContractUnits
					WHERE intSellOffsiteKey = @SellOffsiteKey

					UPDATE tblGRCustomerStorage
					SET dblOpenBalance = dblOpenBalance - @dblContractUnits
					WHERE intCustomerStorageId = @intCustomerStorageId

					INSERT INTO [dbo].[tblGRStorageHistory] (
						[intConcurrencyId]
						,[intCustomerStorageId]
						,[intInvoiceId]
						,[intContractHeaderId]
						,[dblUnits]
						,[dtmHistoryDate]
						,[strType]
						,[strUserName]
						,[intEntityId]
						,[strSettleTicket]
						)
					VALUES (
						1
						,@intCustomerStorageId
						,NULL
						,@intContractHeaderId
						,@dblContractUnits
						,GETDATE()
						,'Settlement'
						,@UserName
						,@ContractEntityId
						,@strOffsiteTicket
						)

					INSERT INTO @OffSiteInvoiceCreate (
						intCustomerStorageId
						,intContractHeaderId
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						)
					SELECT @intCustomerStorageId
						,@intContractHeaderId
						,@intContractDetailId
						,@dblContractUnits
						,@dblCashPrice

					BREAK;
				END

				SELECT @SellContractKey = MIN(intSellContractKey)
				FROM @SellContract
				WHERE intSellContractKey > @SellContractKey
					AND dblContractUnits > 0
			END

			SELECT @SellOffsiteKey = MIN(intSellOffsiteKey)
			FROM @SellOffsite
			WHERE intSellOffsiteKey >= @SellOffsiteKey
				AND dblRemainingUnits > 0
		END
		ELSE IF @dblSpotUnits > 0
		BEGIN
			IF @dblStorageUnits <= @dblSpotUnits
			BEGIN
				UPDATE @SellOffsite
				SET dblRemainingUnits = dblRemainingUnits - @dblStorageUnits
				WHERE intSellOffsiteKey = @SellOffsiteKey

				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @dblStorageUnits
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @dblSpotUnits = @dblSpotUnits - @dblStorageUnits

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[strType]
					,[strUserName]
					,[intEntityId]
					,[strSettleTicket]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,@dblStorageUnits
					,GETDATE()
					,'Settlement'
					,@UserName
					,NULL
					,@strOffsiteTicket
					)

				INSERT INTO @OffSiteInvoiceCreate (
					intCustomerStorageId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					)
				SELECT @intCustomerStorageId
					,NULL
					,NULL
					,@dblStorageUnits
					,@dblSpotCashPrice
			END
			ELSE
			BEGIN
				UPDATE @SellOffsite
				SET dblRemainingUnits = dblRemainingUnits - @dblSpotUnits
				WHERE intSellOffsiteKey = @SellOffsiteKey

				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @dblSpotUnits
				WHERE intCustomerStorageId = @intCustomerStorageId

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[strType]
					,[strUserName]
					,[intEntityId]
					,[strSettleTicket]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,@dblSpotUnits
					,GETDATE()
					,'Settlement'
					,@UserName
					,NULL
					,@strOffsiteTicket
					)

				INSERT INTO @OffSiteInvoiceCreate (
					intCustomerStorageId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					)
				SELECT @intCustomerStorageId
					,NULL
					,NULL
					,@dblSpotUnits
					,@dblSpotCashPrice

				SET @dblSpotUnits = 0
			END

			SELECT @SellOffsiteKey = MIN(intSellOffsiteKey)
			FROM @SellOffsite
			WHERE intSellOffsiteKey >= @SellOffsiteKey
				AND dblRemainingUnits > 0
		END
		ELSE
			BREAK;
	END

	SELECT @intDefaultCurrencyId = intDefaultCurrencyId
	FROM tblSMCompanyPreference

	SET @UserEntityId = ISNULL((
								SELECT [intEntityId]
								FROM tblSMUserSecurity
								WHERE [intEntityId] = @UserKey
								), @UserKey)

	SET @intCurrencyId = ISNULL((
									SELECT intCurrencyId
									FROM tblAPVendor
									WHERE [intEntityId] = @intSaleEntityId
									), @intDefaultCurrencyId)

	SELECT @intTermId = intTermsId
	FROM tblEMEntityLocation
	WHERE intEntityId = @intSaleEntityId

	BEGIN TRANSACTION

	DELETE
	FROM @EntriesForInvoice

	INSERT INTO @EntriesForInvoice (
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
	SELECT [strTransactionType] = 'Invoice'
		,[strType] = 'Standard'
		,[strSourceTransaction] = 'Sale OffSite'
		,[intSourceId] = NULL
		,[strSourceId] = ''
		,[intInvoiceId] = @InvoiceId
		,[intEntityCustomerId] = @intSaleEntityId
		,[intCompanyLocationId] = @intCompanyLocationId
		,[intCurrencyId] = @intCurrencyId
		,[intTermId] = @intTermId
		,[dtmDate] = GETDATE()
		,[dtmDueDate] = NULL
		,[dtmShipDate] = NULL
		,[intEntitySalespersonId] = NULL
		,[intFreightTermId] = NULL
		,[intShipViaId] = NULL
		,[intPaymentMethodId] = NULL
		,[strInvoiceOriginId] = NULL
		,[strPONumber] = NULL
		,[strBOLNumber] = NULL
		,[strComments] = NULL
		,[intShipToLocationId] = NULL
		,[intBillToLocationId] = NULL
		,[ysnTemplate] = 0
		,[ysnForgiven] = 0
		,[ysnCalculated] = 0
		,[ysnSplitted] = 0
		,[intPaymentId] = NULL
		,[intSplitId] = NULL
		,[strActualCostId] = NULL
		,[intEntityId] = @UserEntityId
		,[ysnResetDetails] = 0
		,[ysnPost] = NULL
		,[intInvoiceDetailId] = NULL
		,[intItemId] = @ItemId
		,[ysnInventory] = 1
		,[strItemDescription] = @ItemDescription
		,[intOrderUOMId] = @intSourceItemUOMId
		,[intItemUOMId] = @intSourceItemUOMId
		,[dblQtyOrdered] = dblUnits
		,[dblQtyShipped] = dblUnits
		,[dblDiscount] = 0
		,[dblPrice] = dblCashPrice
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
		,[intContractHeaderId] = intContractHeaderId
		,[intContractDetailId] = intContractDetailId
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
		,[intCustomerStorageId] = intCustomerStorageId
	FROM @OffSiteInvoiceCreate

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
		SELECT [intConcurrencyId] = 1
			,[intCustomerStorageId] = ARD.intCustomerStorageId
			,[intInvoiceId] = AR.intInvoiceId
			,[dblUnits] = ARD.dblQtyOrdered
			,[dtmHistoryDate] = GetDATE()
			,[dblPaidAmount] = ARD.dblPrice
			,[strType] = 'Generated Invoice'
			,[strUserName] = (
								SELECT strUserName
								FROM tblSMUserSecurity
								WHERE [intEntityId] = @UserKey
							 )
		FROM tblARInvoice AR
		JOIN tblARInvoiceDetail ARD ON ARD.intInvoiceId = AR.intInvoiceId
		WHERE AR.intInvoiceId = CONVERT(INT, @CreatedIvoices)

		UPDATE tblGRSellOffsite
		SET ysnPosted = 1
			,intInvoiceId = CONVERT(INT, @CreatedIvoices)
		WHERE intSellOffsiteId = @intSellOffsiteId
	END
	ELSE
	BEGIN
		RAISERROR (@ErrorMessage,16,1);
		ROLLBACK TRANSACTION
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
