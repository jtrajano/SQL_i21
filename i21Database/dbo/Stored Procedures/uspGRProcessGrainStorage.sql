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
	DECLARE @strProcessType Nvarchar(30)
	DECLARE @strUpdateType NVARCHAR(30)
	DECLARE @intBillDiscountKey INT
	
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)	
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	DECLARE @BillDiscounts AS TABLE 
	(
		 intBillDiscountKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,intEntityId INT
		,intCompanyLocationId INT
		,intStorageTypeId INT
		,intStorageScheduleId INT
		,dblOpenBalance DECIMAL(24,10)
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
	
	IF @strPostType='Calculate Test'
	BEGIN
		SET @strProcessType='calculate'
		SET @strUpdateType='estimate'
	END
	ELSE IF @strPostType='Accrue Storage'
	BEGIN
		SET @strProcessType='calculate'
		SET @strUpdateType='accrue'
	END
	ELSE IF @strPostType='Bill Storage'
	BEGIN
		SET @strProcessType='calculate'
		SET @strUpdateType='Bill'
	END
	ELSE IF @strPostType='Recalculate and Accrue'
	BEGIN
		SET @strProcessType='recalculate'
		SET @strUpdateType='accrue'
	END
	
	INSERT INTO @BillDiscounts 
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
	FROM OPENXML(@idoc, 'root/billstorage', 2) WITH 
	(
			 intCustomerStorageId INT
			,intEntityId INT
			,intCompanyLocationId INT
			,intStorageTypeId INT
			,intStorageScheduleId INT
			,dblOpenBalance DECIMAL(24,10)
	)
	
	SELECT @intBillDiscountKey = MIN(intBillDiscountKey)
	FROM @BillDiscounts	
	WHILE @intBillDiscountKey > 0
	BEGIN
		    SET @intCustomerStorageId = NULL
			SELECT @intCustomerStorageId = intCustomerStorageId			
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
		 ,'Process Grain Storage'
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
	EXEC sp_xml_removedocument @idoc
	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()	 
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH