CREATE FUNCTION [dbo].[fnGRGetBillStorageDetails]
(	
	@dtmStorageChargeDate DATETIME	
	,@strPostType NVARCHAR(30)
	,@intUserId INT
	,@intEntityId INT = NULL
	,@intCustomerStorageIdParam INT = NULL
	,@dblBalanceToAccrue DECIMAL(18,6) = 0
)
RETURNS @returnTable TABLE
(
	 [intBillStorageKey]			INT
	,[intCustomerStorageId]			INT					NOT NULL
	,[strStorageTicketNumber]		NVARCHAR(50)		NULL
	,[intEntityId]					INT					NULL
	,[strName]						NVARCHAR(100)		NULL
	,[intItemId]					INT					NULL
	,[strItemNo]					NVARCHAR(100)		NULL
	,[intCompanyLocationId]			INT					NULL
	,[strLocationName]				NVARCHAR(100)		NULL	
	,[dblOpenBalance]				DECIMAL(18,6)		NOT NULL	DEFAULT 0
	,[dblUnpaid]					DECIMAL(18,6)		NOT NULL	DEFAULT 0
	,[intStorageTypeId]				INT					NULL
	,[strStorageTypeDescription]	NVARCHAR(30)		NULL
	,[intStorageScheduleId]			INT					NULL
	,[strScheduleDescription]		NVARCHAR(50)		NULL
	,[dtmDeliveryDate]				DATETIME			NULL
	,[dtmLastStorageAccrueDate]		DATETIME			NULL
	,[dblOldStorageDue]				DECIMAL(18,6)		NOT NULL	DEFAULT 0
	,[dblAdditionalCharge]			DECIMAL(18,6)		NOT NULL	DEFAULT 0
	,[dblNewStorageDue]				DECIMAL(18,6)		NOT NULL	DEFAULT 0
	,[dblOldStorageBilled]			DECIMAL(18,6)		NOT NULL	DEFAULT 0
	,[dblNewStorageBilled]			DECIMAL(18,6)		NOT NULL	DEFAULT 0
	,[dblStorageDueAmount]			DECIMAL(18,6)		NOT NULL	DEFAULT 0
	,[dblFlatFeeTotal]				DECIMAL(18,6)		NOT NULL	DEFAULT 0
)
AS
BEGIN
	DECLARE @intBillStorageKey INT	
	DECLARE @intCustomerStorageId INT
	DECLARE @intStorageScheduleId INT
	DECLARE @dblOpenBalance DECIMAL(38,20)
	DECLARE @dblAdditionalCharge DECIMAL(18,6)
	DECLARE @dblNewStorageDue DECIMAL(18,6)
	DECLARE @dblNewStorageBilled DECIMAL(18,6)
	DECLARE @dblStorageDueAmount DECIMAL(18,6)
	DECLARE @dblFlatFeeTotal DECIMAL(18,6)
	DECLARE @StorageSchedulePeriods StorageSchedulePeriodTableType

	DECLARE @BillStorageValues AS TABLE 
	(
		[intBillStorageKey]				INT IDENTITY(1, 1)
		,[intCustomerStorageId]			INT
		,[intStorageScheduleId]			INT
		,[dblOpenBalance]				DECIMAL(38,20)		NOT NULL DEFAULT 0
		,[dblStorageDuePerUnit]			DECIMAL(18,6)		NOT NULL DEFAULT 0
		,[dblStorageDueAmount]			DECIMAL(18,6)		NOT NULL DEFAULT 0
		,[dblStorageDueTotalPerUnit]	DECIMAL(18,6)		NOT NULL DEFAULT 0
		,[dblStorageDueTotalAmount]		DECIMAL(18,6)		NOT NULL DEFAULT 0
		,[dblStorageBilledPerUnit]		DECIMAL(18,6)		NOT NULL DEFAULT 0		
		,[dblStorageBilledAmount]		DECIMAL(18,6)		NOT NULL DEFAULT 0			
    	,[dblFlatFeeTotal]				DECIMAL(18,6)		NOT NULL DEFAULT 0				
	)

	DECLARE @tmpBillStorageValues AS TABLE
	(
		[intCustomerStorageId]			INT
		,[intStorageScheduleId]			INT
		,[dblOpenBalance]				DECIMAL(38,20)		NOT NULL DEFAULT 0
		,[dblStorageDuePerUnit]			DECIMAL(18,6)		NOT NULL DEFAULT 0
		,[dblStorageDueAmount]			DECIMAL(18,6)		NOT NULL DEFAULT 0
		,[dblStorageDueTotalPerUnit]	DECIMAL(18,6)		NOT NULL DEFAULT 0
		,[dblStorageDueTotalAmount]		DECIMAL(18,6)		NOT NULL DEFAULT 0
		,[dblStorageBilledPerUnit]		DECIMAL(18,6)		NOT NULL DEFAULT 0		
		,[dblStorageBilledAmount]		DECIMAL(18,6)		NOT NULL DEFAULT 0			
    	,[dblFlatFeeTotal]				DECIMAL(18,6)		NOT NULL DEFAULT 0
	)
	
	INSERT INTO @tmpBillStorageValues
	SELECT 
		CS.intCustomerStorageId
		,CS.intStorageScheduleId
		,CASE WHEN @dblBalanceToAccrue = 0 THEN CS.dblOpenBalance ELSE @dblBalanceToAccrue END
		,0
		,0
		,0
		,0
		,0
		,0
		,0
	FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageType ST
		ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
	WHERE CS.dblOpenBalance > 0
		AND ST.ysnCustomerStorage = 0
		AND CS.intCustomerStorageId = ISNULL(@intCustomerStorageIdParam,CS.intCustomerStorageId)
	ORDER BY CS.dtmDeliveryDate

	--SELECT @intBillStorageKey = MIN(intBillStorageKey)
	--FROM @BillStorageValues

	WHILE EXISTS(SELECT TOP 1 1 FROM @tmpBillStorageValues)
	BEGIN
		BEGIN
			SET @intCustomerStorageId = NULL
			SET @intStorageScheduleId = NULL
			SET @dblOpenBalance = NULL
			SET @dblAdditionalCharge = NULL
			SET @dblNewStorageDue = NULL
			SET @dblNewStorageBilled = NULL
			SET @dblStorageDueAmount = NULL
			SET @dblFlatFeeTotal = NULL

			SELECT TOP 1
				@intCustomerStorageId	= intCustomerStorageId
				,@intStorageScheduleId	= intStorageScheduleId
				,@dblOpenBalance		= dblOpenBalance
			FROM @tmpBillStorageValues

			DELETE FROM @StorageSchedulePeriods

			INSERT INTO @StorageSchedulePeriods
			SELECT 
				[intPeriodNumber]	= RANK() OVER (ORDER BY intSort)
				,[strPeriodType]	
				,[dtmStartDate]		= dtmEffectiveDate	
				,[dtmEndingDate]
				,[intNumberOfDays]
				,[dblStorageRate]
				,[dblFeeRate]		
				,[strFeeType]
			FROM tblGRStorageSchedulePeriod
			WHERE intStorageScheduleRule = @intStorageScheduleId
			ORDER BY intSort

			UPDATE SV
			SET SV.dblStorageDuePerUnit			= SC.dblStorageDuePerUnit
				,SV.dblStorageDueAmount			= SC.dblStorageDueAmount
				,SV.dblStorageDueTotalPerUnit	= SC.dblStorageDueTotalPerUnit
				,SV.dblStorageDueTotalAmount	= SC.dblStorageDueTotalAmount
				,SV.dblStorageBilledPerUnit		= SC.dblStorageBilledPerUnit
				,SV.dblStorageBilledAmount		= SC.dblStorageBilledAmount
				,SV.dblFlatFeeTotal				= ISNULL(SC.dblFlatFeeTotal,0)
			FROM @tmpBillStorageValues SV
			INNER JOIN [dbo].[fnGRCalculateStorageCharge](@intCustomerStorageId, @dblOpenBalance, @dtmStorageChargeDate, @StorageSchedulePeriods) SC
				ON SV.intCustomerStorageId = SC.intCustomerStorageId
			WHERE SV.intCustomerStorageId = @intCustomerStorageId

			INSERT INTO @BillStorageValues
			SELECT * FROM @tmpBillStorageValues
			WHERE intCustomerStorageId = @intCustomerStorageId

			DELETE FROM @tmpBillStorageValues 
			WHERE intCustomerStorageId = @intCustomerStorageId
		END
	END

	INSERT INTO @returnTable
	SELECT
		SV.intBillStorageKey
		,CS.intCustomerStorageId
		,CS.strStorageTicketNumber
		,CS.intEntityId
		,EM.strName
		,CS.intItemId
		,IC.strItemNo
		,CS.intCompanyLocationId
		,CL.strLocationName
		,CS.dblOpenBalance
		,dblUnpaid = SV.dblStorageDueTotalPerUnit --Unpaid Storage (storage due from storage screen; storage due - storage paid)
		,CS.intStorageTypeId
		,ST.strStorageTypeDescription
		,CS.intStorageScheduleId
		,SR.strScheduleDescription
		,CS.dtmDeliveryDate
		,CS.dtmLastStorageAccrueDate
		,dblOldStorageDue = ISNULL(CS.dblStorageDue,0)
		,dblAdditionalCharge = SV.dblStorageDuePerUnit --Additional Charge (computed)
		,dblNewStorageDue = SV.dblStorageDueTotalPerUnit + SV.dblStorageDuePerUnit --New Storage Due (unpaid + additional)
		,dblOldStorageBilled = ISNULL(CS.dblStoragePaid,0) --Old Storage Billed (storage due paid)
		,dblNewStorageBilled = ISNULL(CS.dblStoragePaid,0) + SV.dblStorageDuePerUnit --New Storage Billed (storage paid + additional charge)
		,dblStorageDueAmount = ((SV.dblStorageDueTotalPerUnit + SV.dblStorageDuePerUnit) * CS.dblOpenBalance) + SV.dblFlatFeeTotal --Storage Due Amount ((units x additional storage) + flat fee)
		,SV.dblFlatFeeTotal
	FROM tblGRCustomerStorage CS
	INNER JOIN @BillStorageValues SV
		ON SV.intCustomerStorageId = CS.intCustomerStorageId
	INNER JOIN tblEMEntity EM
		ON EM.intEntityId = CS.intEntityId
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = CS.intCompanyLocationId
	INNER JOIN tblGRStorageType ST
		ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
	INNER JOIN tblGRStorageScheduleRule SR
		ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
	INNER JOIN tblICItem IC
		ON IC.intItemId = CS.intItemId	
	WHERE CS.intEntityId = CASE WHEN @intEntityId > 0 THEN @intEntityId ELSE CS.intEntityId END
		AND ((ISNULL(CS.dblStorageDue,0) - ISNULL(CS.dblStoragePaid,0)) + SV.dblStorageDuePerUnit) > 0
	ORDER BY EM.strName, CL.strLocationName		

	RETURN;
END