CREATE PROCEDURE uspRKGetGrainBankDetail 
			@intCommodityId INT  
			,@intLocationId INT = NULL  
			,@intSeqId INT  
			,@strGrainType NVARCHAR(20)  
AS  
BEGIN  

declare  @tblTemp table
			(intCustomerStorageId int,
			strType nvarchar(50),
			strLocation nvarchar(50),
			dtmDeliveryDate datetime,
			strTicket nvarchar(50),
			strCustomerReference nvarchar(100),
			strDPAReceiptNo nvarchar(50),
			dblDiscDue numeric(24,10),
			dblStorageDue numeric(24,10),
			dtmLastStorageAccrueDate datetime,
			strScheduleId nvarchar(50),
			dblTotal numeric(24,10),
			intCommodityId int			
			)

IF @strGrainType = 'Off-Site'  
BEGIN  
IF ISNULL(@intLocationId, 0) <> 0  
		BEGIN  
		INSERT INTO @tblTemp (intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
			dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, dblTotal,intCommodityId )
		SELECT intCustomerStorageId,'Off-Site' strType ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
		,dtmLastStorageAccrueDate ,strScheduleId ,ISNULL(Balance, 0) dblTotal,intCommodityId  
		FROM vyuGRGetStorageOffSiteDetail  
		WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer' AND intCommodityId = @intCommodityId 
		AND intCompanyLocationId = @intLocationId  
	END  
ELSE  
	BEGIN  
	INSERT INTO @tblTemp (intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
			dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, dblTotal,intCommodityId )
		SELECT intCustomerStorageId,'Off-Site' strType ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
		,dtmLastStorageAccrueDate ,strScheduleId ,ISNULL(Balance, 0) dblTotal ,intCommodityId 
		FROM vyuGRGetStorageOffSiteDetail  WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer'  AND intCommodityId = @intCommodityId  
	END  
END  
ELSE IF @strGrainType = 'DP'  
BEGIN  
IF ISNULL(@intLocationId, 0) <> 0  
	BEGIN  
	INSERT INTO @tblTemp (intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
			dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, dblTotal,intCommodityId )
		SELECT intCustomerStorageId,'DP' strType ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
		,dtmLastStorageAccrueDate ,strScheduleId ,ISNULL(Balance, 0) dblTotal,intCommodityId   
		FROM vyuGRGetStorageDetail  
		WHERE ysnDPOwnedType = 1 AND intCommodityId = @intCommodityId  AND intCompanyLocationId = @intLocationId  
	END  
ELSE  
	BEGIN  
	INSERT INTO @tblTemp (intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
			dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, dblTotal,intCommodityId )
		SELECT intCustomerStorageId,'DP' strType ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
		,dtmLastStorageAccrueDate ,strScheduleId ,ISNULL(Balance, 0) dblTotal,intCommodityId   
		FROM vyuGRGetStorageDetail  WHERE ysnDPOwnedType = 1  AND intCommodityId = @intCommodityId  
	END  
END  
ELSE IF @strGrainType = 'Warehouse'  
BEGIN  
	IF ISNULL(@intLocationId, 0) <> 0  
		BEGIN  
		INSERT INTO @tblTemp (intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
			dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, dblTotal,intCommodityId )
			SELECT intCustomerStorageId,'Warehouse' strType ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
			,dtmLastStorageAccrueDate ,strScheduleId ,ISNULL(Balance, 0) dblTotal,intCommodityId   
			FROM vyuGRGetStorageOffSiteDetail  WHERE ysnReceiptedStorage = 1 AND ysnExternal <> 1 AND strOwnedPhysicalStock = 'Customer'  AND intCommodityId = @intCommodityId  AND intCompanyLocationId = @intLocationId  
		END  
	ELSE  
		BEGIN  
		INSERT INTO @tblTemp (intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
			dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, dblTotal,intCommodityId )
			SELECT intCustomerStorageId,'Warehouse' strType ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
			,dtmLastStorageAccrueDate ,strScheduleId ,ISNULL(Balance, 0) dblTotal,intCommodityId   
			 FROM vyuGRGetStorageOffSiteDetail  WHERE ysnReceiptedStorage = 1 AND ysnExternal <> 1 	AND intCommodityId = @intCommodityId  
		END  
	END  
	ELSE   
	IF ISNULL(@intLocationId, 0) <> 0  
		BEGIN  
		INSERT INTO @tblTemp (intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
			dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, dblTotal,intCommodityId )
			SELECT intCustomerStorageId,@strGrainType strType ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
			,dtmLastStorageAccrueDate ,strScheduleId ,ISNULL(Balance, 0) dblTotal,intCommodityId   
			FROM vyuGRGetStorageDetail  
			WHERE intCommodityId = @intCommodityId AND ysnDPOwnedType = 0  AND ysnReceiptedStorage = 0  AND intCompanyLocationId = @intLocationId  AND [Storage Type] = @strGrainType  
		END  
		ELSE	  
		BEGIN  
		INSERT INTO @tblTemp (intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
			dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, dblTotal,intCommodityId )
			SELECT intCustomerStorageId,@strGrainType strType ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
			,dtmLastStorageAccrueDate ,strScheduleId ,ISNULL(Balance, 0) dblTotal ,intCommodityId    
			FROM vyuGRGetStorageDetail  
			WHERE intCommodityId = @intCommodityId AND ysnDPOwnedType = 0  AND ysnReceiptedStorage = 0  AND [Storage Type] = @strGrainType  
		END  
END

DECLARE @intUnitMeasureId int
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
if isnull(@intUnitMeasureId,'')<> ''
BEGIN

SELECT intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,dblDiscDue,
			dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, 
			isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,round(dblTotal,4)),0) dblTotal
	FROM @tblTemp t
JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
END
ELSE
BEGIN
SELECT intCustomerStorageId,strType ,strLocation ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,dblDiscDue ,dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId, dblTotal 
FROM @tblTemp
END
