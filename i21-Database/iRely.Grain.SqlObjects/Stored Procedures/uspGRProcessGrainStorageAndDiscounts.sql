CREATE PROCEDURE [dbo].[uspGRProcessGrainStorageAndDiscounts]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE	@idoc INT
			,@ErrMsg NVARCHAR(MAX)
	DECLARE @UserKey INT
	DECLARE @intCustomerStorageId INT
	DECLARE @EntityId INT
	DECLARE @LocationId INT		
	DECLARE @ItemId INT
	DECLARE @dblOpenBalance DECIMAL(24, 10)
	DECLARE @ErrorMessage NVARCHAR(250)
			,@CreatedInvoices NVARCHAR(MAX)
			,@UpdatedInvoices NVARCHAR(MAX)
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable
	DECLARE @InvoiceId INT
	DECLARE @UserEntityId INT
	DECLARE @intCurrencyId INT
	DECLARE @intDefaultCurrencyId INT
	DECLARE @intTermId INT
	DECLARE @StorageChargeDate DATETIME
	DECLARE @BillInvoiceKey INT
	DECLARE @BillDiscountKey INT
	DECLARE @TicketItemNo NVARCHAR(100)
	DECLARE @dblNewStorageDue DECIMAL(24, 10)
	DECLARE @StorageChargeItemDescription NVARCHAR(100)
	DECLARE @intCommodityStockUOMId INT
	DECLARE @intItemUOMId INT
	DECLARE @IntCommodityId INT
	DECLARE @intStorageChargeItemId INT
	DECLARE @intTicketId INT
	DECLARE @dblTotalDiscountUnpaid DECIMAL(24, 10)
	DECLARE @dtmDate AS DATETIME = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	DECLARE @BillStorage AS TABLE 
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

	DECLARE @BillDiscounts AS TABLE 
	(
		 intBillDiscountKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,intEntityId INT
		,intItemId INT
		,intCompanyLocationId INT
		,intDiscountScheduleCodeId INT
		,intDiscountItemId INT
		,dblOpenBalance DECIMAL(24, 10)
		,dblDiscountDue DECIMAL(24, 10)
		,dblDiscountPaid DECIMAL(24, 10)
		,dblDiscountUnpaid DECIMAL(24, 10)
		,dblDiscountTotal DECIMAL(24, 10)
		,IsProcessed BIT
	 )	
	
	SELECT @UserKey = intCreatedUserId
		,@StorageChargeDate = StorageChargeDate
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			intCreatedUserId INT
			,StorageChargeDate DATETIME
	 )

	 --bill storage
	 INSERT INTO @BillStorage 
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

	--bill discount
	INSERT INTO @BillDiscounts 
	(
		intCustomerStorageId
		,intEntityId
		,intItemId
		,intCompanyLocationId
		,intDiscountScheduleCodeId
		,intDiscountItemId
		,dblOpenBalance
		,dblDiscountDue
		,dblDiscountPaid
		,dblDiscountUnpaid
		,dblDiscountTotal
		,IsProcessed
	 )
	SELECT 
		 intCustomerStorageId
		,intEntityId
		,intItemId
		,intCompanyLocationId
		,intDiscountScheduleCodeId
		,intDiscountItemId
		,dblOpenBalance
		,dblDiscountDue
		,dblDiscountPaid
		,dblDiscountUnpaid
		,dblDiscountTotal
		,0
	FROM OPENXML(@idoc, 'root/billdiscount', 2) WITH 
	(
		intCustomerStorageId INT
		,intEntityId INT
		,intItemId INT
		,intCompanyLocationId INT
		,intDiscountScheduleCodeId INT
		,intDiscountItemId INT
		,dblOpenBalance DECIMAL(24, 10)
		,dblDiscountDue DECIMAL(24, 10)
		,dblDiscountPaid DECIMAL(24, 10)
		,dblDiscountUnpaid DECIMAL(24, 10)
		,dblDiscountTotal DECIMAL(24, 10)
	 )

	SELECT @intDefaultCurrencyId=intDefaultCurrencyId FROM tblSMCompanyPreference

	SELECT @BillDiscountKey = MIN(intBillDiscountKey) FROM @BillDiscounts WHERE IsProcessed = 0

	SELECT @BillInvoiceKey = MIN(intBillDiscountKey) FROM @BillStorage WHERE IsInvoiced = 0

	WHILE @BillInvoiceKey > 0 OR @BillDiscountKey > 0
	BEGIN
		SET @intCustomerStorageId = NULL --*
		SET @EntityId = NULL--*
		SET @LocationId = NULL --*
		SET @ItemId = NULL
		SET @TicketItemNo = NULL
		SET @dblOpenBalance = NULL --*
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
		FROM @BillStorage
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
		FROM @BillStorage BD 
		JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=BD.intCustomerStorageId
			
		UPDATE @BillStorage
		SET dblOpenBalance=dbo.fnCTConvertQuantityToTargetItemUOM(intItemId,intOriginalUnitMeasureId,@intCommodityStockUOMId,dblOpenBalance)

		SELECT @dblTotalDiscountUnpaid = SUM(ISNULL(dblDiscountUnpaid, 0))
		FROM @BillDiscounts
		WHERE intEntityId = @EntityId AND intCompanyLocationId = @LocationId

		BEGIN TRANSACTION
				
			DELETE FROM @EntriesForInvoice
			
			IF @dblTotalDiscountUnpaid > 0
			BEGIN
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
				,[intTicketId] = CS.intTicketId
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
				FROM @BillStorage BD
				LEFT JOIN tblGRCustomerStorage CS ON BD.intCustomerStorageId = CS.intCustomerStorageId
				WHERE BD.intEntityId = @EntityId AND BD.intCompanyLocationId=@LocationId AND BD.intItemId = @ItemId

				UNION ALL

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
				,[intItemId] = BD.intDiscountItemId
				,[ysnInventory] = 1
				,[strItemDescription] = Item.strItemNo
				,[intOrderUOMId]= ItemUOM.intItemUOMId    
				,[intItemUOMId] = ItemUOM.intItemUOMId    
				,[dblQtyOrdered] = BD.dblOpenBalance
				,[dblQtyShipped] = BD.dblOpenBalance
				,[dblDiscount] = 0
				,[dblPrice] = BD.dblDiscountUnpaid
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
			FROM @BillDiscounts BD
			JOIN tblICItem Item ON Item.intItemId = BD.intDiscountItemId
			JOIN tblGRCustomerStorage CS ON CS.intItemId = BD.intItemId AND  CS.intCustomerStorageId = BD.intCustomerStorageId
			JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
			JOIN tblICItemUOM ItemUOM ON ItemUOM.intUnitMeasureId=CU.intUnitMeasureId AND ItemUOM.intItemId = BD.intItemId
			WHERE BD.intEntityId = @EntityId AND BD.intCompanyLocationId = @LocationId AND BD.IsProcessed = 0
			END
			ELSE
			BEGIN
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
				,[intTicketId] = CS.intTicketId
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
				FROM @BillStorage BD
				LEFT JOIN tblGRCustomerStorage CS ON BD.intCustomerStorageId = CS.intCustomerStorageId
				WHERE BD.intEntityId = @EntityId AND BD.intCompanyLocationId=@LocationId AND BD.intItemId = @ItemId
			END

			EXEC [dbo].[uspARProcessInvoices] 
				@InvoiceEntries = @EntriesForInvoice
				,@LineItemTaxEntries = @TaxDetails
				,@UserId = @UserKey
				,@GroupingOption = 11
				,@RaiseError = 1
				,@ErrorMessage = @ErrorMessage OUTPUT
				,@CreatedIvoices = @CreatedInvoices OUTPUT
				,@UpdatedIvoices = @UpdatedInvoices OUTPUT

			IF (@ErrorMessage IS NULL)
			BEGIN					
				COMMIT TRANSACTION
					
					--bill storage
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
						,[strType]='Generated Storage and Discount Invoice'
						,[strUserName]=(SELECT strUserName FROM tblSMUserSecurity WHERE [intEntityId] = @UserKey)
					FROM tblARInvoice AR
					JOIN tblARInvoiceDetail ARD ON ARD.intInvoiceId = AR.intInvoiceId
					WHERE AR.intInvoiceId = CONVERT(INT,@CreatedInvoices)

					--for bill discount
					;WITH SRC
					AS (
						SELECT intCustomerStorageId
							,SUM(dblDiscountUnpaid) AS Discountpaid
						FROM @BillDiscounts
						WHERE IsProcessed = 0
						GROUP BY intCustomerStorageId
						)
					
					UPDATE CS
					SET CS.dblDiscountsPaid = CS.dblDiscountsPaid + Q.Discountpaid
					FROM tblGRCustomerStorage CS
					JOIN SRC Q ON Q.intCustomerStorageId = CS.intCustomerStorageId
					JOIN @BillDiscounts BD ON BD.intCustomerStorageId = CS.intCustomerStorageId
					WHERE BD.intEntityId = @EntityId AND BD.intCompanyLocationId = @LocationId AND BD.IsProcessed = 0

					UPDATE QM
					SET QM.dblDiscountPaid = QM.dblDiscountDue
					FROM tblGRCustomerStorage CS
					JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId
					JOIN @BillDiscounts BD ON BD.intCustomerStorageId = CS.intCustomerStorageId
					JOIN tblGRDiscountScheduleCode GSC ON GSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId AND GSC.intItemId = BD.intDiscountItemId
					WHERE BD.IsProcessed = 0 AND QM.strSourceType = 'Storage' AND BD.intEntityId = @EntityId AND BD.intCompanyLocationId = @LocationId	
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				RAISERROR(@ErrorMessage, 16, 1);					
			END
		--Update @BillStorage 
		--SET IsInvoiced = 1 
		--WHERE intEntityId = @EntityId AND intCompanyLocationId=@LocationId AND intItemId = @ItemId
			
		--SELECT @BillInvoiceKey = MIN(intBillDiscountKey)
		--FROM @BillStorage
		--WHERE intBillDiscountKey > @BillInvoiceKey AND IsInvoiced = 0			


		UPDATE @BillDiscounts
		SET IsProcessed = 1
		WHERE intEntityId = @EntityId AND intCompanyLocationId = @LocationId

		SELECT @BillDiscountKey = MIN(intBillDiscountKey)
		FROM @BillDiscounts
		WHERE intBillDiscountKey > @BillDiscountKey AND IsProcessed = 0

		UPDATE @BillStorage
		SET IsInvoiced = 1 
		WHERE intEntityId = @EntityId AND intCompanyLocationId=@LocationId AND intItemId = @ItemId
			
		SELECT @BillInvoiceKey = MIN(intBillDiscountKey)
		FROM @BillStorage
		WHERE intBillDiscountKey > @BillInvoiceKey AND IsInvoiced = 0


	END

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH