CREATE PROCEDURE [dbo].[uspGRProcessGrainStorage]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
	DECLARE @StorageChargeDate DATETIME
	DECLARE @strPostType NVARCHAR(30)
	DECLARE @UserKey INT
	DECLARE @intCustomerStorageId INT
	DECLARE @strProcessType NVARCHAR(30)
	DECLARE @strUpdateType NVARCHAR(30)
	DECLARE @intBillDiscountKey INT
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	
	DECLARE @BillInvoiceKey INT
	DECLARE @ErrorMessage NVARCHAR(250)
		   ,@CreatedIvoices NVARCHAR(MAX)
		   ,@UpdatedIvoices NVARCHAR(MAX)
	DECLARE @EntityId INT
	DECLARE @LocationId INT
	DECLARE @ItemId INT
	DECLARE @TicketItemNo NVARCHAR(100)
	DECLARE @dblOpenBalance DECIMAL(24, 10)
	DECLARE @dblNewStorageDue DECIMAL(24, 10)
		
	DECLARE @InvoiceId INT
	DECLARE @UserEntityId INT
	DECLARE @intCurrencyId INT
	DECLARE @intDefaultCurrencyId INT
	DECLARE @intTermId INT
	DECLARE @StorageChargeItemDescription NVARCHAR(100)
	DECLARE @intCommodityStockUOMId INT
	DECLARE @intItemUOMId INT
	DECLARE @IntCommodityId INT
	DECLARE @intStorageChargeItemId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	DECLARE @BillDiscounts AS TABLE 
	(
		intBillDiscountKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,intEntityId INT
		,intCompanyLocationId INT
		,intStorageTypeId INT
		,intStorageScheduleId INT
		,dblOpenBalance DECIMAL(24, 10)
		,dblNewStorageDue DECIMAL(24, 10)
		,intItemId INT
		,IsInvoiced BIT
		,intOriginalUnitMeasureId INT
	)

	SELECT @UserKey = intCreatedUserId
		,@StorageChargeDate = StorageChargeDate
		,@strPostType = strPostType
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			intCreatedUserId INT
			,StorageChargeDate DATETIME
			,strPostType NVARCHAR(20)
	 )

	IF @strPostType = 'Calculate Test'
	BEGIN
		SET @strProcessType = 'calculate'
		SET @strUpdateType = 'estimate'
	END
	ELSE IF @strPostType = 'Accrue Storage'
	BEGIN
		SET @strProcessType = 'calculate'
		SET @strUpdateType = 'accrue'
	END
	ELSE IF @strPostType = 'Bill Storage'
	BEGIN
		SET @strProcessType = 'calculate'
		SET @strUpdateType = 'Bill'
	END
	ELSE IF @strPostType = 'Recalculate and Accrue'
	BEGIN
		SET @strProcessType = 'recalculate'
		SET @strUpdateType = 'accrue'
	END

	INSERT INTO @BillDiscounts 
	(
		intCustomerStorageId
		,intEntityId
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
		,dblOpenBalance
		,dblNewStorageDue
		,intItemId
		,IsInvoiced
	)
	SELECT intCustomerStorageId
		,intEntityId
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
		,dblOpenBalance
		,dblNewStorageDue
		,intItemId
		,0
	FROM OPENXML(@idoc, 'root/billstorage', 2) WITH 
	(
			intCustomerStorageId INT
			,intEntityId INT
			,intCompanyLocationId INT
			,intStorageTypeId INT
			,intStorageScheduleId INT
			,dblOpenBalance DECIMAL(24, 10)
			,dblNewStorageDue DECIMAL(24, 10)
			,intItemId INT
	)

	SELECT @intBillDiscountKey = MIN(intBillDiscountKey)
	FROM @BillDiscounts

	WHILE @intBillDiscountKey > 0
	BEGIN
		SET @intCustomerStorageId = NULL
		SET @dblStorageDuePerUnit = 0
		SET @dblStorageDueAmount = 0
		SET @dblStorageDueTotalPerUnit = 0
		SET @dblStorageDueTotalAmount = 0
		SET @dblStorageBilledPerUnit = 0
		SET @dblStorageBilledAmount = 0
		SET @EntityId = NULL
		SET @LocationId = NULL		
		SET @dblOpenBalance = NULL
		SET @dblNewStorageDue = NULL

		SELECT @intCustomerStorageId = intCustomerStorageId
			,@EntityId = intEntityId
			,@LocationId = intCompanyLocationId
			,@dblOpenBalance = dblOpenBalance
			,@dblNewStorageDue = dblNewStorageDue
		FROM @BillDiscounts
		WHERE intBillDiscountKey = @intBillDiscountKey
		
		EXEC uspGRCalculateStorageCharge 
			 @strProcessType
			,@strUpdateType
			,@intCustomerStorageId
			,NULL
			,NULL
			,NULL
			,@StorageChargeDate
			,@UserKey
			,0
			,NULL	
			,@dblStorageDuePerUnit OUTPUT
			,@dblStorageDueAmount OUTPUT
			,@dblStorageDueTotalPerUnit OUTPUT
			,@dblStorageDueTotalAmount OUTPUT
			,@dblStorageBilledPerUnit OUTPUT
			,@dblStorageBilledAmount OUTPUT

		SELECT @intBillDiscountKey = MIN(intBillDiscountKey)
		FROM @BillDiscounts
		WHERE intBillDiscountKey > @intBillDiscountKey
	END

	--Creating Invoice
	
	SELECT @intDefaultCurrencyId=intDefaultCurrencyId FROm tblSMCompanyPreference

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable
	
	IF @strPostType = 'Bill Storage'
	BEGIN
		SELECT @BillInvoiceKey = MIN(intBillDiscountKey)
		FROM @BillDiscounts WHERE IsInvoiced = 0

		WHILE @BillInvoiceKey > 0
		BEGIN
			SET @intCustomerStorageId = NULL			
			SET @EntityId = NULL
			SET @LocationId = NULL
			SET @ItemId = NULL
			SET @TicketItemNo = NULL
			SET @dblOpenBalance = NULL
			SET @dblNewStorageDue = NULL
			SET @IntCommodityId=NULL
			SET @intCommodityStockUOMId=NULL
			SET @intItemUOMId=NULL
			SET @intStorageChargeItemId=NULL

			SELECT 
				 @intCustomerStorageId = intCustomerStorageId
				,@EntityId = intEntityId
				,@LocationId = intCompanyLocationId				
				,@dblNewStorageDue = dblNewStorageDue
				,@ItemId=intItemId
			FROM @BillDiscounts
			WHERE intBillDiscountKey = @BillInvoiceKey
			
			SELECT @IntCommodityId=intCommodityId FROM tblGRCustomerStorage Where intCustomerStorageId=@intCustomerStorageId

			SELECT @TicketItemNo=strItemNo FROM tblICItem WHERE intItemId=@ItemId

			SELECT TOP 1 @intStorageChargeItemId=intItemId FROM tblICItem 
			WHERE strType='Other Charge' AND strCostType='Storage Charge' AND intCommodityId = @IntCommodityId
			
			IF @intStorageChargeItemId IS NULL
			BEGIN
				SELECT TOP 1 @intStorageChargeItemId=intItemId FROM tblICItem 
				WHERE strType='Other Charge' AND strCostType='Storage Charge' AND intCommodityId IS NULL
			END
			
			IF @intStorageChargeItemId IS NULL 
			BEGIN
				SET @ErrMsg = 'Invoice cannot be created because of Item '''+ @TicketItemNo +''' has no Storage Charge CostType item.'
				RAISERROR(@ErrMsg,16, 1);
			END	
			
			SELECT @StorageChargeItemDescription=strDescription FROM tblICItem Where intItemId=@intStorageChargeItemId
			
			SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserKey), @UserKey)
			
			SET @intCurrencyId = ISNULL((SELECT intCurrencyId FROM tblAPVendor WHERE [intEntityId] = @EntityId), @intDefaultCurrencyId)

			SELECT @intTermId = intTermsId FROM tblEMEntityLocation WHERE intEntityId = @EntityId

			SELECT @intCommodityStockUOMId = U.intUnitMeasureId
			FROM tblICCommodity C
			JOIN tblICItem Item ON Item.intCommodityId = C.intCommodityId
			JOIN tblICCommodityUnitMeasure U ON U.intCommodityId = C.intCommodityId
			WHERE U.ysnStockUnit = 1 AND Item.intItemId = @ItemId

			SELECT @intItemUOMId=intItemUOMId FROM tblICItemUOM WHERE intItemId=@ItemId AND intUnitMeasureId=@intCommodityStockUOMId

			
			UPDATE BD 
			SET BD.intOriginalUnitMeasureId=CS.intUnitMeasureId 
			FROM @BillDiscounts BD 
			JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=BD.intCustomerStorageId
			
			UPDATE @BillDiscounts
			SET dblOpenBalance=dbo.fnCTConvertQuantityToTargetItemUOM(intItemId,intOriginalUnitMeasureId,@intCommodityStockUOMId,dblOpenBalance)
			
			BEGIN TRANSACTION
				
				DELETE FROM @EntriesForInvoice
				
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
					,[strDeliverPickup]
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
					,[strDeliverPickup] = NULL --''
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
					,[intItemId] = @intStorageChargeItemId
					,[ysnInventory] = 1
					,[strItemDescription] = @StorageChargeItemDescription
					,[intOrderUOMId]= @intItemUOMId
					,[intItemUOMId] = @intItemUOMId
					,[dblQtyOrdered] = BD.dblOpenBalance
					,[dblQtyShipped] = BD.dblOpenBalance
					,[dblDiscount] = 0
					,[dblPrice] = BD.dblNewStorageDue
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
					,[intCustomerStorageId]=BD.intCustomerStorageId
					FROM @BillDiscounts BD 					
					WHERE BD.intEntityId = @EntityId AND BD.intCompanyLocationId=@LocationId AND BD.intItemId = @ItemId

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
							,[dblUnits] = ARD.dblQtyOrdered
							,[dtmHistoryDate]=GetDATE()
							,[dblPaidAmount]=ARD.dblPrice							
							,[strType]='Generated Invoice'
							,[strUserName]=(SELECT strUserName FROM tblSMUserSecurity WHERE [intEntityId] = @UserKey)
							 FROM tblARInvoice AR
							 JOIN tblARInvoiceDetail ARD ON ARD.intInvoiceId = AR.intInvoiceId
							 WHERE AR.intInvoiceId = CONVERT(INT,@CreatedIvoices)
										   
						
				END
				ELSE
				BEGIN
					ROLLBACK TRANSACTION
					RAISERROR(@ErrorMessage, 16, 1);					
				END			
			
				Update @BillDiscounts 
				SET IsInvoiced = 1 
				WHERE intEntityId = @EntityId AND intCompanyLocationId=@LocationId AND intItemId = @ItemId
			
			SELECT @BillInvoiceKey = MIN(intBillDiscountKey)
			FROM @BillDiscounts
			WHERE intBillDiscountKey > @BillInvoiceKey AND IsInvoiced = 0
			
		END
	END

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
