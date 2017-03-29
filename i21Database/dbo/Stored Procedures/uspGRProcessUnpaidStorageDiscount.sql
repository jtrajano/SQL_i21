CREATE PROCEDURE [dbo].[uspGRProcessUnpaidStorageDiscount]
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
	DECLARE @intBillDiscountKey INT
	DECLARE @EntityId INT
	DECLARE @LocationId INT
	DECLARE @ItemId INT
	DECLARE @dblOpenBalance DECIMAL(24, 10)
	DECLARE @dblTotalDiscountUnpaid DECIMAL(24, 10)
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
	
	DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory
	DECLARE @intCreatedBillId INT
	

	SET @dtmDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

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
	FROM OPENXML(@idoc, 'root', 2) WITH (intCreatedUserId INT)
	
	SELECT @intDefaultCurrencyId=intDefaultCurrencyId FROm tblSMCompanyPreference
	
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

	SELECT @intBillDiscountKey = MIN(intBillDiscountKey)
	FROM @BillDiscounts
	WHERE IsProcessed = 0

	WHILE @intBillDiscountKey > 0
	BEGIN
		SET @intCustomerStorageId = NULL
		SET @EntityId = NULL
		SET @LocationId = NULL
		SET @dblOpenBalance = NULL

		SELECT @intCustomerStorageId = intCustomerStorageId
			,@EntityId = intEntityId
			,@LocationId = intCompanyLocationId
			,@dblOpenBalance = dblOpenBalance
		FROM @BillDiscounts
		WHERE intBillDiscountKey = @intBillDiscountKey

		SELECT @dblTotalDiscountUnpaid = SUM(ISNULL(dblDiscountUnpaid, 0))
		FROM @BillDiscounts
		WHERE intEntityId = @EntityId AND intCompanyLocationId = @LocationId

		IF @dblTotalDiscountUnpaid > 0
		BEGIN
			SET @UserEntityId = ISNULL((SELECT [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserKey), @UserKey)						
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
					,[dtmHistoryDate] = GetDATE()
					,[dblPaidAmount] = ARD.dblPrice
					,[strType] = 'Generated Invoice'
					,[strUserName] = (SELECT strUserName FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserKey)
				FROM tblARInvoice AR
				JOIN tblARInvoiceDetail ARD ON ARD.intInvoiceId = AR.intInvoiceId
				WHERE AR.intInvoiceId = CONVERT(INT, @CreatedIvoices)

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
				RAISERROR (@ErrorMessage,16,1);
			END;
		END
		
		ELSE      
		BEGIN
			 BEGIN TRANSACTION
			 					
				DELETE FROM @voucherDetailNonInventory
				SET @intCreatedBillId=0
									     
				  INSERT INTO @voucherDetailNonInventory   
				   (  
					 [intAccountId]  
					,[intItemId]  
					,[strMiscDescription]  
					,[dblQtyReceived]  
					,[dblDiscount]  
					,[dblCost]  
					,[intTaxGroupId]  
					)  
				   SELECT   
					 NULL  
					,a.intDiscountItemId  
					,b.strItemNo  
					,a.dblOpenBalance  
					,CASE WHEN a.dblDiscountUnpaid <0 THEN -a.dblDiscountUnpaid ELSE a.dblDiscountUnpaid END  
					,CASE WHEN a.dblDiscountUnpaid <0 THEN -a.dblDiscountUnpaid ELSE a.dblDiscountUnpaid END
					,NULL  
				   FROM @BillDiscounts a  
				   JOIN tblICItem b ON b.intItemId = a.intDiscountItemId  
				   WHERE a.intEntityId = @EntityId AND a.intCompanyLocationId = @LocationId AND a.IsProcessed = 0
				   
				   EXEC [dbo].[uspAPCreateBillData]   
				   @userId = @UserKey  
				  ,@vendorId = @EntityId  
				  ,@type = 1  
				  ,@voucherNonInvDetails = @voucherDetailNonInventory  
				  ,@shipTo = @LocationId  
				  ,@vendorOrderNumber = NULL
				  ,@voucherDate = @dtmDate  
				  ,@billId = @intCreatedBillId OUTPUT
				  
				  IF @intCreatedBillId >0
				  BEGIN
					 COMMIT TRANSACTION
					
					    UPDATE APD
						SET
						APD.intCustomerStorageId=BD.intCustomerStorageId,
						APD.intUnitOfMeasureId=ItemUOM.intItemUOMId
						FROM tblAPBillDetail APD
						JOIN tblAPBill AP ON AP.intBillId=APD.intBillId
						JOIN @BillDiscounts BD ON BD.intDiscountItemId=APD.intItemId
						JOIN tblGRCustomerStorage CS ON CS.intItemId = BD.intItemId
						JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
						JOIN tblICItemUOM ItemUOM ON ItemUOM.intUnitMeasureId=CU.intUnitMeasureId
						WHERE AP.[intBillId]=@intCreatedBillId AND BD.intEntityId = @EntityId AND BD.intCompanyLocationId = @LocationId AND BD.IsProcessed = 0

					INSERT INTO [dbo].[tblGRStorageHistory] 
					(
						 [intConcurrencyId]
						,[intCustomerStorageId]
						,[intBillId]					
						,[dblUnits]
						,[dtmHistoryDate]
						,[dblPaidAmount]
						,[strType]
						,[strUserName]
					)
					SELECT 
						 [intConcurrencyId] = 1
						,[intCustomerStorageId] =intCustomerStorageId
						,[intBillId]=@intCreatedBillId						
						,[dblUnits] = dblOpenBalance
						,[dtmHistoryDate] = GetDATE()
						,[dblPaidAmount] =CASE WHEN dblDiscountUnpaid <0 THEN -dblDiscountUnpaid ELSE dblDiscountUnpaid END
						,[strType] = 'Generated Bill'
						,[strUserName] = (SELECT strUserName FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserKey)
					FROM @BillDiscounts WHERE intEntityId = @EntityId AND intCompanyLocationId = @LocationId AND IsProcessed = 0
					
					
					 
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
					RAISERROR (@ErrorMessage,16,1);
				  END;  	
				   
		END      
		
		UPDATE @BillDiscounts
		SET IsProcessed = 1
		WHERE intEntityId = @EntityId AND intCompanyLocationId = @LocationId

		SELECT @intBillDiscountKey = MIN(intBillDiscountKey)
		FROM @BillDiscounts
		WHERE intBillDiscountKey > @intBillDiscountKey AND IsProcessed = 0
	END

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
