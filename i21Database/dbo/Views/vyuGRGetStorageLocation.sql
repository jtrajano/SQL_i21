CREATE VIEW [dbo].[vyuGRGetStorageLocation]  
AS  
SELECT DISTINCT
	 CS.intEntityId 
	,CS.intCompanyLocationId  
	,LOC.strLocationName
	,ST.ysnCustomerStorage
	,ysnStorageLocationReady = CAST(
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
JOIN tblSMCompanyLocation LOC 
	ON LOC.intCompanyLocationId = CS.intCompanyLocationId
JOIN tblGRStorageType ST 
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId  
WHERE CS.dblOpenBalance > 0