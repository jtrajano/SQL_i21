CREATE PROCEDURE [dbo].[uspGRStorageSave]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
	DECLARE @intCustomerStorageId INT
	DECLARE @ysnUpdateHouseTotal INT
	DECLARE @intConcurrencyId INT
	DECLARE @intEntityId INT
	DECLARE @intStorageTicketNumber INT
	DECLARE @intStorageTypeId INT
	DECLARE @intItemId INT
	DECLARE @intCommodityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @OldintStorageScheduleId INT
	DECLARE @NewintStorageScheduleId INT
	DECLARE @OldstrDPARecieptNumber NVARCHAR(10)
	DECLARE @NewstrDPARecieptNumber NVARCHAR(10)
	DECLARE @OldstrCustomerReference NVARCHAR(25)
	DECLARE @NewstrCustomerReference NVARCHAR(25)
	DECLARE @OlddblOriginalBalance NUMERIC(18, 6)
	DECLARE @NewdblOriginalBalance NUMERIC(18, 6)
	DECLARE @OlddblOpenBalance NUMERIC(18, 6)
	DECLARE @NewdblOpenBalance NUMERIC(18, 6)
	DECLARE @OlddtmDeliveryDate DATETIME
	DECLARE @NewdtmDeliveryDate DATETIME
	DECLARE @OldstrDiscountComment NVARCHAR(100)
	DECLARE @NewstrDiscountComment NVARCHAR(100)
	DECLARE @OlddblInsuranceRate NUMERIC(18, 6)
	DECLARE @NewdblInsuranceRate NUMERIC(18, 6)
	DECLARE @OlddblStorageDue NUMERIC(18, 6)
	DECLARE @NewdblStorageDue NUMERIC(18, 6)
	DECLARE @OlddblStoragePaid NUMERIC(18, 6)
	DECLARE @NewdblStoragePaid NUMERIC(18, 6)
	DECLARE @OlddblFeesDue NUMERIC(18, 6)
	DECLARE @NewdblFeesDue NUMERIC(18, 6)
	DECLARE @OlddblFeesPaid NUMERIC(18, 6)
	DECLARE @NewdblFeesPaid NUMERIC(18, 6)
	DECLARE @OlddblDiscountsDue NUMERIC(18, 6)
	DECLARE @NewdblDiscountsDue NUMERIC(18, 6)
	DECLARE @OlddblDiscountsPaid NUMERIC(18, 6)
	DECLARE @NewdblDiscountsPaid NUMERIC(18, 6)
	DECLARE @intDiscountScheduleId INT
	DECLARE @intCurrencyId INT
	DECLARE @UserKey INT
	DECLARE @UserName NVARCHAR(100)
	DECLARE @strDiscountCode NVARCHAR(3)
		,@strDiscountCodeDescription NVARCHAR(20)
		,@dblGradeReading DECIMAL(7, 3)
		,@dblShrinkPercent DECIMAL(7, 3)
		,@strShrinkWhat NVARCHAR(50)
		,@dblDiscountDue DECIMAL(18, 6)
		,@dblDiscountPaid DECIMAL(18, 6)
		,@intDiscountScheduleCodeId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	---Header
	SELECT @UserKey = intCreatedUserId
		,@intCustomerStorageId = intCustomerStorageId
		,@ysnUpdateHouseTotal = ysnUpdateHouseTotal
		,@intConcurrencyId = intConcurrencyId
		,@intEntityId = intEntityId
		,@intStorageTicketNumber = intStorageTicketNumber
		,@intStorageTypeId = intStorageTypeId
		,@intItemId = intItemId
		,@intCommodityId = intCommodityId
		,@intCompanyLocationId = intCompanyLocationId
		,@NewintStorageScheduleId = intStorageScheduleId
		,@NewstrDPARecieptNumber = strDPARecieptNumber
		,@NewstrCustomerReference = strCustomerReference
		,@NewdblOriginalBalance = dblOriginalBalance
		,@NewdblOpenBalance = dblOpenBalance
		,@NewdtmDeliveryDate = dtmDeliveryDate
		,@NewstrDiscountComment = strDiscountComment
		,@NewdblInsuranceRate = dblInsuranceRate
		,@NewdblStorageDue = dblStorageDue
		,@NewdblStoragePaid = dblStoragePaid
		,@NewdblFeesDue = dblFeesDue
		,@NewdblFeesPaid = dblFeesPaid
		,@NewdblDiscountsDue = dblDiscountsDue
		,@NewdblDiscountsPaid = dblDiscountsPaid
		,@intDiscountScheduleId = intDiscountScheduleId
		,@intCurrencyId = intCurrencyId
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			intCreatedUserId INT
			,intCustomerStorageId INT
			,ysnUpdateHouseTotal INT
			,intConcurrencyId INT
			,intEntityId INT
			,intStorageTicketNumber INT
			,intStorageTypeId INT
			,intItemId INT
			,intCommodityId INT
			,intCompanyLocationId INT
			,intStorageScheduleId INT
			,strDPARecieptNumber NVARCHAR(10)
			,strCustomerReference NVARCHAR(25)
			,dblOriginalBalance NUMERIC(18, 6)
			,dblOpenBalance NUMERIC(18, 6)
			,dtmDeliveryDate DATETIME
			,strDiscountComment NVARCHAR(100)
			,dblInsuranceRate NUMERIC(18, 6)
			,dblStorageDue NUMERIC(18, 6)
			,dblStoragePaid NUMERIC(18, 6)
			,dblFeesDue NUMERIC(18, 6)
			,dblFeesPaid NUMERIC(18, 6)
			,dblDiscountsDue NUMERIC(18, 6)
			,dblDiscountsPaid NUMERIC(18, 6)
			,intDiscountScheduleId INT
			,intCurrencyId INT
	 )

	SELECT @UserName = strUserName	FROM tblSMUserSecurity	WHERE [intEntityId] = @UserKey

	IF @intConcurrencyId = 0 AND @intCustomerStorageId = 0
	BEGIN
		---NEW Mode
		INSERT INTO [dbo].[tblGRCustomerStorage] 
		(
			 [intConcurrencyId]
			,[intEntityId]
			,[intCommodityId]
			,[intStorageScheduleId]
			,[intStorageTypeId]
			,[intCompanyLocationId]
			,[intDiscountScheduleId]
			,[dblOriginalBalance]
			,[dblOpenBalance]
			,[dtmDeliveryDate]
			,[strDPARecieptNumber]
			,[dblStorageDue]
			,[dblStoragePaid]
			,[dblInsuranceRate]
			,[dblFeesDue]
			,[dblFeesPaid]
			,[strDiscountComment]
			,[dblDiscountsDue]
			,[dblDiscountsPaid]
			,[strCustomerReference]
			,[intCurrencyId]
			,[strStorageTicketNumber]
			,intItemId
			
		)
		SELECT 1
			,@intEntityId
			,@intCommodityId
			,@NewintStorageScheduleId
			,@intStorageTypeId
			,@intCompanyLocationId
			,@intDiscountScheduleId
			,@NewdblOriginalBalance
			,@NewdblOpenBalance
			,@NewdtmDeliveryDate
			,@NewstrDPARecieptNumber
			,@NewdblStorageDue
			,@NewdblStoragePaid
			,@NewdblInsuranceRate
			,@NewdblFeesDue
			,@NewdblFeesPaid
			,@NewstrDiscountComment
			,@NewdblDiscountsDue
			,@NewdblDiscountsPaid
			,@NewstrCustomerReference
			,@intCurrencyId
			,@intStorageTicketNumber
			,@intItemId
		

		SET @intCustomerStorageId = SCOPE_IDENTITY()

		--Discounts Part
		INSERT INTO tblQMTicketDiscount 
		(
			intConcurrencyId		
			,dblGradeReading
			,dblShrinkPercent
			,strShrinkWhat
			,dblDiscountDue
			,dblDiscountPaid
			,intDiscountScheduleCodeId
			,intTicketFileId
			,strSourceType
		)
		SELECT 1		
			,dblGradeReading
			,dblShrinkPercent
			,strShrinkWhat
			,dblDiscountDue
			,dblDiscountPaid
			,intDiscountScheduleCodeId
			,@intCustomerStorageId
			,'Storage'
		FROM OPENXML(@idoc, 'root/Discounts', 2) WITH 
		(
				strDiscountCode NVARCHAR(3)
				,strDiscountCodeDescription NVARCHAR(20)
				,dblGradeReading DECIMAL(7, 3)
				,dblShrinkPercent DECIMAL(7, 3)
				,strShrinkWhat NVARCHAR(50)
				,dblDiscountDue DECIMAL(18, 6)
				,dblDiscountPaid DECIMAL(18, 6)
				,intDiscountScheduleCodeId INT
		)

		--History
		INSERT INTO [dbo].[tblGRStorageHistory] 
		(
			[intConcurrencyId]
			,[intCustomerStorageId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[strPaidDescription]
			,[strType]
			,[strUserName]
		)
		SELECT 1
			,@intCustomerStorageId
			,@NewdblOpenBalance
			,GETDATE()
			,'Added by Storage Maintenance'
			,'NEW'
			,@UserName
	END
	ELSE
	BEGIN
		---EDIT Mode
		SELECT @OlddblOriginalBalance = dblOriginalBalance
			,@OlddblOpenBalance = dblOpenBalance
			,@OlddblInsuranceRate = dblInsuranceRate
			,@OlddblStorageDue = dblStorageDue
			,@OlddblStoragePaid = dblStoragePaid
			,@OlddblFeesDue = dblFeesDue
			,@OlddblFeesPaid = dblFeesPaid
			,@OlddblDiscountsDue = dblDiscountsDue
			,@OlddblDiscountsPaid = dblDiscountsPaid
		FROM tblGRCustomerStorage
		WHERE intCustomerStorageId = @intCustomerStorageId

		UPDATE tblGRCustomerStorage
		SET intCompanyLocationId = @intCompanyLocationId
			,intStorageScheduleId = @NewintStorageScheduleId
			,strDPARecieptNumber = @NewstrDPARecieptNumber
			,strCustomerReference = @NewstrCustomerReference
			,dblOriginalBalance = @NewdblOriginalBalance
			,dblOpenBalance = @NewdblOpenBalance
			,dtmDeliveryDate = @NewdtmDeliveryDate
			,strDiscountComment = @NewstrDiscountComment
			,dblInsuranceRate = @NewdblInsuranceRate
			,dblStorageDue = @NewdblStorageDue
			,dblStoragePaid = @NewdblStoragePaid
			,dblFeesDue = @NewdblFeesDue
			,dblFeesPaid = @NewdblFeesPaid
			,dblDiscountsDue = @NewdblDiscountsDue
			,dblDiscountsPaid = @NewdblDiscountsPaid			
		WHERE intCustomerStorageId = @intCustomerStorageId

		UPDATE a
		SET a.dblGradeReading = b.dblGradeReading
			,a.dblShrinkPercent = b.dblShrinkPercent
			,a.dblDiscountDue = b.dblDiscountDue
			,a.dblDiscountPaid = b.dblDiscountPaid
		FROM tblQMTicketDiscount a
		JOIN (
			SELECT strDiscountCode
				,strDiscountCodeDescription
				,dblGradeReading
				,dblShrinkPercent
				,strShrinkWhat
				,dblDiscountDue
				,dblDiscountPaid
				,intDiscountScheduleCodeId
			FROM OPENXML(@idoc, 'root/Discounts', 2) WITH (
					strDiscountCode NVARCHAR(3)
					,strDiscountCodeDescription NVARCHAR(20)
					,dblGradeReading DECIMAL(7, 3)
					,dblShrinkPercent DECIMAL(7, 3)
					,strShrinkWhat NVARCHAR(50)
					,dblDiscountDue DECIMAL(18, 6)
					,dblDiscountPaid DECIMAL(18, 6)
					,intDiscountScheduleCodeId INT
					)
			) b ON b.intDiscountScheduleCodeId = a.intDiscountScheduleCodeId
			AND a.intTicketFileId = @intCustomerStorageId

		--1.Orginal Balance adjustment
		IF @OlddblOriginalBalance <> @NewdblOriginalBalance
		BEGIN
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strPaidDescription]
				,[strType]
				,[strUserName]
			)
			SELECT 1
				,@intCustomerStorageId
				,(@NewdblOriginalBalance - @OlddblOriginalBalance)
				,GETDATE()
				,CASE 
					WHEN @NewdblOriginalBalance > @OlddblOriginalBalance
						THEN 'Original Units Increased'
					ELSE 'Original Units Decreased'
					END
				,'ADJUSTMENT'
				,@UserName
		END

		--2.Open Balance adjustment
		IF @OlddblOpenBalance <> @NewdblOpenBalance
		BEGIN
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strPaidDescription]
				,[strType]
				,[strUserName]
			)
			SELECT 1
				,@intCustomerStorageId
				,(@NewdblOpenBalance - @OlddblOpenBalance)
				,GETDATE()
				,CASE 
					WHEN @NewdblOpenBalance > @OlddblOpenBalance
						THEN 'Available Units Increased'
					ELSE 'Available Units Decreased'
					END
				,'ADJUSTMENT'
				,@UserName
		END

		--3.Insurance Rate Change		
		IF @OlddblInsuranceRate <> @NewdblInsuranceRate
		BEGIN
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strPaidDescription]
				,[strType]
				,[strUserName]
			)
			SELECT 1
				,@intCustomerStorageId
				,(@NewdblInsuranceRate - @OlddblInsuranceRate)
				,GETDATE()
				,'Insurance Rate changed from ' + LTRIM(@OlddblInsuranceRate)
				,'ADJUSTMENT'
				,@UserName
		END

		--4.Storage Due Adjustment		
		IF @OlddblStorageDue <> @NewdblStorageDue
		BEGIN
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strPaidDescription]
				,[strType]
				,[strUserName]
			)
			SELECT 1
				,@intCustomerStorageId
				,(@NewdblStorageDue - @OlddblStorageDue)
				,GETDATE()
				,'Storage Due Adjustment'
				,'ADJUSTMENT'
				,@UserName
		END

		--5.Storage Paid Adjustment				
		IF @OlddblStoragePaid <> @NewdblStoragePaid
		BEGIN
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strPaidDescription]
				,[strType]
				,[strUserName]
			)
			SELECT 1
				,@intCustomerStorageId
				,(@NewdblStoragePaid - @OlddblStoragePaid)
				,GETDATE()
				,'Storage Paid Adjustment'
				,'ADJUSTMENT'
				,@UserName
		END

		--6.Fees Due Adjustment
		IF @OlddblFeesDue <> @NewdblFeesDue
		BEGIN
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strPaidDescription]
				,[strType]
				,[strUserName]
			)
			SELECT 1
				,@intCustomerStorageId
				,(@NewdblFeesDue - @OlddblFeesDue)
				,GETDATE()
				,'Fees Due Adjustment'
				,'ADJUSTMENT'
				,@UserName
		END

		--7.Fees Paid Adjustment
		IF @OlddblFeesPaid <> @NewdblFeesPaid
		BEGIN
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strPaidDescription]
				,[strType]
				,[strUserName]
			)
			SELECT 1
				,@intCustomerStorageId
				,(@NewdblFeesPaid - @OlddblFeesPaid)
				,GETDATE()
				,'Fees Paid Adjustment'
				,'ADJUSTMENT'
				,@UserName
		END

		--8.Discount Due Adjustment
		IF @OlddblDiscountsDue <> @NewdblDiscountsDue
		BEGIN
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strPaidDescription]
				,[strType]
				,[strUserName]
			)
			SELECT 1
				,@intCustomerStorageId
				,(@NewdblDiscountsDue - @OlddblDiscountsDue)
				,GETDATE()
				,'Discount Due Adjustment'
				,'ADJUSTMENT'
				,@UserName
		END

		--9.Discount Paid Adjustment
		IF @OlddblDiscountsPaid <> @NewdblDiscountsPaid
		BEGIN
			INSERT INTO [dbo].[tblGRStorageHistory] 
			(
				[intConcurrencyId]
				,[intCustomerStorageId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strPaidDescription]
				,[strType]
				,[strUserName]
			)
			SELECT 1
				,@intCustomerStorageId
				,(@NewdblDiscountsPaid - @OlddblDiscountsPaid)
				,GETDATE()
				,'Discount Paid Adjustment'
				,'ADJUSTMENT'
				,@UserName
		END
	END

	DECLARE @intItemLocationId INT

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intItemId = @intItemId
		AND intLocationId = @intCompanyLocationId

	--NEW MODE Yes
	IF @intConcurrencyId = 0 AND @ysnUpdateHouseTotal = 1
	BEGIN
		IF NOT EXISTS ( SELECT 1 FROM tblICItemStock WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId)
		BEGIN
			INSERT INTO tblICItemStock 
			(
				intItemId
				,intItemLocationId
				,dblUnitStorage
				,intConcurrencyId
			)
			SELECT @intItemId
				,@intItemLocationId
				,@NewdblOpenBalance
				,1
		END
		ELSE
		BEGIN
			UPDATE tblICItemStock
			SET dblUnitStorage = dblUnitStorage + @NewdblOpenBalance
			WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId
		END
	END
			--NEW MODE NO
	ELSE IF @intConcurrencyId = 0 AND @ysnUpdateHouseTotal = 0
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM tblICItemStock WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId)
		BEGIN
			INSERT INTO tblICItemStock 
			(
				intItemId
				,intItemLocationId
				,dblUnitStorage
				,dblUnitOnHand
				,intConcurrencyId
			)
			SELECT @intItemId
				,@intItemLocationId
				,@NewdblOpenBalance
				,-@NewdblOpenBalance
				,1
		END
		ELSE
		BEGIN
			UPDATE tblICItemStock
			SET dblUnitStorage = dblUnitStorage + @NewdblOpenBalance
				,dblUnitOnHand = dblUnitOnHand - @NewdblOpenBalance
			WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId
		END
	END
			--Edit Mode Yes
	ELSE IF @intConcurrencyId > 0 AND @ysnUpdateHouseTotal = 1 AND (@NewdblOpenBalance < > @OlddblOpenBalance)
	BEGIN
		UPDATE tblICItemStock
		SET dblUnitStorage = dblUnitStorage + (@NewdblOpenBalance - @OlddblOpenBalance)
		WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId
	END
			--Edit Mode No
	ELSE IF @intConcurrencyId > 0 AND @ysnUpdateHouseTotal = 0 AND (@NewdblOpenBalance < > @OlddblOpenBalance)
	BEGIN
		UPDATE tblICItemStock
		SET dblUnitStorage = dblUnitStorage + (@NewdblOpenBalance - @OlddblOpenBalance)
			,dblUnitOnHand = dblUnitOnHand - (@NewdblOpenBalance - @OlddblOpenBalance)
		WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId
	END

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH