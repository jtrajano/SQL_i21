CREATE PROCEDURE [dbo].[uspGRUpdateGrainOpenBalanceByFIFO]
	 @strOptionType NVARCHAR(30)
	,@strSourceType NVARCHAR(30)---[SalesOrder,Scale]
	,@intEntityId INT
	,@intItemId INT
	,@intStorageTypeId INT
	,@dblUnitsConsumed NUMERIC(24, 10) = 0
	,@IntSourceKey INT
	,@intUserId INT
	
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @dblAvailableGrainOpenBalance DECIMAL(24, 10)
	DECLARE @strProcessType NVARCHAR(30)
	DECLARE @strUpdateType NVARCHAR(30)
	DECLARE @intCustomerStorageId INT
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	DECLARE @StorageChargeDate DATETIME
	DECLARE @dblStorageUnits DECIMAL(24, 10)
	DECLARE @intColumnKey INT
	DECLARE @strColumnName NVARCHAR(40)
	DECLARE @strColumnSuffix NVARCHAR(40)
	DECLARE @strOriginalColumnName NVARCHAR(40)
	DECLARE @SqlAddColumn NVARCHAR(MAX)
	DECLARE @strItemNo NVARCHAR(MAX)
	DECLARE @intStorageChargeItemId INT
	DECLARE @IntCommodityId INT
	DECLARE @FeeItemId INT
	DECLARE @strFeeItem NVARCHAR(40)

	IF OBJECT_ID('tempdb..#tblGRCustomerStorage') IS NOT NULL
		DROP TABLE #tblGRCustomerStorage

	CREATE TABLE #tblGRCustomerStorage 
	(
		 [intCustomerStorageId] INT
		,[strStorageTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblOpenBalance] NUMERIC(18,6)
		,[intUnitMeasureId] INT
		,[strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,[dblStorageCharge] NUMERIC(18,6)
		,[intStorageItemId] INT
		,[strStorageItem] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[FeeItemId] INT
		,[strFeeItem] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblFees] NUMERIC(18,6)		
	)

	IF OBJECT_ID('tempdb..#tblRequiredColumns') IS NOT NULL
		DROP TABLE #tblRequiredColumns

	CREATE TABLE #tblRequiredColumns 
	(
		 [intColumnKey] INT IDENTITY(1,1)
		,[strColumnName] NVARCHAR(100) COLLATE Latin1_General_CI_AS
	 )

	SET @strUpdateType = 'estimate'
	SET @strProcessType = 'calculate'
	SET @StorageChargeDate = GetDATE()
	
	SELECT @FeeItemId=intItemId FROM tblGRCompanyPreference
	SELECT @strFeeItem=strItemNo FROM tblICItem WHERE intItemId=@FeeItemId
	 
	SELECT @dblAvailableGrainOpenBalance = SUM(dblOpenBalance)
	FROM vyuGRGetStorageTransferTicket
	WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intStorageTypeId = @intStorageTypeId AND ysnDPOwnedType=0 AND ysnCustomerStorage=0

	IF @strOptionType = 'Inquiry'
	BEGIN
		SELECT @dblAvailableGrainOpenBalance
	END
	ELSE IF @dblUnitsConsumed > 0 AND @dblAvailableGrainOpenBalance > 0
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM tblGRCustomerStorage WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intStorageTypeId = @intStorageTypeId AND dblOpenBalance > 0)
		BEGIN
			RAISERROR ('There is no available grain balance for this Entity,Item and Storage Type.',16,1);
		END

		---1.Choosing the Grain Tickets Based ON FIFO(Delivery Date).
		WHILE @dblUnitsConsumed > 0
		BEGIN
			SET @intCustomerStorageId = NULL
			SET @dblStorageDuePerUnit = NULL
			SET @dblStorageDueAmount = NULL
			SET @dblStorageDueTotalPerUnit = NULL
			SET @dblStorageDueTotalAmount = NULL
			SET @dblStorageBilledPerUnit = NULL
			SET @dblStorageBilledAmount = NULL
			SET @dblStorageUnits = NULL

			SELECT TOP 1 @intCustomerStorageId = intCustomerStorageId
				,@dblStorageUnits = dblOpenBalance
			FROM vyuGRGetStorageTransferTicket
			WHERE intEntityId = @intEntityId
				AND intItemId = @intItemId
				AND intStorageTypeId = @intStorageTypeId
				AND ysnDPOwnedType=0 
				AND ysnCustomerStorage=0				
				AND dtmDeliveryDate IS NOT NULL
				AND intCustomerStorageId NOT IN (SELECT intCustomerStorageId FROM #tblGRCustomerStorage)
			ORDER BY dtmDeliveryDate,intCustomerStorageId

			IF @intCustomerStorageId IS NULL
				BREAK

			IF @dblStorageUnits > @dblUnitsConsumed
				SET @dblStorageUnits = @dblUnitsConsumed

			EXEC uspGRCalculateStorageCharge 
				 @strProcessType
				,@strUpdateType
				,@intCustomerStorageId
				,NULL
				,NULL
				,@dblStorageUnits
				,@StorageChargeDate
				,@intUserId
				,'Process Grain Storage'
				,@dblStorageDuePerUnit OUTPUT
				,@dblStorageDueAmount OUTPUT
				,@dblStorageDueTotalPerUnit OUTPUT
				,@dblStorageDueTotalAmount OUTPUT
				,@dblStorageBilledPerUnit OUTPUT
				,@dblStorageBilledAmount OUTPUT

			INSERT INTO #tblGRCustomerStorage 
			(
				 [intCustomerStorageId]
				,[strStorageTicketNumber]
				,[dblOpenBalance]
				,[intUnitMeasureId]
				,[strUnitMeasure]
				,[dblStorageCharge]				
				,[dblFees]				
			 )
			SELECT 
				 @intCustomerStorageId
				,a.[strStorageTicketNumber]
				,@dblStorageUnits
				,a.[intUnitMeasureId]
				,b.[strUnitMeasure]
				,@dblStorageDueAmount+@dblStorageDueTotalAmount --(Unpaid:@dblStorageDueAmount+ Additional :@dblStorageDueTotalAmount)				
				,a.[dblFeesDue]- a.[dblFeesPaid]
			FROM tblGRCustomerStorage a
			JOIN tblICUnitMeasure b ON a.[intUnitMeasureId]=b.[intUnitMeasureId]
			WHERE [intCustomerStorageId] = @intCustomerStorageId
			
			SET @intStorageChargeItemId=NULL
			SET @IntCommodityId=NULL
			
			SELECT @IntCommodityId=intCommodityId FROM tblGRCustomerStorage Where[intCustomerStorageId] = @intCustomerStorageId
			
			IF EXISTS(SELECT 1 FROM tblICItem WHERE strType='Other Charge' AND strCostType='Storage Charge' AND intCommodityId = @IntCommodityId)
			BEGIN
				SELECT TOP 1 @intStorageChargeItemId=intItemId FROM tblICItem 
				WHERE strType='Other Charge' AND strCostType='Storage Charge' AND intCommodityId = @IntCommodityId				
				UPDATE #tblGRCustomerStorage SET [intStorageItemId]=@intStorageChargeItemId WHERE [intCustomerStorageId] = @intCustomerStorageId
				UPDATE #tblGRCustomerStorage SET [strStorageItem]=(SELECT strItemNo FROM tblICItem WHERE intItemId=@intStorageChargeItemId)
			END
			ELSE IF EXISTS(SELECT 1 FROM tblICItem WHERE strType='Other Charge' AND strCostType='Storage Charge' AND intCommodityId IS NULL)
			BEGIN
				SELECT TOP 1 @intStorageChargeItemId=intItemId FROM tblICItem 
				WHERE strType='Other Charge' AND strCostType='Storage Charge' AND intCommodityId IS NULL			
				UPDATE #tblGRCustomerStorage SET [intStorageItemId]=@intStorageChargeItemId WHERE [intCustomerStorageId] = @intCustomerStorageId
				UPDATE #tblGRCustomerStorage SET [strStorageItem]=(SELECT strItemNo FROM tblICItem WHERE intItemId=@intStorageChargeItemId)
			END
			ELSE
			BEGIN
				RAISERROR('There should be atleast One Storage charge Cost Type Item.', 16, 1);
			END
			
			SET @dblUnitsConsumed = @dblUnitsConsumed - @dblStorageUnits
		END

		---2. Adding the Required Columns in the Temporary Table AND updating the Columns.
		IF EXISTS (SELECT 1 FROM #tblGRCustomerStorage)
		BEGIN
			INSERT INTO #tblRequiredColumns ([strColumnName])
			SELECT DISTINCT '[' + b.strItemNo + ' Discount]'
			FROM tblGRDiscountScheduleCode a
			JOIN tblICItem b ON b.intItemId = a.intItemId
			JOIN tblQMTicketDiscount c ON c.intDiscountScheduleCodeId = a.intDiscountScheduleCodeId
			WHERE strSourceType = 'Storage'
				AND c.dblDiscountDue < > 0
				AND c.intTicketFileId IN (SELECT [intCustomerStorageId] FROM #tblGRCustomerStorage)
			
			UNION			
			SELECT DISTINCT '[' + b.strItemNo + ' Item Key]'
			FROM tblGRDiscountScheduleCode a
			JOIN tblICItem b ON b.intItemId = a.intItemId
			JOIN tblQMTicketDiscount c ON c.intDiscountScheduleCodeId = a.intDiscountScheduleCodeId
			WHERE strSourceType = 'Storage' 
				AND c.dblDiscountDue < > 0 
				AND c.intTicketFileId IN (SELECT [intCustomerStorageId] FROM #tblGRCustomerStorage)

			IF EXISTS (SELECT 1 FROM #tblRequiredColumns)
			BEGIN
				SELECT @intColumnKey = MIN(intColumnKey)
				FROM #tblRequiredColumns

				WHILE @intColumnKey > 0
				BEGIN
					SET @strColumnName = NULL
					SET @strColumnSuffix = NULL
					SET @SqlAddColumn = NULL
					SET @strItemNo = NULL

					SELECT @strColumnName = strColumnName
					FROM #tblRequiredColumns
					WHERE intColumnKey = @intColumnKey
					
					SET @strColumnSuffix = RIGHT(@strColumnName, 9)					
					SET @strItemNo = REPLACE(@strColumnName, '[', '''')
					SET @strItemNo = REPLACE(@strItemNo, ']', '''')

					IF @strColumnSuffix = 'Discount]'
					BEGIN
					
					SET @SqlAddColumn = 'ALTER TABLE #tblGRCustomerStorage ADD ' + @strColumnName + ' DECIMAL(24,10) NULL'
					EXEC (@SqlAddColumn)
					SET @SqlAddColumn = NULL
					
						SET @strItemNo = REPLACE(@strItemNo, ' Discount', '')
						SET @SqlAddColumn = 'UPDATE CS SET CS.' + @strColumnName + '= QM.dblDiscountDue 
												FROM #tblGRCustomerStorage CS
												JOIN tblQMTicketDiscount QM on QM.intTicketFileId=CS.intCustomerStorageId AND QM.strSourceType=''Storage''
												JOIN tblGRDiscountScheduleCode DS ON DS.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
												JOIN tblICItem Item ON Item.intItemId=DS.intItemId AND Item.strItemNo=' + @strItemNo

						EXEC (@SqlAddColumn)
					END
					ELSE IF @strColumnSuffix = 'Item Key]'
					BEGIN
					SET @SqlAddColumn = 'ALTER TABLE #tblGRCustomerStorage ADD ' + @strColumnName + ' INT NULL'
					EXEC (@SqlAddColumn)
					SET @SqlAddColumn = NULL
					
						SET @strItemNo = REPLACE(@strItemNo, ' Item Key', '')
						SET @SqlAddColumn = 'UPDATE CS SET CS.' + @strColumnName + '= DS.intItemId 
												FROM #tblGRCustomerStorage CS
												JOIN tblQMTicketDiscount QM on QM.intTicketFileId=CS.intCustomerStorageId AND QM.strSourceType=''Storage''
												JOIN tblGRDiscountScheduleCode DS ON DS.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
												JOIN tblICItem Item ON Item.intItemId=DS.intItemId AND Item.strItemNo=' + @strItemNo

						EXEC (@SqlAddColumn)
					END

					SELECT @intColumnKey = MIN(intColumnKey)
					FROM #tblRequiredColumns
					WHERE intColumnKey > @intColumnKey
				END
			END
			
			UPDATE #tblGRCustomerStorage SET [FeeItemId]=@FeeItemId,[strFeeItem]=@strFeeItem				
			
			UPDATE CS
			SET CS.dblOpenBalance=CS.dblOpenBalance-tblCS.dblOpenBalance
			FROM tblGRCustomerStorage CS 
			JOIN #tblGRCustomerStorage tblCS ON CS.intCustomerStorageId=tblCS.intCustomerStorageId
			
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				 [intConcurrencyId]
				,[intCustomerStorageId]
				,[intTicketId]
				,[intSalesOrderId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[dblPaidAmount]
				,[strType]
				,[strUserName]
			 )
			SELECT 
				 [intConcurrencyId] = 1
				,[intCustomerStorageId] = intCustomerStorageId
				,[intTicketId] =    CASE WHEN @strSourceType='Scale' THEN @IntSourceKey ELSE NULL END
				,[intSalesOrderId]= CASE WHEN @strSourceType='SalesOrder' THEN @IntSourceKey ELSE NULL END				
				,[dblUnits] = dblOpenBalance
				,[dtmHistoryDate] = GetDATE()
				,[dblPaidAmount] = [dblStorageCharge]* dblOpenBalance
				,[strType] = CASE 
								 WHEN @strSourceType='SalesOrder' THEN 'Reduced By Sales Order'
								 WHEN @strSourceType='Scale'	  THEN 'Reduced By Scale'
							 END
				,[strUserName] = (SELECT strUserName FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @intUserId)
			FROM #tblGRCustomerStorage

			SELECT * FROM #tblGRCustomerStorage
			
		END
	END
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH
