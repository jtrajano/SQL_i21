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
	DECLARE @intBillBeforeTransfer INT
	DECLARE @strProcessType Nvarchar(30)
	DECLARE @strUpdateType NVARCHAR(30)

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
		,dblNewStorageDue DECIMAL(24,10)
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
		,@intBillBeforeTransfer=intBillBeforeTransfer
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			 intCreatedUserId INT			
			,intItemCustomerId INT
			,intItemLocation INT
			,intActionLocation INT
			,strTransferTicketNumber NVARCHAR(20)
			,intBillBeforeTransfer INT
	)	
	IF @intBillBeforeTransfer=1	
	BEGIN
		SET @strProcessType='calculate'
		SET @strUpdateType='Bill'
    END
												
	SELECT @ItemCustomerName = strName	FROM tblEMEntity	WHERE intEntityId = @ItemEntityid

	SELECT @ItemLocationName = strLocationName	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @ItemCompanyLocationId

	SELECT @ActionLocationName = strLocationName FROM tblSMCompanyLocation	WHERE intCompanyLocationId = @ActionCompanyLocationId

	SELECT @UserName = strUserName	FROM tblSMUserSecurity	WHERE [intEntityUserSecurityId] = @UserKey

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
		
		IF @intBillBeforeTransfer=1	
		BEGIN
			--Storage Charge Update
			EXEC uspGRCalculateStorageCharge
			  @strProcessType
			 ,@strUpdateType
			 ,@intCustomerStorageId
			 ,NULL
			 ,NULL
			 ,NULL
			 ,NULL
			 ,@UserKey
			 ,'Transfer Storage'
			 ,@dblStorageDuePerUnit OUTPUT
			 ,@dblStorageDueAmount OUTPUT
			 ,@dblStorageDueTotalPerUnit OUTPUT
			 ,@dblStorageDueTotalAmount OUTPUT
			 ,@dblStorageBilledPerUnit OUTPUT
			 ,@dblStorageBilledAmount OUTPUT
			 
			 UPDATE @ItemsToMove SET dblNewStorageDue = @dblStorageDuePerUnit WHERE intCustomerStorageId = @intCustomerStorageId

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
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStorageDue] END
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStoragePaid] END				
					,0--[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,0--[dblFeesDue]
					,0--[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,0--[dblDiscountsDue]
					,0--[dblDiscountsPaid]
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
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStorageDue] END
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStoragePaid] END
					,0--[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,0--[dblFeesDue]
					,0--[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,0--[dblDiscountsDue]
					,0--[dblDiscountsPaid]
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
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStorageDue] END
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStoragePaid] END
					,0--[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,0--[dblFeesDue]
					,0--[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,0--[dblDiscountsDue]
					,0--[dblDiscountsPaid]
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
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStorageDue] END
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStoragePaid] END
					,0--[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,0--[dblFeesDue]
					,0--[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,0--[dblDiscountsDue]
					,0--[dblDiscountsPaid]
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
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStorageDue] END
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStoragePaid] END
					,0--[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,0--[dblFeesDue]
					,0--[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,0--[dblDiscountsDue]
					,0--[dblDiscountsPaid]
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
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStorageDue] END
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStoragePaid] END
					,0--[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,0--[dblFeesDue]
					,0--[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,0--[dblDiscountsDue]
					,0--[dblDiscountsPaid]
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
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStorageDue] END
					,CASE WHEN @strProcessType='Bill' THEN 0 ELSE [dblStoragePaid] END
					,0--[dblInsuranceRate]
					,[strOriginState]
					,[strInsuranceState]
					,0--[dblFeesDue]
					,0--[dblFeesPaid]
					,[dblFreightDueRate]
					,[ysnPrinted]
					,[dblCurrencyRate]
					,[strDiscountComment]
					,0--[dblDiscountsDue]
					,0--[dblDiscountsPaid]
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

			SELECT @ActionKey = MIN(intActionKey)
			FROM @Action
			WHERE intActionKey > @ActionKey
		END

		SELECT @ItemsToMoveKey = MIN(intItemsToMoveKey)
		FROM @ItemsToMove
		WHERE intItemsToMoveKey > @ItemsToMoveKey	
		
	END	
	
	---CREATING INVOICE
	
		SELECT @IntCommodityId=intCommodityId FROM tblGRCustomerStorage Where intCustomerStorageId=@intCustomerStorageId
				
		SELECT TOP 1 @intStorageChargeItemId=intItemId FROM tblICItem 
		WHERE strType='Other Charge' AND strCostType='Storage Charge' AND intCommodityId = @IntCommodityId
		
		IF @intStorageChargeItemId IS NULL
		BEGIN
			SELECT TOP 1 @intStorageChargeItemId=intItemId FROM tblICItem 
			WHERE strType='Other Charge' AND strCostType='Storage Charge'
		END
		
		IF @intStorageChargeItemId IS NULL 
		BEGIN
			RAISERROR('Invoice cannot be created because there is no Other Charge Item having Storage Charge as CostType.', 16, 1);
		END	
		
		SELECT @ItemDescription=strDescription FROM tblICItem Where intItemId=@intStorageChargeItemId
		
		SET @UserEntityId = ISNULL((SELECT [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserKey), @UserKey)
		
		SET @intCurrencyId = ISNULL((SELECT intCurrencyId FROM tblAPVendor WHERE intEntityVendorId = @ItemEntityid), @intDefaultCurrencyId)

		SELECT @intTermId = intTermsId FROM tblEMEntityLocation WHERE intEntityId = @ItemEntityid
		
		SELECT @intItemUOMId=intItemUOMId FROM tblICItemUOM WHERE intItemId=@ItemId AND intUnitMeasureId=@intUnitMeasureId
		
		UPDATE BD 
		SET BD.intOriginalUnitMeasureId=CS.intUnitMeasureId 
		FROM @ItemsToMove BD 
		JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=BD.intCustomerStorageId
		
		UPDATE @ItemsToMove
		SET dblOpenBalance=dbo.fnCTConvertQuantityToTargetItemUOM(@ItemId,intOriginalUnitMeasureId,@intUnitMeasureId,dblOpenBalance)
		
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
					,[intEntityCustomerId] = @ItemEntityid
					,[intCompanyLocationId] = @ItemCompanyLocationId
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
					,[strItemDescription] = @ItemDescription
					,[intOrderUOMId]= @intItemUOMId
					,[intItemUOMId] = @intItemUOMId
					,[dblQtyOrdered] = dblOpenBalance
					,[dblQtyShipped] = dblOpenBalance
					,[dblDiscount] = 0
					,[dblPrice] = dblNewStorageDue
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
					,[intCustomerStorageId]=intCustomerStorageId
					FROM @ItemsToMove				
					
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
					,[strUserName]=(SELECT strUserName FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserKey)
					 FROM tblARInvoice AR
					 JOIN tblARInvoiceDetail ARD ON ARD.intInvoiceId = AR.intInvoiceId
					 WHERE AR.intInvoiceId = CONVERT(INT,@CreatedIvoices)
								   
				
		END
		ELSE
		BEGIN
			RAISERROR(@ErrorMessage, 16, 1);
			ROLLBACK TRANSACTION
		END
	
	--END CREATING INVOICE--
	
	EXEC sp_xml_removedocument @idoc
	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()	 
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH