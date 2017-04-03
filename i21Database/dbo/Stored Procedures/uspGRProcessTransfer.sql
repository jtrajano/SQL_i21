CREATE PROCEDURE [dbo].[uspGRProcessTransfer]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
    SET NOCOUNT ON
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		
	DECLARE @intCustomerStorageId INT
	DECLARE @NewCustomerStorageId INT
	DECLARE @ItemEntityid INT
	DECLARE @ItemCompanyLocationId INT
	DECLARE @ItemStorageType INT
	DECLARE @ItemStorageSchedule INT	
	DECLARE @ItemBalance DECIMAL(24,10)
	DECLARE @ItemContractBalance DECIMAL(24,10)
	DECLARE @TicketNo Nvarchar(20)
	DECLARE @TransferTicketNumber Nvarchar(20)
	DECLARE @ActionCustomer INT
		,@Percent DECIMAL(24,10)
		,@ActionOpenBalance DECIMAL(24,10)
		,@ActionStorageTypeId INT
		,@ActionStorageScheduleId INT
		,@ActionCompanyLocationId INT
		
	DECLARE @UserKey INT
	DECLARE @UserName NVARCHAR(100)	
	DECLARE @InventoryStockUOM Nvarchar(50)
	DECLARE @ItemsToMoveKey INT
	DECLARE @ActionKey INT
	DECLARE @ItemLocationName NVARCHAR(100)
	DECLARE @ItemCustomerName NVARCHAR(200)
	DECLARE @ItemStorageTypeDescription NVARCHAR(50)
	DECLARE @ItemStorageScheduleId NVARCHAR(50)
	DECLARE @ItemContractHeaderId INT
	DECLARE @ItemContractDetailId INT
	DECLARE @ActionLocationName NVARCHAR(100)
	DECLARE @ActionStorageTypeDescription NVARCHAR(50)
	DECLARE @ActionCustomerName NVARCHAR(200)
	DECLARE @UnitsToReduce DECIMAL(18,6)
	DECLARE @CurrentItemOpenBalance DECIMAL(24,10)	
	DECLARE @intItemId INT
	DECLARE @intItemLocationId INT
	DECLARE @intActionLocationId INT
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)	
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	DECLARE @ActionContractHeaderId INT
	DECLARE @ActionontractDetailId INT

	DECLARE @intUnitMeasureId INT
	DECLARE @intSourceItemUOMId INT
	DECLARE @ItemId INT
	
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable
	DECLARE @ErrorMessage NVARCHAR(250)
	DECLARE @CreatedIvoices NVARCHAR(MAX)
	DECLARE @UpdatedIvoices NVARCHAR(MAX)
		   
	DECLARE @intItemUOMId INT
	DECLARE @IntCommodityId INT
	
	DECLARE @intStorageChargeItemId INT
	DECLARE @InvoiceId INT
	DECLARE @UserEntityId INT
	DECLARE @intCurrencyId INT
	DECLARE @intDefaultCurrencyId INT
	DECLARE @intTermId INT
	DECLARE @ItemDescription NVARCHAR(100)

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	DECLARE @ItemsToMove AS TABLE 
	(
		 intItemsToMoveKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,intEntityId INT
		,intCompanyLocationId INT
		,intStorageTypeId INT
		,intStorageScheduleId INT
		,dblOpenBalance DECIMAL(24,10)
		,intContractHeaderId INT		
		,intOriginalUnitMeasureId INT
	)
		
	DECLARE @Action AS TABLE 
	(
		intActionKey INT IDENTITY(1, 1)
		,intEntityId INT
		,dblPercent DECIMAL(24,10)
		,dblOpenBalance DECIMAL(24,10)
		,intStorageTypeId INT
		,intStorageScheduleId INT
		,intCompanyLocationId INT
		,intContractHeaderId INT
	)

	SELECT @UserKey = intCreatedUserId		
		,@ItemEntityid = intItemCustomerId
		,@ItemCompanyLocationId = intItemLocation
		,@ActionCompanyLocationId = intActionLocation	
		,@TransferTicketNumber=strTransferTicketNumber		
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			 intCreatedUserId INT			
			,intItemCustomerId INT
			,intItemLocation INT
			,intActionLocation INT
			,strTransferTicketNumber NVARCHAR(20)
			,intBillBeforeTransfer INT
	)
	
	SELECT @ItemCustomerName = strName	FROM tblEMEntity	WHERE intEntityId = @ItemEntityid

	SELECT @ItemLocationName = strLocationName	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @ItemCompanyLocationId

	SELECT @ActionLocationName = strLocationName FROM tblSMCompanyLocation	WHERE intCompanyLocationId = @ActionCompanyLocationId

	SELECT @UserName = strUserName	FROM tblSMUserSecurity	WHERE [intEntityId] = @UserKey

	INSERT INTO @ItemsToMove 
	(
		intCustomerStorageId
		,intEntityId
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
		,dblOpenBalance
		,intContractHeaderId
	)
	SELECT intCustomerStorageId
		,intEntityId
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
		,dblOpenBalance
		,intContractHeaderId
	FROM OPENXML(@idoc, 'root/ItemsToTransfer', 2) WITH 
	(
			 intCustomerStorageId INT
			,intEntityId INT
			,intCompanyLocationId INT
			,intStorageTypeId INT
			,intStorageScheduleId INT
			,dblOpenBalance DECIMAL(24,10)
			,intContractHeaderId INT
	)
	
	INSERT INTO @Action 
	(
		intEntityId
		,dblPercent
		,dblOpenBalance
		,intStorageTypeId
		,intStorageScheduleId
		,intCompanyLocationId
		,intContractHeaderId
	)
	SELECT intEntityId
		,dblPercent
		,dblOpenBalance
		,intStorageTypeId
		,intStorageScheduleId
		,intCompanyLocationId
		,intContractHeaderId
	FROM OPENXML(@idoc, 'root/ActionTransfer', 2) WITH 
	(
			 intEntityId INT
			,dblPercent DECIMAL(24,10)
			,dblOpenBalance DECIMAL(24,10)
			,intStorageTypeId INT
			,intStorageScheduleId INT
			,intCompanyLocationId INT
			,intContractHeaderId INT
	)
	
	UPDATE a 
	SET a.dblOpenBalance=b.dblOpenBalance
	FROM @ItemsToMove a
	JOIN tblGRCustomerStorage b ON b.intCustomerStorageId=a.intCustomerStorageId
	
    SELECT @ItemId=intItemId from tblGRCustomerStorage WHERE intCustomerStorageId=(SELECT Top 1 intCustomerStorageId FROM @ItemsToMove)
	
	SELECT @intUnitMeasureId=a.intUnitMeasureId 
	FROM tblICCommodityUnitMeasure a 
	JOIN tblICItem b ON b.intCommodityId=a.intCommodityId
	WHERE b.intItemId=@ItemId AND a.ysnStockUnit=1
		
    IF @intUnitMeasureId IS NULL 
	BEGIN
		RAISERROR('The stock UOM of the commodity must be set for item', 16, 1);
		RETURN;
	END	
	
	IF NOT EXISTS(SELECT 1 FROM tblICItemUOM WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId)
	BEGIN
		RAISERROR('The stock UOM of the commodity must exist in the conversion table of the item', 16, 1);
	END
	 			
	SELECT @intSourceItemUOMId=intItemUOMId FROM tblICItemUOM UOM  WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId

	SELECT @ItemsToMoveKey = MIN(intItemsToMoveKey)
	FROM @ItemsToMove

	SET @intCustomerStorageId = NULL
	SET @ItemStorageType = NULL
	SET @ItemStorageSchedule=NULL
	SET @ItemBalance = NULL
	SET @ItemStorageTypeDescription = NULL
	SET @ItemStorageScheduleId=NULL	
	SET @CurrentItemOpenBalance=NULL
	SET @TicketNo=NULL
	SET @intItemId=NULL
	SET @intItemLocationId=NULL
	SET @intActionLocationId=NULL	
	SET @ItemContractHeaderId=NULL
	SET @ItemContractDetailId=NULL
	SET @ItemContractBalance=NULL  

	
	WHILE @ItemsToMoveKey > 0
	BEGIN
		SELECT @intCustomerStorageId = intCustomerStorageId
			,@ItemStorageType = intStorageTypeId
			,@ItemStorageSchedule=intStorageScheduleId
			,@ItemBalance = dblOpenBalance
			,@ItemContractHeaderId=intContractHeaderId
		FROM @ItemsToMove
		WHERE intItemsToMoveKey = @ItemsToMoveKey
		
		SELECT @CurrentItemOpenBalance=dblOpenBalance,@TicketNo=strStorageTicketNumber,@intItemId=intItemId FROM tblGRCustomerStorage Where intCustomerStorageId=@intCustomerStorageId

		SELECT @ItemStorageTypeDescription = strStorageTypeDescription
		FROM tblGRStorageType
		WHERE intStorageScheduleTypeId = @ItemStorageType
		
		SELECT @ItemStorageScheduleId=strScheduleId FROM tblGRStorageScheduleRule Where intStorageScheduleRuleId=@ItemStorageSchedule

		SELECT @ActionKey = MIN(intActionKey) FROM @Action
		 
		SET @ActionCustomer = NULL
		SET @Percent = NULL
		SET @ActionOpenBalance = NULL
		SET @ActionStorageTypeId = NULL
		SET @ActionStorageScheduleId = NULL
		SET @ActionStorageTypeDescription = NULL
		SET @ActionCustomerName = NULL
		SET @NewCustomerStorageId=NULL
		SET @ActionContractHeaderId=NULL
		SET @ActionontractDetailId=NULL

		IF @CurrentItemOpenBalance <> @ItemBalance
		BEGIN		 
		 SELECT @TicketNo=strStorageTicketNumber FROM tblGRCustomerStorage Where intCustomerStorageId=@intCustomerStorageId
		 SET @ErrMsg='The Open balance of ticket '+@TicketNo+' has been modified by another user.  Transfer Process cannot proceed.'
		 RAISERROR(@ErrMsg,16,1)		 
		END
		
		IF ISNULL(@ItemContractHeaderId,0)>0
		BEGIN
		SELECT @ItemContractDetailId=intContractDetailId FROM vyuCTContractDetailView WHERE intContractHeaderId=@ItemContractHeaderId
		SET @ItemContractBalance = -@ItemBalance

			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				  @intContractDetailId=@ItemContractDetailId
				 ,@dblQuantityToUpdate=@ItemContractBalance
				 ,@intUserId=@UserKey
				 ,@intExternalId=@intCustomerStorageId
				 ,@strScreenName='Transfer Storage'
				 ,@intSourceItemUOMId=@intSourceItemUOMId

		END

		WHILE @ActionKey > 0
		BEGIN
			 SELECT @ActionCustomer = intEntityId
				,@Percent = dblPercent
				,@ActionOpenBalance = dblOpenBalance
				,@ActionStorageTypeId = intStorageTypeId
				,@ActionStorageScheduleId = intStorageScheduleId
				,@ActionContractHeaderId=intContractHeaderId
			FROM @Action
			WHERE intActionKey = @ActionKey
			
			SELECT @ActionStorageTypeDescription = strStorageTypeDescription
			FROM tblGRStorageType
			WHERE intStorageScheduleTypeId = @ActionStorageTypeId

			SELECT @ActionCustomerName = strName
			FROM tblEMEntity
			WHERE intEntityId = @ActionCustomer
			
			---CASE #1:Customer Match,Location Match, Storatype Mismatch
			IF @ItemEntityid = @ActionCustomer AND @ItemCompanyLocationId = @ActionCompanyLocationId AND @ItemStorageType <> @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				
				---Old Ticket
				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @UnitsToReduce
				WHERE intCustomerStorageId = @intCustomerStorageId

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]					
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ItemContractHeaderId,0)>0 THEN @ItemContractHeaderId ELSE NULL END
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'Transfer'
					,@UserName
					,3
					,@ActionCustomer
					,@ActionCompanyLocationId
					,@TransferTicketNumber
					)

				--New Ticket		
				
				INSERT INTO [dbo].[tblGRCustomerStorage] (
					 [intConcurrencyId]
					,[intEntityId]
					,[intCommodityId]
					,[intStorageScheduleId]
					,[intStorageTypeId]
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,[dblOriginalBalance]
					,[dblOpenBalance]
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]					
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
					)
				SELECT 1
					,[intEntityId]
					,[intCommodityId]
					,CASE WHEN @ActionStorageScheduleId=0 THEN  intStorageScheduleId ELSE @ActionStorageScheduleId END
					,@ActionStorageTypeId
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,@UnitsToReduce
					,@UnitsToReduce
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]							
					,[dblStorageDue]
					,[dblStoragePaid]		
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,intItemId
					,[intUnitMeasureId]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]	
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,@intCustomerStorageId
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ActionContractHeaderId,0)>0 THEN @ActionContractHeaderId ELSE NULL END
					,@UnitsToReduce
					,GETDATE()
					,NULL 
					,NULL
					,NULL
					,'From Transfer'
					,@UserName
					,3
					,@ItemEntityid
					,@ItemCompanyLocationId
					,@TransferTicketNumber
					)
			END
			
			---CASE #2:Customer Match,Location MisMatch,Storatype Match
			
			IF @ItemEntityid = @ActionCustomer AND @ItemCompanyLocationId <> @ActionCompanyLocationId AND @ItemStorageType = @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				
				---Old Ticket
				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @UnitsToReduce
				WHERE intCustomerStorageId = @intCustomerStorageId

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]		
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ItemContractHeaderId,0)>0 THEN @ItemContractHeaderId ELSE NULL END
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'Transfer'
					,@UserName
					,3
					,@ActionCustomer
					,@ActionCompanyLocationId
					,@TransferTicketNumber
					)			

				--New Ticket
				INSERT INTO [dbo].[tblGRCustomerStorage] (
					[intConcurrencyId]
					,[intEntityId]
					,[intCommodityId]
					,[intStorageScheduleId]
					,[intStorageTypeId]
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,[dblOriginalBalance]
					,[dblOpenBalance]
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]							
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
					)
				SELECT 1
					,[intEntityId]
					,[intCommodityId]
					,CASE WHEN @ActionStorageScheduleId=0 THEN  intStorageScheduleId ELSE @ActionStorageScheduleId END
					,[intStorageTypeId]
					,@ActionCompanyLocationId
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,@UnitsToReduce
					,@UnitsToReduce
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]							
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]	
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,@intCustomerStorageId
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ActionContractHeaderId,0)>0 THEN @ActionContractHeaderId ELSE NULL END
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'From Transfer'
					,@UserName
					,3
					,@ItemEntityid
					,@ItemCompanyLocationId
					,@TransferTicketNumber
					)
			END
			
			---CASE #3:Customer Match,Location MisMatch,Storatype MisMatch
			IF @ItemEntityid = @ActionCustomer AND @ItemCompanyLocationId <> @ActionCompanyLocationId AND @ItemStorageType <> @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)			
				
				---Old Ticket
				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @UnitsToReduce
				WHERE intCustomerStorageId = @intCustomerStorageId

				INSERT INTO [dbo].[tblGRStorageHistory] (
					 [intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]	
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ItemContractHeaderId,0)>0 THEN @ItemContractHeaderId ELSE NULL END
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'Transfer'
					,@UserName
					,3
					,@ActionCustomer
					,@ActionCompanyLocationId
					,@TransferTicketNumber
					)

				--New Ticket
				INSERT INTO [dbo].[tblGRCustomerStorage] (
					 [intConcurrencyId]
					,[intEntityId]
					,[intCommodityId]
					,[intStorageScheduleId]
					,[intStorageTypeId]
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,[dblOriginalBalance]
					,[dblOpenBalance]
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]							
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
					)
				SELECT 1
					,[intEntityId]
					,[intCommodityId]
					,CASE WHEN @ActionStorageScheduleId=0 THEN  intStorageScheduleId ELSE @ActionStorageScheduleId END
					,@ActionStorageTypeId
					,@ActionCompanyLocationId
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,@UnitsToReduce
					,@UnitsToReduce
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]			
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]		
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,@intCustomerStorageId
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ActionContractHeaderId,0)>0 THEN @ActionContractHeaderId ELSE NULL END
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'From Transfer'
					,@UserName
					,3
					,@ItemEntityid
					,@ItemCompanyLocationId
					,@TransferTicketNumber
					)
			END
			
			---CASE #4:Customer MisMatch,Location Match,Storatype Match			
			IF @ItemEntityid <> @ActionCustomer AND @ItemCompanyLocationId = @ActionCompanyLocationId AND @ItemStorageType = @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)			
				
				---Old Ticket
				
				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @UnitsToReduce
				WHERE intCustomerStorageId = @intCustomerStorageId

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]	
					,[strTransferTicket]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ItemContractHeaderId,0)>0 THEN @ItemContractHeaderId ELSE NULL END
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'Transfer'
					,@UserName
					,3
					,@ActionCustomer
					,@ActionCompanyLocationId
					,@TransferTicketNumber
					)

				--New Ticket
				INSERT INTO [dbo].[tblGRCustomerStorage] (
					[intConcurrencyId]
					,[intEntityId]
					,[intCommodityId]
					,[intStorageScheduleId]
					,[intStorageTypeId]
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,[dblOriginalBalance]
					,[dblOpenBalance]
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]							
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
					)
				SELECT 1
					,@ActionCustomer
					,[intCommodityId]
					,CASE WHEN @ActionStorageScheduleId=0 THEN  intStorageScheduleId ELSE @ActionStorageScheduleId END
					,intStorageTypeId
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,@UnitsToReduce
					,@UnitsToReduce
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]		
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]	
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,@intCustomerStorageId
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ActionContractHeaderId,0)>0 THEN @ActionContractHeaderId ELSE NULL END
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'From Transfer'
					,@UserName
					,3
					,@ItemEntityid
					,@ItemCompanyLocationId
					,@TransferTicketNumber
					)
			END
			
			---CASE #5:Customer MisMatch,Location Match,Storatype MisMatch
					
			IF @ItemEntityid <> @ActionCustomer AND @ItemCompanyLocationId = @ActionCompanyLocationId AND @ItemStorageType <> @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				
				---Old Ticket
				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @UnitsToReduce
				WHERE intCustomerStorageId = @intCustomerStorageId

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]	
					,[strTransferTicket]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ItemContractHeaderId,0)>0 THEN @ItemContractHeaderId ELSE NULL END
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'Transfer'
					,@UserName
					,3
					,@ActionCustomer
					,@ActionCompanyLocationId
					,@TransferTicketNumber
					)

				--New Ticket
				INSERT INTO [dbo].[tblGRCustomerStorage] (
					[intConcurrencyId]
					,[intEntityId]
					,[intCommodityId]
					,[intStorageScheduleId]
					,[intStorageTypeId]
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,[dblOriginalBalance]
					,[dblOpenBalance]
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]							
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
					)
				SELECT 1
					,@ActionCustomer
					,[intCommodityId]
					,CASE WHEN @ActionStorageScheduleId=0 THEN  intStorageScheduleId ELSE @ActionStorageScheduleId END
					,@ActionStorageTypeId
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,@UnitsToReduce
					,@UnitsToReduce
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]		
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]	
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,@intCustomerStorageId
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ActionContractHeaderId,0)>0 THEN @ActionContractHeaderId ELSE NULL END
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'From Transfer'
					,@UserName
					,3
					,@ItemEntityid
					,@ItemCompanyLocationId
					,@TransferTicketNumber
					)
			END
			
			--CASE #6:Customer MisMatch,Location MisMatch,Storatype Match
			IF @ItemEntityid <> @ActionCustomer AND @ItemCompanyLocationId <> @ActionCompanyLocationId AND @ItemStorageType = @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)		
				
				---Old Ticket
				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @UnitsToReduce
				WHERE intCustomerStorageId = @intCustomerStorageId

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ItemContractHeaderId,0)>0 THEN @ItemContractHeaderId ELSE NULL END
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'Transfer'
					,@UserName
					,3
					,@ActionCustomer
					,@ActionCompanyLocationId
					,@TransferTicketNumber
					)

				--New Ticket
				INSERT INTO [dbo].[tblGRCustomerStorage] (
					[intConcurrencyId]
					,[intEntityId]
					,[intCommodityId]
					,[intStorageScheduleId]
					,[intStorageTypeId]
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,[dblOriginalBalance]
					,[dblOpenBalance]
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]							
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
					)
				SELECT 1
					,@ActionCustomer
					,[intCommodityId]
					,CASE WHEN @ActionStorageScheduleId=0 THEN  intStorageScheduleId ELSE @ActionStorageScheduleId END
					,intStorageTypeId
					,@ActionCompanyLocationId
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,@UnitsToReduce
					,@UnitsToReduce
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]		
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]		
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,@intCustomerStorageId
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ActionContractHeaderId,0)>0 THEN @ActionContractHeaderId ELSE NULL END
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'From Transfer'
					,@UserName
					,3
					,@ItemEntityid
					,@ItemCompanyLocationId
					,@TransferTicketNumber
					)

			
			END
			
			--CASE #7:Customer MisMatch,Location MisMatch,Storatype MisMatch
			IF @ItemEntityid <> @ActionCustomer AND @ItemCompanyLocationId <> @ActionCompanyLocationId AND @ItemStorageType <> @ActionStorageTypeId
			BEGIN
			
				

				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)				
				---Old Ticket
				UPDATE tblGRCustomerStorage
				SET dblOpenBalance = dblOpenBalance - @UnitsToReduce
				WHERE intCustomerStorageId = @intCustomerStorageId

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]	
					,[strTransferTicket]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ItemContractHeaderId,0)>0 THEN @ItemContractHeaderId ELSE NULL END
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'Transfer'
					,@UserName
					,3
					,@ActionCustomer
					,@ActionCompanyLocationId
					,@TransferTicketNumber
					)

				--New Ticket
				INSERT INTO [dbo].[tblGRCustomerStorage] (
					[intConcurrencyId]
					,[intEntityId]
					,[intCommodityId]
					,[intStorageScheduleId]
					,[intStorageTypeId]
					,[intCompanyLocationId]
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,[dblOriginalBalance]
					,[dblOpenBalance]
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]							
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
					)
				SELECT 1
					,@ActionCustomer
					,[intCommodityId]
					,CASE WHEN @ActionStorageScheduleId=0 THEN  intStorageScheduleId ELSE @ActionStorageScheduleId END
					,intStorageTypeId
					,@ActionCompanyLocationId
					,[intTicketId]
					,[intDiscountScheduleId]
					,[dblTotalPriceShrink]
					,[dblTotalWeightShrink]
					,@UnitsToReduce
					,@UnitsToReduce
					,[dtmDeliveryDate]
					,[dtmZeroBalanceDate]
					,[strDPARecieptNumber]
					,[dtmLastStorageAccrueDate]		
					,[dblStorageDue]
					,[dblStoragePaid]
					,[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,[dblFeesDue]
					,[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,[dblDiscountsDue]
					,[dblDiscountsPaid]
					,[strCustomerReference]
					,[strStorageType]
					,[intCurrencyId]
					,[strStorageTicketNumber]
					,[intItemId]
					,[intUnitMeasureId]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					,[intTransactionTypeId]
					,[intEntityId]
					,[intCompanyLocationId]
					,[strTransferTicket]		
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,@intCustomerStorageId
					,NULL
					,NULL
					,CASE WHEN ISNULL(@ActionContractHeaderId,0)>0 THEN @ActionContractHeaderId ELSE NULL END
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,'From Transfer'
					,@UserName
					,3
					,@ItemEntityid
					,@ItemCompanyLocationId
					,@TransferTicketNumber
					)				
			END
			
			IF ISNULL(@ActionContractHeaderId,0)>0
			BEGIN
			SELECT @ActionontractDetailId=intContractDetailId FROM vyuCTContractDetailView WHERE intContractHeaderId=@ActionContractHeaderId

				EXEC uspCTUpdateSequenceQuantityUsingUOM 
					  @intContractDetailId=@ActionontractDetailId
					 ,@dblQuantityToUpdate=@ActionOpenBalance
					 ,@intUserId=@UserKey
					 ,@intExternalId=@intCustomerStorageId
					 ,@strScreenName='Transfer Storage'
					 ,@intSourceItemUOMId=@intSourceItemUOMId			
			END
			
			---Discount Information
			INSERT INTO [dbo].[tblQMTicketDiscount]
			   (
					[intConcurrencyId]         
				   ,[dblGradeReading]
				   ,[strCalcMethod]
				   ,[strShrinkWhat]
				   ,[dblShrinkPercent]
				   ,[dblDiscountAmount]
				   ,[dblDiscountDue]
				   ,[dblDiscountPaid]
				   ,[ysnGraderAutoEntry]
				   ,[intDiscountScheduleCodeId]
				   ,[dtmDiscountPaidDate]
				   ,[intTicketId]
				   ,[intTicketFileId]
				   ,[strSourceType]
				   ,[intSort]
				   ,[strDiscountChargeType]
			   )
				 SELECT 
				 [intConcurrencyId] = 1
				,[dblGradeReading] = [dblGradeReading]
				,[strCalcMethod] = [strCalcMethod]
				,[strShrinkWhat] = [strShrinkWhat]
				,[dblShrinkPercent] = [dblShrinkPercent]
				,[dblDiscountAmount] = [dblDiscountAmount]
				,[dblDiscountDue] = [dblDiscountDue]
				,[dblDiscountPaid] = [dblDiscountPaid]
				,[ysnGraderAutoEntry] = [ysnGraderAutoEntry]
				,[intDiscountScheduleCodeId] = [intDiscountScheduleCodeId]
				,[dtmDiscountPaidDate] = [dtmDiscountPaidDate]
				,[intTicketId] = NULL
				,[intTicketFileId] = @NewCustomerStorageId
				,[strSourceType] = 'Storage'
				,[intSort] = [intSort]
				,[strDiscountChargeType] = [strDiscountChargeType]
			FROM dbo.[tblQMTicketDiscount]
			WHERE intTicketFileId = @intCustomerStorageId AND strSourceType = 'Storage'


			SELECT @ActionKey = MIN(intActionKey)
			FROM @Action
			WHERE intActionKey > @ActionKey
		END

		SELECT @ItemsToMoveKey = MIN(intItemsToMoveKey)
		FROM @ItemsToMove
		WHERE intItemsToMoveKey > @ItemsToMoveKey	
		
	END
	
	EXEC sp_xml_removedocument @idoc
	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()	 
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH