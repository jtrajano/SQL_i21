CREATE VIEW [dbo].[vyuGRGetStorageType]
AS  
SELECT DISTINCT
    CS.intEntityId
    ,CS.intCompanyLocationId     
    ,CS.intItemId  
    ,ST.intStorageScheduleTypeId
    ,ST.strStorageTypeCode
    ,ST.strStorageTypeDescription
	,ysnShowInStorage = CAST(
							CASE
								WHEN ST.ysnCustomerStorage = 0 THEN 1
								WHEN ST.ysnCustomerStorage = 1 AND ST.strOwnedPhysicalStock = 'Customer' THEN 1
								ELSE 0
							END AS BIT
						)
    ,ysnStorageTypeReady = CAST(
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
JOIN tblGRStorageType ST 
    ON ST.intStorageScheduleTypeId = CS.intStorageTypeId 
WHERE CS.dblOpenBalance > 0