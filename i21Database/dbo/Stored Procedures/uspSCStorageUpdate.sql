CREATE PROCEDURE [dbo].[uspSCStorageUpdate]
	 @intTicketId AS INT
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (13,3)
	,@intEntityId AS INT
	,@strDistributionOption AS NVARCHAR(3)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intCustomerStorageId AS INT
DECLARE @ysnAddDiscount BIT
DECLARE @intHoldCustomerStorageId AS INT
DECLARE @intGRStorageId AS INT
DECLARE @intScaleStationId AS INT
DECLARE @strGRStorage AS nvarchar(3)

BEGIN 
	SELECT @intScaleStationId = SC.intScaleSetupId
	FROM	dbo.tblSCTicket SC	        
	WHERE	SC.intTicketId = @intTicketId		
END

BEGIN 
	SELECT	@intGRStorageId = ST.intStorageScheduleTypeId
	FROM	dbo.tblGRStorageType ST	        
	WHERE	ST.strStorageTypeCode = @strDistributionOption		
END

IF @intGRStorageId is NULL
BEGIN
   	SELECT	@intGRStorageId = ST.intDefaultStorageTypeId
	FROM	dbo.tblSCScaleSetup ST	        
	WHERE	ST.intScaleSetupId = @intScaleStationId
END

IF @intGRStorageId IS NULL 
BEGIN 
	-- Raise the error:
	RAISERROR('Invalid Default Storage Setup - uspSCStorageUpdate', 16, 1);
	RETURN;
END

-- Insert the Customer Storage Record 
INSERT INTO [dbo].[tblGRCustomerStorage]
           ([intConcurrencyId]
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
           ,[dblCurrencyRate])
SELECT 	[intConcurrencyId]		= 1
		,[intEntityId]			= @intEntityId
		,[intCommodityId]		= SC.intCommodityId
		,[intStorageScheduleId]	= NULL -- TODO Storage Schedule
		,[intStorageTypeId]		= @intGRStorageId
		,[intCompanyLocationId]= SC.intProcessingLocationId
		,[intTicketId]= SC.intTicketId
		,[intDiscountScheduleId]= SC.intDiscountSchedule
		,[dblTotalPriceShrink]= 0
		,[dblTotalWeightShrink]= 0 
		,[dblOriginalBalance]= @dblNetUnits 
		,[dblOpenBalance]= @dblNetUnits
		,[dtmDeliveryDate]= NULL
		,[dtmZeroBalanceDate]= NULL
		,[strDPARecieptNumber]= NULL
		,[dtmLastStorageAccrueDate]= NULL 
		,[dblStorageDue]= NULL 
		,[dblStoragePaid]= 0
		,[dblInsuranceRate]= 0 
		,[strOriginState]= NULL 
		,[strInsuranceState]= NULL
		,[dblFeesDue]= 0 
		,[dblFeesPaid]= 0 
		,[dblFreightDueRate]= 0 
		,[ysnPrinted]= 0 
		,[dblCurrencyRate]= 1 
FROM	dbo.tblSCTicket SC
WHERE	SC.intTicketId = @intTicketId

-- Get the identity value from tblGRCustomerStorage
SELECT @intCustomerStorageId = SCOPE_IDENTITY()

IF @intCustomerStorageId IS NULL 
BEGIN 
	-- Raise the error:
	RAISERROR('Unable to get Identity value from Customer Storage', 16, 1);
	RETURN;
END

BEGIN
	select @intHoldCustomerStorageId = SD.intCustomerStorageId from tblGRStorageDiscount SD 
	where intCustomerStorageId = @intCustomerStorageId
END

if @intHoldCustomerStorageId is NULL
BEGIN
	INSERT INTO [dbo].[tblGRStorageDiscount]
           ([intConcurrencyId]
           ,[intCustomerStorageId]
           ,[strDiscountCode]
           ,[dblGradeReading]
           ,[strCalcMethod]
           ,[dblDiscountAmount]
           ,[strShrinkWhat]
           ,[dblShrinkPercent]
           ,[dblDiscountDue]
           ,[dblDiscountPaid]
           ,[dtmDiscountPaidDate])
	SELECT	 [intConcurrencyId]= 1
		,[intCustomerStorageId]= @intCustomerStorageId
		,[strDiscountCode]= SD.strDiscountCode
		,[dblGradeReading]= SD.dblGradeReading
		,[strCalcMethod]= SD.strCalcMethod
		,[dblDiscountAmount]= SD.dblDiscountAmount
		,[strShrinkWhat]= SD.strShrinkWhat
		,[dblShrinkPercent]= SD.dblShrinkPercent
		,[dblDiscountDue]= SD.dblDiscountAmount
		,[dblDiscountPaid]=	0
		,[dtmDiscountPaidDate] = NULL
	FROM	dbo.tblSCTicketDiscount SD
	WHERE	SD.intTicketId = @intTicketId
END


