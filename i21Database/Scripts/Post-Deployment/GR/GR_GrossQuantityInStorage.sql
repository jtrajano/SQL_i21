PRINT 'BEGIN UPDATING THE GROSS QUANTITY OF STORAGES'
GO

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE name = N'dblGrossQuantity'
          AND object_id = object_id(N'dbo.tblGRCustomerStorage'))
BEGIN

DECLARE @cnt INT

UPDATE GRS 
SET GRS.dblGrossQuantity = CASE 
							WHEN SCD.dblNet > 0 THEN ROUND(((GRS.dblOpenBalance / SCD.dblNet) * SCD.dblGross),(SELECT intCurrencyDecimal FROM tblSMCompanyPreference))
							ELSE 0
						END
FROM tblSCDeliverySheet SCD
INNER JOIN tblSCDeliverySheetSplit SCDS 
	ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
INNER JOIN tblGRCustomerStorage GRS 
	ON GRS.intDeliverySheetId = SCDS.intDeliverySheetId 
		AND SCDS.intEntityId = GRS.intEntityId
		AND SCDS.intStorageScheduleTypeId = GRS.intStorageTypeId  
WHERE GRS.ysnTransferStorage = 0
	AND SCD.ysnPost = 1

SELECT @cnt = COUNT(*)
FROM tblSCDeliverySheet SCD
INNER JOIN tblSCDeliverySheetSplit SCDS 
	ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
INNER JOIN tblGRCustomerStorage GRS 
	ON GRS.intDeliverySheetId = SCDS.intDeliverySheetId 
		AND SCDS.intEntityId = GRS.intEntityId
		AND SCDS.intStorageScheduleTypeId = GRS.intStorageTypeId  
WHERE GRS.ysnTransferStorage = 0
	AND SCD.ysnPost = 1

PRINT('SUCCESSFULLY UPDATED ' + CAST(@cnt AS NVARCHAR(MAX)) + ' RECORDS.')

END

PRINT 'END UPDATING THE GROSS QUANTITY OF STORAGES'
GO

PRINT 'BEGIN UPDATING THE GROSS QUANTITY OF SETTLED STORAGES'
GO

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE name = N'dblGrossSettledUnits'
          AND object_id = object_id(N'dbo.tblGRSettleStorageTicket'))
BEGIN

DECLARE @cnt INT

UPDATE SST
SET SST.dblGrossSettledUnits = CASE
									WHEN DS.dblNet > 0 THEN ROUND(((SST.dblUnits / DS.dblNet) * DS.dblGross),(SELECT intCurrencyDecimal FROM tblSMCompanyPreference))
									ELSE 0
							END
FROM tblGRSettleStorageTicket SST
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SST.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SS.intSettleStorageId = SST.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
INNER JOIN (
	SELECT
		DS.intDeliverySheetId
		,DSS.intEntityId
		,DS.intCompanyLocationId
		,DSS.intStorageScheduleTypeId
		,DSS.intStorageScheduleRuleId
		,dblGross	= DS.dblGross * (DSS.dblSplitPercent / 100)
		,dblNet		= DS.dblNet * (DSS.dblSplitPercent / 100)
	FROM tblSCDeliverySheet DS
	INNER JOIN tblSCDeliverySheetSplit DSS
		ON DSS.intDeliverySheetId = DS.intDeliverySheetId
		) DS ON DS.intDeliverySheetId = CS.intDeliverySheetId
			AND DS.intEntityId = CS.intEntityId
			AND DS.intCompanyLocationId = CS.intCompanyLocationId
			AND DS.intStorageScheduleTypeId = CS.intStorageTypeId
			AND DS.intStorageScheduleRuleId = CS.intStorageScheduleId

SELECT @cnt = COUNT(*)
FROM tblGRSettleStorageTicket SST
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SST.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SS.intSettleStorageId = SST.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
INNER JOIN (
	SELECT
		DS.intDeliverySheetId
		,DSS.intEntityId
		,DS.intCompanyLocationId
		,DSS.intStorageScheduleTypeId
		,DSS.intStorageScheduleRuleId
		,dblGross	= DS.dblGross * (DSS.dblSplitPercent / 100)
		,dblNet		= DS.dblNet * (DSS.dblSplitPercent / 100)
	FROM tblSCDeliverySheet DS
	INNER JOIN tblSCDeliverySheetSplit DSS
		ON DSS.intDeliverySheetId = DS.intDeliverySheetId
		) DS ON DS.intDeliverySheetId = CS.intDeliverySheetId
			AND DS.intEntityId = CS.intEntityId
			AND DS.intCompanyLocationId = CS.intCompanyLocationId
			AND DS.intStorageScheduleTypeId = CS.intStorageTypeId
			AND DS.intStorageScheduleRuleId = CS.intStorageScheduleId

PRINT('SUCCESSFULLY UPDATED ' + CAST(@cnt AS NVARCHAR(MAX)) + ' RECORDS.')

END

PRINT 'END UPDATING THE GROSS QUANTITY OF SETTLED STORAGES'
GO