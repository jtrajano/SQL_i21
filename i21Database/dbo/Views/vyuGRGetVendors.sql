CREATE VIEW [dbo].[vyuGRGetVendors]
AS  
SELECT DISTINCT
	CS.intEntityId 
	,E.strName AS strEntityName
	,E.strEntityNo
	,ET.strType AS strEntityType
	,ysnCustomerStorage		  = CAST(
                              CASE
                                WHEN ST.ysnCustomerStorage = 0 THEN 1
                                
                                WHEN ST.ysnCustomerStorage = 1 AND ST.strOwnedPhysicalStock = 'Customer' THEN 1
                                ELSE 0
                              END AS BIT
                          )
	,ysnStorageVendorReady  = CAST(
                              CASE
                                WHEN ysnTransferStorage = 1 THEN 1
                                ELSE 
                                  CASE
                                    WHEN CS.intTicketId IS NOT NULL THEN 1
                                    WHEN CS.intDeliverySheetId IS NOT NULL THEN (SELECT ysnPost FROM tblSCDeliverySheet WHERE intDeliverySheetId = CS.intDeliverySheetId)
                                  END
                              END AS BIT
                          )
FROM tblGRCustomerStorage CS  
INNER JOIN tblEMEntity E 
	ON E.intEntityId = CS.intEntityId
INNER JOIN tblEMEntityType ET 
	ON ET.intEntityId = E.intEntityId
INNER JOIN tblGRStorageType ST 
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
WHERE CS.dblOpenBalance > 0