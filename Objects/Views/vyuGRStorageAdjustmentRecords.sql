CREATE VIEW [dbo].[vyuGRStorageAdjustmentRecords]
AS
SELECT
	CS.intCustomerStorageId
	,CS.dblOriginalBalance
	,A.dblNewBalanceBeforeSettlement
	,ST.intStorageScheduleTypeId
	,ST.strStorageTypeCode
	,ST.ysnDPOwnedType
	,ysnIsStorageAdjusted = CAST(
								CASE 
									WHEN SH.intCustomerStorageId IS NULL THEN 0 
									ELSE 1
								END 
							AS BIT)
FROM tblGRCustomerStorage CS
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
OUTER APPLY (
	SELECT 		
		SUM(CASE 
				WHEN intTransactionTypeId = 5 OR intTransactionTypeId = 1 OR (strType = 'Storage Adjustment') OR strType = 'From Transfer' THEN dblUnits 
				ELSE 0 
			END
		) AS dblNewBalanceBeforeSettlement
	FROM tblGRStorageHistory SH
	WHERE SH.intCustomerStorageId = CS.intCustomerStorageId
) A
LEFT JOIN tblGRStorageHistory SH
	ON SH.intCustomerStorageId = CS.intCustomerStorageId
		AND SH.strType = 'Storage Adjustment'