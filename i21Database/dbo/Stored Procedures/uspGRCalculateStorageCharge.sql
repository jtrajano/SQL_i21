CREATE PROCEDURE [dbo].[uspGRCalculateStorageCharge]  
    @intCustomerStorageId INT  
   ,@strProcessType Nvarchar(30)  
   ,@StorageChargeDate DATETIME = NULL   
   ,@UserKey INT  
   ,@dblStorageDuePerUnit DECIMAL(24, 10) OUTPUT  
   ,@dblStorageDueAmount DECIMAL(24, 10) OUTPUT  
   ,@dblStorageDueTotalPerUnit DECIMAL(24, 10) OUTPUT  
   ,@dblStorageDueTotalAmount DECIMAL(24, 10) OUTPUT  
   ,@dblStorageBilledPerUnit DECIMAL(24, 10) OUTPUT  
   ,@dblStorageBilledAmount DECIMAL(24, 10) OUTPUT  
AS  
BEGIN TRY  
 SET NOCOUNT ON  
  
 IF @StorageChargeDate IS NULL  
  SET @StorageChargeDate = GETDATE()  
  
 DECLARE @ErrMsg NVARCHAR(MAX)  
 DECLARE @UserName NVARCHAR(100)   
 DECLARE @dblOldStoragePaid DECIMAL(24, 10)  
 DECLARE @dblOpenBalance DECIMAL(24, 10)  
 DECLARE @intStorageScheduleId INT  
 DECLARE @strStorageRate NVARCHAR(50)  
 DECLARE @dtmHEffectiveDate DATETIME  
 DECLARE @dtmTerminationDate DATETIME  
 DECLARE @dtmDeliveryDate DATETIME  
 DECLARE @dtmLastStorageAccrueDate DATETIME  
   
 DECLARE @intSchedulePeriodId INT  
 DECLARE @strPeriodType NVARCHAR(50)  
 DECLARE @dtmDEffectiveDate DATETIME  
 DECLARE @dtmEndingDate DATETIME  
 DECLARE @intNumberOfDays INT  
 DECLARE @dblStorageRate DECIMAL(24, 10)  
  
 DECLARE @dblNewStoragePaid DECIMAL(24, 10)  
 DECLARE @TotalDaysApplicableForStorageCharge INT  
 DECLARE @StorageChargeCalculationRequired BIT=1  
   
 DECLARE @tblGRStorageSchedulePeriod AS TABLE   
 (  
  [intSchedulePeriodId] INT IDENTITY(1, 1),  
  [strPeriodType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL,   
  [dtmEffectiveDate] DATETIME NULL,   
  [dtmEndingDate] DATETIME NULL,   
  [intNumberOfDays] INT NULL ,   
  [dblStorageRate] NUMERIC(18, 6)  
 )  
   
 SELECT   
    @dblOldStoragePaid=CS.dblStoragePaid  
   ,@dblOpenBalance=CS.dblOpenBalance  
  ,@intStorageScheduleId = CS.intStorageScheduleId  
  ,@strStorageRate = SR.strStorageRate  
  ,@dtmHEffectiveDate = SR.dtmEffectiveDate  
  ,@dtmTerminationDate = SR.dtmTerminationDate  
  ,@dtmDeliveryDate = CS.dtmDeliveryDate  
  ,@dtmLastStorageAccrueDate = CS.dtmLastStorageAccrueDate  
 FROM tblGRCustomerStorage CS  
 JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId  
 WHERE CS.intCustomerStorageId = @intCustomerStorageId  
   
   
 INSERT INTO @tblGRStorageSchedulePeriod   
 (  
   [strPeriodType]  
  ,[dtmEffectiveDate]  
  ,[dtmEndingDate]  
  ,[intNumberOfDays]  
  ,[dblStorageRate]    
 )  
 SELECT   
   [strPeriodType]  
  ,[dtmEffectiveDate]  
  ,[dtmEndingDate]  
  ,[intNumberOfDays]  
  ,[dblStorageRate]  
  FROM  tblGRStorageSchedulePeriod Where intStorageScheduleRule=@intStorageScheduleId Order by intSort  
   
  --Suppose Termination Date is not Blank and Storage Charge Date is later on Termination Date then Charge Upto Termination Date.  
  IF @StorageChargeDate > @dtmTerminationDate AND @dtmTerminationDate IS NOT NULL  
   SET @StorageChargeDate=@dtmTerminationDate  
       
  --Suppose Effective Date is not blank and Delivery Date is Prior to Effective Date then Charge From Effective Date.   
  IF @dtmDeliveryDate < @dtmHEffectiveDate AND @dtmHEffectiveDate IS NOT NULL   
   SET @dtmDeliveryDate=@dtmHEffectiveDate  
     
  --Suppose Storage Due is atleast once Accured then Storage Charge should be accrued from the Most recent Accured date.  
  IF @dtmLastStorageAccrueDate IS NOT NULL  
   SET @dtmDeliveryDate=@dtmLastStorageAccrueDate+1  
     
  SELECT @UserName = strUserName FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserKey  
    
  --Suppose Storage Charge is accrued for a Particular date and User is again trying to Accure Storage Charge past to the Paricular Date then return zero.  
    
  IF EXISTS(SELECT 1 FROM tblGRCustomerStorage Where intCustomerStorageId = @intCustomerStorageId AND dtmLastStorageAccrueDate IS NOT NULL AND (dtmLastStorageAccrueDate >@StorageChargeDate)) OR (@StorageChargeDate < @dtmDeliveryDate)  
  BEGIN  
   SET @dblStorageDuePerUnit =0  
   SET @dblStorageDueAmount=0  
   SET @StorageChargeCalculationRequired=0  
  END  
  
  IF @strProcessType='Unpaid'  
  BEGIN  
   SET @StorageChargeCalculationRequired=0  
  END  
    
  SELECT @TotalDaysApplicableForStorageCharge=DATEDIFF(DAY, @dtmDeliveryDate,@StorageChargeDate)+1  
    
  IF  @strStorageRate = 'Daily' AND @StorageChargeCalculationRequired=1    
  BEGIN  
   SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)  
   FROM @tblGRStorageSchedulePeriod  
     
   SET @strPeriodType = NULL  
   SET @dtmDEffectiveDate = NULL  
   SET @dtmEndingDate=NULL  
   SET @intNumberOfDays = NULL  
   SET @dblStorageRate = NULL  
     
   WHILE @intSchedulePeriodId > 0 AND @TotalDaysApplicableForStorageCharge > 0  
   BEGIN  
    SELECT @strPeriodType = strPeriodType  
     ,@dtmDEffectiveDate = dtmEffectiveDate  
     ,@dtmEndingDate=dtmEndingDate  
     ,@intNumberOfDays = ISNULL(intNumberOfDays,0)  
     ,@dblStorageRate=dblStorageRate  
    FROM @tblGRStorageSchedulePeriod  
    WHERE intSchedulePeriodId = @intSchedulePeriodId  
      
    IF @strPeriodType='Thereafter'  
    BEGIN  
     SET @dblStorageDuePerUnit =@dblStorageRate *(DATEDIFF(DAY, @dtmDeliveryDate,@StorageChargeDate)+1)  
     SET @dblStorageDueAmount=@dblStorageDuePerUnit*@dblOpenBalance  
     SET @TotalDaysApplicableForStorageCharge=@TotalDaysApplicableForStorageCharge - (DATEDIFF(DAY, @dtmDeliveryDate,@StorageChargeDate)+1)     
    END  
       
    SELECT @intSchedulePeriodId = MIN(intSchedulePeriodId)  
    FROM @tblGRStorageSchedulePeriod Where intSchedulePeriodId >@intSchedulePeriodId     
   
   END  
     
    
  END  
    
    
  ---Updating Last Storage AccrueDate, Storage Due Field and Creating History.  
  IF @StorageChargeCalculationRequired=1  
  BEGIN    
     
   IF @strProcessType='accrue' OR @strProcessType='Bill'  
   BEGIN  
  
    Update tblGRCustomerStorage SET dtmLastStorageAccrueDate=@StorageChargeDate   
    Where intCustomerStorageId=@intCustomerStorageId  
     
    Update tblGRCustomerStorage SET dblStorageDue=dblStorageDue+ @dblStorageDuePerUnit  
    Where intCustomerStorageId=@intCustomerStorageId  
  
    INSERT INTO [dbo].[tblGRStorageHistory]   
       (  
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
       )  
      VALUES   
         (  
        1  
       ,@intCustomerStorageId  
       ,NULL  
       ,NULL  
       ,NULL  
       ,NULL  
       ,NULL  
       ,@StorageChargeDate  
       ,@dblStorageDuePerUnit  
       ,NULL  
       ,NULL  
       ,'Accrued Storage Due'  
       ,@UserName  
       ,NULL  
       ,NULL  
       ,NULL  
        )   
  
   END  
     
  END   
  
  IF @strProcessType='Bill'  
  BEGIN  
  
   Update tblGRCustomerStorage SET dblStoragePaid=dblStorageDue Where intCustomerStorageId=@intCustomerStorageId  
  
   SELECT @dblNewStoragePaid=dblStoragePaid FROM tblGRCustomerStorage Where intCustomerStorageId=@intCustomerStorageId  
  
   INSERT INTO [dbo].[tblGRStorageHistory]   
      (  
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
      )  
     VALUES   
      (  
       1  
      ,@intCustomerStorageId  
      ,NULL  
      ,NULL  
      ,NULL  
      ,NULL  
      ,NULL  
      ,@StorageChargeDate  
      ,(@dblNewStoragePaid-@dblOldStoragePaid)  
      ,NULL  
      ,NULL  
      ,'Storage Paid'  
      ,@UserName  
      ,NULL  
      ,NULL  
      ,NULL  
      )      
  END  
     
               
  SELECT @dblStorageDueTotalPerUnit=dblStorageDue-dblStoragePaid  
    ,@dblStorageBilledPerUnit=dblStoragePaid-@dblOldStoragePaid   
    FROM tblGRCustomerStorage  
    Where intCustomerStorageId=@intCustomerStorageId  
      
  IF @strProcessType='Unpaid'  
  BEGIN  
   SET @dblStorageDuePerUnit=@dblStorageDueTotalPerUnit      
   SET @dblStorageDueAmount= @dblStorageDuePerUnit*@dblOpenBalance  
  END  
    
    
      
  SELECT @dblStorageDueTotalAmount=@dblStorageDueTotalPerUnit * @dblOpenBalance  
  SELECT @dblStorageBilledAmount=@dblStorageBilledPerUnit * @dblOpenBalance  
  
END TRY  
  
BEGIN CATCH  
  
 SET @ErrMsg = ERROR_MESSAGE()  
 SET @ErrMsg = 'uspGRCalculateStorageCharge: ' + @ErrMsg  
 RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
   
END CATCH