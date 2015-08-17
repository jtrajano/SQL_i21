CREATE PROCEDURE uspRKGetGrainBankDetail 
@intCommodityId INT  
 ,@intLocationId INT = NULL  
 ,@intSeqId INT  
 ,@strGrainType NVARCHAR(20)  
AS  
BEGIN  
 IF @strGrainType = 'Off-Site'  
 BEGIN  
  IF ISNULL(@intLocationId, 0) <> 0  
  BEGIN  
   SELECT intCustomerStorageId  
    ,'Off-Site' strType  
    ,Loc AS strLocation  
    ,[Delivery Date] AS dtmDeliveryDate  
    ,Ticket intTicket  
    ,Customer as strCustomerReference  
    ,Receipt AS strDPAReceiptNo  
    ,[Disc Due] AS dblDiscDue  
    ,[Storage Due] AS dblStorageDue  
    ,dtmLastStorageAccrueDate  
    ,strScheduleId  
    ,ISNULL(Balance, 0) dblTotal  
   FROM vyuGRGetStorageDetail  
   WHERE ysnCustomerStorage = 1  
    AND strOwnedPhysicalStock = 'Company'  
    AND intCommodityId = @intCommodityId  
    AND intCompanyLocationId = @intLocationId  
  END  
  ELSE  
  BEGIN  
   SELECT intCustomerStorageId  
    ,'Off-Site' strType  
    ,Loc AS strLocation  
    ,[Delivery Date] AS dtmDeliveryDate  
    ,Ticket intTicket  
    ,Customer as strCustomerReference  
    ,Receipt AS strDPAReceiptNo  
    ,[Disc Due] AS dblDiscDue  
    ,[Storage Due] AS dblStorageDue  
    ,dtmLastStorageAccrueDate  
    ,strScheduleId  
    ,ISNULL(Balance, 0) dblTotal  
   FROM vyuGRGetStorageDetail  
   WHERE ysnCustomerStorage = 1  
    AND strOwnedPhysicalStock = 'Company'  
    AND intCommodityId = @intCommodityId  
  END  
 END  
 ELSE IF @strGrainType = 'DP'  
 BEGIN  
  IF ISNULL(@intLocationId, 0) <> 0  
  BEGIN  
   SELECT intCustomerStorageId  
    ,[Storage Type] strType  
    ,Loc AS strLocation  
    ,[Delivery Date] AS dtmDeliveryDate  
    ,Ticket intTicket  
    ,Customer as strCustomerReference  
    ,Receipt AS strDPAReceiptNo  
    ,[Disc Due] AS dblDiscDue  
    ,[Storage Due] AS dblStorageDue  
    ,dtmLastStorageAccrueDate  
    ,strScheduleId  
    ,ISNULL(Balance, 0) dblTotal  
   FROM vyuGRGetStorageDetail  
   WHERE ysnDPOwnedType = 1  
    AND intCommodityId = @intCommodityId  
    AND intCompanyLocationId = @intLocationId  
  END  
  ELSE  
  BEGIN  
   SELECT intCustomerStorageId  
    ,[Storage Type] strType  
    ,Loc AS strLocation  
    ,[Delivery Date] AS dtmDeliveryDate  
    ,Ticket intTicket  
    ,Customer as strCustomerReference  
    ,Receipt AS strDPAReceiptNo  
    ,[Disc Due] AS dblDiscDue  
    ,[Storage Due] AS dblStorageDue  
    ,dtmLastStorageAccrueDate  
    ,strScheduleId  
    ,ISNULL(Balance, 0) dblTotal  
   FROM vyuGRGetStorageDetail  
   WHERE ysnDPOwnedType = 1  
    AND intCommodityId = @intCommodityId  
  END  
 END  
 ELSE IF @strGrainType = 'Warehouse'  
 BEGIN  
  IF ISNULL(@intLocationId, 0) <> 0  
  BEGIN  
   SELECT intCustomerStorageId  
    ,[Storage Type] strType  
    ,Loc AS strLocation  
    ,[Delivery Date] AS dtmDeliveryDate  
    ,Ticket intTicket  
 ,Customer as strCustomerReference  
    ,Receipt AS strDPAReceiptNo  
    ,[Disc Due] AS dblDiscDue  
    ,[Storage Due] AS dblStorageDue  
    ,dtmLastStorageAccrueDate  
    ,strScheduleId  
    ,ISNULL(Balance, 0) dblTotal  
   FROM vyuGRGetStorageDetail  
   WHERE  ysnReceiptedStorage = 1  
    AND intCommodityId = @intCommodityId  
    AND intCompanyLocationId = @intLocationId  
  END  
  ELSE  
  BEGIN  
   SELECT intCustomerStorageId  
    ,[Storage Type] strType  
    ,Loc AS strLocation  
    ,[Delivery Date] AS dtmDeliveryDate  
    ,Ticket intTicket  
    ,Customer as strCustomerReference  
    ,Receipt AS strDPAReceiptNo  
    ,[Disc Due] AS dblDiscDue  
    ,[Storage Due] AS dblStorageDue  
    ,dtmLastStorageAccrueDate  
    ,strScheduleId  
    ,ISNULL(Balance, 0) dblTotal  
   FROM vyuGRGetStorageDetail  
   WHERE ysnReceiptedStorage = 1  
    AND intCommodityId = @intCommodityId  
  END  
 END  
 ELSE   
 IF ISNULL(@intLocationId, 0) <> 0  
 BEGIN  
  SELECT intCustomerStorageId  
   ,[Storage Type] strType  
   ,Loc AS strLocation  
   ,[Delivery Date] AS dtmDeliveryDate  
   ,Ticket intTicket  
   ,Customer as strCustomerReference  
   ,Receipt AS strDPAReceiptNo  
   ,[Disc Due] AS dblDiscDue  
   ,[Storage Due] AS dblStorageDue  
   ,dtmLastStorageAccrueDate  
   ,strScheduleId  
   ,ISNULL(Balance, 0) dblTotal  
  FROM vyuGRGetStorageDetail  
  WHERE intCommodityId = @intCommodityId  
   AND ysnDPOwnedType = 0  
   AND ysnReceiptedStorage = 0  
   AND intCompanyLocationId = @intLocationId  
   AND [Storage Type] = @strGrainType  
 END  
 ELSE  
 BEGIN  
  SELECT intCustomerStorageId  
   ,[Storage Type] strType  
   ,Loc AS strLocation  
   ,[Delivery Date] AS dtmDeliveryDate  
   ,Ticket intTicket  
 ,Customer as strCustomerReference  
   ,Receipt AS strDPAReceiptNo  
   ,[Disc Due] AS dblDiscDue  
   ,[Storage Due] AS dblStorageDue  
   ,dtmLastStorageAccrueDate  
   ,strScheduleId  
   ,ISNULL(Balance, 0) dblTotal  
  FROM vyuGRGetStorageDetail  
  WHERE intCommodityId = @intCommodityId  
   AND ysnDPOwnedType = 0  
   AND ysnReceiptedStorage = 0  
   AND [Storage Type] = @strGrainType  
 END  
END