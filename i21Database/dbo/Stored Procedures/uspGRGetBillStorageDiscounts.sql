CREATE PROCEDURE [dbo].[uspGRGetBillStorageDiscounts]
 @StorageChargeDate DATETIME	
,@PostType NVARCHAR(30)
,@UserKey INT
,@PortalEntityId INT
AS
BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strProcessType NVARCHAR(30)
	DECLARE @strUpdateType NVARCHAR(30)
	DECLARE @intTicketKey INT
	DECLARE @intCustomerStorageId INT
	
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)	
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	
	DECLARE @tblStorageTickets AS TABLE 
	(
	  intTicketKey INT IDENTITY(1, 1)
	 ,intCustomerStorageId INT		
	)
	
	DECLARE @BillStorageDiscounts AS TABLE 
	(
	  intBillStorageKey INT IDENTITY(1, 1)
	 ,intCustomerStorageId INT
	 ,dblAdditionalCharge DECIMAL(24,10)
	 ,dblNewStorageDue DECIMAL(24,10)
	 ,dblNewStorageBilled DECIMAL(24,10)
	 ,dblStorageDueAmount  DECIMAL(24,10)		
	)

	SET @strUpdateType='estimate'
	SET @strProcessType=CASE WHEN @PostType='Recalculate and Accrue' THEN 'recalculate' ELSE 'calculate'END
		
	INSERT INTO @tblStorageTickets(intCustomerStorageId)
	SELECT a.intCustomerStorageId
	FROM tblGRCustomerStorage a  
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
	Where 
	ISNULL(a.strStorageType,'') <> 'ITR' 
	AND b.ysnCustomerStorage=0  
	AND a.dblOpenBalance >0
	ORDER BY a.dtmDeliveryDate
	
		SELECT @intTicketKey = MIN(intTicketKey)
		FROM @tblStorageTickets		
		
		WHILE @intTicketKey > 0 
		BEGIN
		    SET @intCustomerStorageId=NULL
	    	SET @dblStorageDuePerUnit = NULL
			SET @dblStorageDueAmount = NULL
			SET @dblStorageDueTotalPerUnit = NULL
			SET @dblStorageDueTotalAmount = NULL
			SET @dblStorageBilledPerUnit = NULL
			SET @dblStorageBilledAmount = NULL
		    
		    SELECT @intCustomerStorageId=intCustomerStorageId FROM @tblStorageTickets
			WHERE intTicketKey = @intTicketKey
			
			  EXEC 
			  uspGRCalculateStorageCharge
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
			 
			 INSERT INTO @BillStorageDiscounts(intCustomerStorageId,dblAdditionalCharge,dblNewStorageDue,dblNewStorageBilled,dblStorageDueAmount)
			 SELECT @intCustomerStorageId,@dblStorageDuePerUnit,@dblStorageDuePerUnit,@dblStorageDuePerUnit,@dblStorageDuePerUnit
			 
			SELECT @intTicketKey = MIN(intTicketKey)
			FROM @tblStorageTickets
			WHERE intTicketKey > @intTicketKey
	
		END	
		
	  SELECT  
	  bill.intBillStorageKey
	 ,a.intCustomerStorageId
	 ,a.intEntityId  
	 ,E.strName    
	 ,a.intItemId
	 ,Item.strItemNo  
	 ,a.intCompanyLocationId  
	 ,c.strLocationName 
	 ,a.strStorageTicketNumber  
	 ,a.dblOpenBalance
	 ,(ISNULL(a.dblStorageDue,0)-ISNULL(a.dblStoragePaid,0)) dblUnpaid   
	 ,a.intStorageTypeId  
	 ,b.strStorageTypeDescription
	 ,a.intStorageScheduleId
	 ,SR.strScheduleId
	 ,a.dtmDeliveryDate
	 ,a.dtmLastStorageAccrueDate
	 ,ISNULL(a.dblStorageDue,0) dblOldStorageDue
	 ,ISNULL(bill.dblAdditionalCharge,0) dblAdditionalCharge
	 ,(ISNULL(a.dblStorageDue,0)-ISNULL(a.dblStoragePaid,0))+ISNULL(bill.dblAdditionalCharge,0) AS dblNewStorageDue
	 ,ISNULL(a.dblStoragePaid,0) dblOldStorageBilled
	 ,CASE WHEN @PostType='Bill Storage' THEN (a.dblStoragePaid+bill.dblAdditionalCharge) ELSE a.dblStoragePaid END  AS dblNewStorageBilled
	 ,a.dblOpenBalance* CASE WHEN @PostType='Bill Storage' THEN bill.dblAdditionalCharge ELSE 0 END  AS dblStorageDueAmount
	FROM tblGRCustomerStorage a  
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId  
	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId  
	JOIN tblEMEntity E ON E.intEntityId = a.intEntityId 
	JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=a.intStorageScheduleId
	JOIN tblICItem Item ON Item.intItemId = a.intItemId
	JOIN @BillStorageDiscounts bill ON bill.intCustomerStorageId=a.intCustomerStorageId
	WHERE a.intEntityId= CASE WHEN @PortalEntityId>0 THEN @PortalEntityId ELSE a.intEntityId END
	AND (ISNULL(a.dblStorageDue,0)-ISNULL(a.dblStoragePaid,0))+ISNULL(bill.dblAdditionalCharge,0) > 0
	ORDER BY E.strName,c.strLocationName
	
END TRY

BEGIN CATCH

	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH