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
	DECLARE @TicketNo Nvarchar(20)
	
	DECLARE @ActionCustomer INT
		,@Percent DECIMAL(24,10)
		,@ActionOpenBalance DECIMAL(24,10)
		,@ActionStorageTypeId INT
		,@ActionStorageScheduleId INT
		,@ActionCompanyLocationId INT
		
	DECLARE @UserKey INT
	DECLARE @UserName NVARCHAR(100)
	DECLARE @intCommodityId INT
	DECLARE @InventoryStockUOM Nvarchar(50)
	DECLARE @ItemsToMoveKey INT
	DECLARE @ActionKey INT
	DECLARE @ItemLocationName NVARCHAR(100)
	DECLARE @ItemCustomerName NVARCHAR(200)
	DECLARE @ItemStorageTypeDescription NVARCHAR(50)
	DECLARE @ItemStorageScheduleId NVARCHAR(50)
	DECLARE @ActionLocationName NVARCHAR(100)
	DECLARE @ActionStorageTypeDescription NVARCHAR(50)
	DECLARE @ActionCustomerName NVARCHAR(200)
	DECLARE @OldTicketMessage NVARCHAR(1000)
	DECLARE @NewTicketMessage NVARCHAR(1000)
	DECLARE @UnitsToReduce DECIMAL(18,6)
	DECLARE @CurrentItemOpenBalance DECIMAL(24,10)

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
	)

	SELECT @UserKey = intCreatedUserId
		,@ItemEntityid = intItemCustomerId
		,@ItemCompanyLocationId = intItemLocation
		,@ActionCompanyLocationId = intActionLocation
		,@intCommodityId=intCommodityId
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			 intCreatedUserId INT
			,intItemCustomerId INT
			,intItemLocation INT
			,intActionLocation INT
			,intCommodityId INT
	)
		
	SELECT @InventoryStockUOM=
		U1.strUnitMeasure 
		FROM 
		tblICCommodity C 
		JOIN tblICCommodityUnitMeasure U ON U.intCommodityId=C.intCommodityId
		JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId=U.intUnitMeasureId
		Where U.ysnStockUnit=1 AND C.intCommodityId=@intCommodityId
												
	SELECT @ItemCustomerName = strName	FROM tblEntity	WHERE intEntityId = @ItemEntityid

	SELECT @ItemLocationName = strLocationName	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @ItemCompanyLocationId

	SELECT @ActionLocationName = strLocationName FROM tblSMCompanyLocation	WHERE intCompanyLocationId = @ActionCompanyLocationId

	SELECT @UserName = strUserName	FROM tblSMUserSecurity	WHERE intUserSecurityID = @UserKey

	INSERT INTO @ItemsToMove 
	(
		intCustomerStorageId
		,intEntityId
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
		,dblOpenBalance
	)
	SELECT intCustomerStorageId
		,intEntityId
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
		,dblOpenBalance
	FROM OPENXML(@idoc, 'root/ItemsToTransfer', 2) WITH 
	(
			intCustomerStorageId INT
			,intEntityId INT
			,intCompanyLocationId INT
			,intStorageTypeId INT
			,intStorageScheduleId INT
			,dblOpenBalance DECIMAL(24,10)
	)

	INSERT INTO @Action 
	(
		intEntityId
		,dblPercent
		,dblOpenBalance
		,intStorageTypeId
		,intStorageScheduleId
		,intCompanyLocationId
	)
	SELECT intEntityId
		,dblPercent
		,dblOpenBalance
		,intStorageTypeId
		,intStorageScheduleId
		,intCompanyLocationId
	FROM OPENXML(@idoc, 'root/ActionTransfer', 2) WITH 
	(
			intEntityId INT
			,dblPercent DECIMAL(24,10)
			,dblOpenBalance DECIMAL(24,10)
			,intStorageTypeId INT
			,intStorageScheduleId INT
			,intCompanyLocationId INT
	)
  
  

	SELECT @ItemsToMoveKey = MIN(intItemsToMoveKey)
	FROM @ItemsToMove

	SET @intCustomerStorageId = NULL
	SET @ItemStorageType = NULL
	SET @ItemStorageSchedule=NULL
	SET @ItemBalance = NULL
	SET @ItemStorageTypeDescription = NULL
	SET @ItemStorageScheduleId=NULL
	SET @OldTicketMessage = NULL
	SET @CurrentItemOpenBalance=NULL
	SET @TicketNo=NULL
	

	
	WHILE @ItemsToMoveKey > 0
	BEGIN
		SELECT @intCustomerStorageId = intCustomerStorageId
			,@ItemStorageType = intStorageTypeId
			,@ItemStorageSchedule=intStorageScheduleId
			,@ItemBalance = dblOpenBalance
		FROM @ItemsToMove
		WHERE intItemsToMoveKey = @ItemsToMoveKey
		
		SELECT @CurrentItemOpenBalance=dblOpenBalance,@TicketNo=intStorageTicketNumber FROM tblGRCustomerStorage Where intCustomerStorageId=@intCustomerStorageId

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
		SET @NewTicketMessage = NULL
		SET @ActionStorageTypeDescription = NULL
		SET @ActionCustomerName = NULL
		SET @NewCustomerStorageId=NULL
		
		IF @CurrentItemOpenBalance <> @ItemBalance
		BEGIN		 
		 SELECT @TicketNo=intStorageTicketNumber FROM tblGRCustomerStorage Where intCustomerStorageId=@intCustomerStorageId
		 SET @ErrMsg='The Open balance of ticket '+@TicketNo+' has been modified by another user.  Transfer Process cannot proceed.'
		 RAISERROR(@ErrMsg,16,1)		 
		END
		
		
		
		WHILE @ActionKey > 0
		BEGIN
		
		 
			SELECT @ActionCustomer = intEntityId
				,@Percent = dblPercent
				,@ActionOpenBalance = dblOpenBalance
				,@ActionStorageTypeId = intStorageTypeId
				,@ActionStorageScheduleId = intStorageScheduleId
			FROM @Action
			WHERE intActionKey = @ActionKey

			SELECT @ActionStorageTypeDescription = strStorageTypeDescription
			FROM tblGRStorageType
			WHERE intStorageScheduleTypeId = @ActionStorageTypeId

			SELECT @ActionCustomerName = strName
			FROM tblEntity
			WHERE intEntityId = @ActionCustomer
			
			---CASE #1:Customer Match,Location Match, Storatype Mismatch
			IF @ItemEntityid = @ActionCustomer AND @ItemCompanyLocationId = @ActionCompanyLocationId AND @ItemStorageType <> @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				
				SET @OldTicketMessage = 'Transferred ' +Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' to '+@ActionCustomerName +' '+@ActionLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ActionStorageTypeDescription
				
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
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,@OldTicketMessage
					,NULL
					,'Transfer'
					,@UserName
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
					,[intStorageTicketNumber]
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
					,[dblOriginalBalance]
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
					,[intStorageTicketNumber]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,@UnitsToReduce
					,GETDATE()
					,NULL 
					,'Transferred '+Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' FROM '+@ItemLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ItemStorageTypeDescription+' '+@ItemCustomerName
					,NULL
					,'Created by Transfer'
					,@UserName
					)
			END
			
			---CASE #2:Customer Match,Location MisMatch,Storatype Match
			
			IF @ItemEntityid = @ActionCustomer AND @ItemCompanyLocationId <> @ActionCompanyLocationId AND @ItemStorageType = @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				
				SET @OldTicketMessage = 'Transferred ' +Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' to '+@ActionCustomerName +' '+@ActionLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ActionStorageTypeDescription
				
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
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,@OldTicketMessage
					,NULL
					,'Transfer'
					,@UserName
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
					,[intStorageTicketNumber]
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
					,[dblOriginalBalance]
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
					,[intStorageTicketNumber]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,'Transferred '+Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' FROM '+@ItemLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ItemStorageTypeDescription+' '+@ItemCustomerName
					,NULL
					,'Created by Transfer'
					,@UserName
					)
			END
			
			---CASE #3:Customer Match,Location MisMatch,Storatype MisMatch
			IF @ItemEntityid = @ActionCustomer AND @ItemCompanyLocationId <> @ActionCompanyLocationId AND @ItemStorageType <> @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				
				SET @OldTicketMessage = 'Transferred ' +Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' to '+@ActionCustomerName +' '+@ActionLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ActionStorageTypeDescription
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
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,@OldTicketMessage
					,NULL
					,'Transfer'
					,@UserName
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
					,[intStorageTicketNumber]
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
					,[dblOriginalBalance]
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
					,[intStorageTicketNumber]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,'Transferred '+Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' FROM '+@ItemLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ItemStorageTypeDescription+' '+@ItemCustomerName
					,NULL
					,'Created by Transfer'
					,@UserName
					)
			END
			
			---CASE #4:Customer MisMatch,Location Match,Storatype Match			
			IF @ItemEntityid <> @ActionCustomer AND @ItemCompanyLocationId = @ActionCompanyLocationId AND @ItemStorageType = @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				
				SET @OldTicketMessage = 'Transferred ' +Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' to '+@ActionCustomerName +' '+@ActionLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ActionStorageTypeDescription
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
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,@OldTicketMessage
					,NULL
					,'Transfer'
					,@UserName
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
					,[intStorageTicketNumber]
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
					,[dblOriginalBalance]
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
					,[intStorageTicketNumber]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,'Transferred '+Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' FROM '+@ItemLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ItemStorageTypeDescription+' '+@ItemCustomerName
					,NULL
					,'Created by Transfer'
					,@UserName
					)
			END
			
			---CASE #5:Customer MisMatch,Location Match,Storatype MisMatch
					
			IF @ItemEntityid <> @ActionCustomer AND @ItemCompanyLocationId = @ActionCompanyLocationId AND @ItemStorageType <> @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				
				SET @OldTicketMessage = 'Transferred ' +Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' to '+@ActionCustomerName +' '+@ActionLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ActionStorageTypeDescription
				
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
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,@OldTicketMessage
					,NULL
					,'Transfer'
					,@UserName
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
					,[intStorageTicketNumber]
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
					,[dblOriginalBalance]
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
					,[intStorageTicketNumber]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,'Transferred '+Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' FROM '+@ItemLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ItemStorageTypeDescription+' '+@ItemCustomerName
					,NULL
					,'Created by Transfer'
					,@UserName
					)
			END
			
			--CASE #6:Customer MisMatch,Location MisMatch,Storatype Match
			IF @ItemEntityid <> @ActionCustomer AND @ItemCompanyLocationId <> @ActionCompanyLocationId AND @ItemStorageType = @ActionStorageTypeId
			BEGIN
			
				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				
				SET @OldTicketMessage = 'Transferred ' +Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' to '+@ActionCustomerName +' '+@ActionLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ActionStorageTypeDescription
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
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,@OldTicketMessage
					,NULL
					,'Transfer'
					,@UserName
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
					,[intStorageTicketNumber]
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
					,[dblOriginalBalance]
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
					,[intStorageTicketNumber]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,'Transferred '+Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' FROM '+@ItemLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ItemStorageTypeDescription+' '+@ItemCustomerName
					,NULL
					,'Created by Transfer'
					,@UserName
					)

			
			END
			
			--CASE #7:Customer MisMatch,Location MisMatch,Storatype MisMatch
			IF @ItemEntityid <> @ActionCustomer AND @ItemCompanyLocationId <> @ActionCompanyLocationId AND @ItemStorageType <> @ActionStorageTypeId
			BEGIN
			
				

				SELECT @UnitsToReduce = @ItemBalance * (@Percent / 100)
				SET @OldTicketMessage = 'Transferred ' +Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' to '+@ActionCustomerName +' '+@ActionLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ActionStorageTypeDescription
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
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@intCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,- @UnitsToReduce
					,GETDATE()
					,NULL
					,@OldTicketMessage
					,NULL
					,'Transfer'
					,@UserName
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
					,[intStorageTicketNumber]
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
					,[dblOriginalBalance]
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
					,[intStorageTicketNumber]
				FROM tblGRCustomerStorage
				WHERE intCustomerStorageId = @intCustomerStorageId

				SET @NewCustomerStorageId = SCOPE_IDENTITY()

				INSERT INTO [dbo].[tblGRStorageHistory] (
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intTicketId]
					,[intInventoryReceiptId]
					,[intInvoiceId]
					,[intContractDetailId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[dblPaidAmount]
					,[strPaidDescription]
					,[dblCurrencyRate]
					,[strType]
					,[strUserName]
					)
				VALUES (
					1
					,@NewCustomerStorageId
					,NULL
					,NULL
					,NULL
					,NULL
					,@UnitsToReduce
					,GETDATE()
					,NULL
					,'Transferred '+Convert(Nvarchar,CAST(@UnitsToReduce AS FLOAT))+@InventoryStockUOM+' FROM '+@ItemLocationName+' '+Convert(Nvarchar,@TicketNo)+' '+@ItemStorageTypeDescription+' '+@ItemCustomerName
					,NULL
					,'Created by Transfer'
					,@UserName
					)				
			END
		
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


