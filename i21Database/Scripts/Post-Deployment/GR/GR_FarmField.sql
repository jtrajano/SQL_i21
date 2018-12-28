PRINT 'BEGIN UPDATING THE SHIP FROM ENTITY AND LOCATION OF STORAGE RECORDS'
GO

IF EXISTS(
			SELECT 1 
			FROM sys.columns 
			WHERE name IN (N'intShipFromLocationId',N'intShipFromEntityId')
				AND object_id = object_id(N'dbo.tblGRCustomerStorage')
		)
BEGIN

--FROM DELIVERY SHEETS
UPDATE CS 
SET CS.intShipFromLocationId = ISNULL(DS.intFarmFieldId, EL.intEntityLocationId) 
	,CS.intShipFromEntityId = DS.intEntityId
FROM tblSCDeliverySheetSplit DSS
JOIN tblSCDeliverySheet DS
	ON DS.intDeliverySheetId = DSS.intDeliverySheetId
LEFT JOIN tblEMEntityLocation EL 
	ON EL.intEntityId = DS.intEntityId 
		AND EL.ysnDefaultLocation = 1
JOIN tblGRCustomerStorage CS
	ON DSS.intDeliverySheetId = CS.intDeliverySheetId
		AND CS.intEntityId = DSS.intEntityId
		AND CS.intStorageTypeId = DSS.intStorageScheduleTypeId
		AND CS.intStorageScheduleId = DSS.intStorageScheduleRuleId
WHERE CS.ysnTransferStorage = 0

--TRANSFER STORAGE
UPDATE CS 
SET CS.intShipFromLocationId = (SELECT intShipFromLocationId FROM tblGRCustomerStorage WHERE intCustomerStorageId = TSSource.intSourceCustomerStorageId)
	,CS.intShipFromEntityId =  (SELECT intShipFromEntityId FROM tblGRCustomerStorage WHERE intCustomerStorageId = TSSource.intSourceCustomerStorageId)
FROM tblGRCustomerStorage CS
INNER JOIN tblGRTransferStorageSplit TSplit
	ON TSplit.intTransferToCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRTransferStorageSourceSplit TSSource
	ON TSSource.intTransferStorageId = TSplit.intTransferStorageId

--TRANSFERRED TRANSFER STORAGE
UPDATE CS 
SET CS.intShipFromLocationId = (SELECT intShipFromLocationId FROM tblGRCustomerStorage WHERE intCustomerStorageId = TSSource.intSourceCustomerStorageId)
	,CS.intShipFromEntityId =  (SELECT intShipFromEntityId FROM tblGRCustomerStorage WHERE intCustomerStorageId = TSSource.intSourceCustomerStorageId)
FROM tblGRCustomerStorage CS
INNER JOIN tblGRTransferStorageSplit TSplit
	ON TSplit.intTransferToCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRTransferStorageSourceSplit TSSource
	ON TSSource.intTransferStorageId = TSplit.intTransferStorageId
WHERE TSplit.intTransferToCustomerStorageId NOT IN (SELECT intSourceCustomerStorageId FROM tblGRTransferStorageSourceSplit)

--to correct the transfer storage ticket in history
UPDATE SH
SET SH.strTransferTicket = TS.strTransferStorageTicket
FROM tblGRStorageHistory SH
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = SH.intTransferStorageId

END

PRINT 'END UPDATING THE SHIP FROM ENTITY AND LOCATION OF STORAGE RECORDS'
GO