GO
--BEGIN TRAN
    PRINT 'BEGIN Migrating Transfer Storage data to Main tables'
    --migrate all existing Transfer Storage to new tables
    --1. insert in transfer storage tables
    --2. update tblGRStorageHistory with the intTransferStorageId and strTransferTicketNumber
    --3. set intTicketId in tblGRStorageHistory to NULL
    
    IF NOT EXISTS(  SELECT TOP 1 1 
                    FROM tblGRTransferStorage TS
                    INNER JOIN tblGRTransferStorageSourceSplit TSource
                        ON TSource.intTransferStorageId = TS.intTransferStorageId
                    INNER JOIN tblGRTransferStorageSplit TSplit
                        ON TSplit.intTransferStorageId = TS.intTransferStorageId
                    INNER JOIN tblGRStorageHistory SH
                        ON (
                            TSource.intSourceCustomerStorageId = SH.intTicketId
                                AND TSplit.intTransferToCustomerStorageId = SH.intCustomerStorageId
                                AND SH.strType = 'From Transfer'
                            ) --TRANSFERRED TO
                            OR
                            (
                            TSource.intSourceCustomerStorageId = SH.intCustomerStorageId
                                AND SH.strType = 'Transfer'
                            ) --SOURCE
                )
    BEGIN
	/*====TRANSFER STORAGE'S HEADER====*/
    INSERT INTO [dbo].[tblGRTransferStorage]
    (
        [strTransferStorageTicket]
        , [intEntityId]
        , [intCompanyLocationId]
        , [intStorageScheduleTypeId]
        , [intItemId]
        , [intItemUOMId]
        , [dblTotalUnits]
        , [intConcurrencyId]
        , [intUserId]
        , [intTransferLocationId]
    )
    SELECT
        [strTransferStorageTicket]      = SH.strTransferTicket
        , [intEntityId]                 = CS.intEntityId
        , [intCompanyLocationId]        = CS.intCompanyLocationId
        , [intStorageScheduleTypeId]    = CS.intStorageTypeId
        , [intItemId]                   = CS.intItemId
        , [intItemUOMId]                = CS.intItemUOMId
        , [dblTotalUnits]               = ABS(SUM(dblUnits))
        , [intConcurrencyId]            = CS.intConcurrencyId
        , [intUserId]                   = ISNULL(SH.intUserId, US.intEntityId)
        , [intTransferLocationId]       = CS.intCompanyLocationId
    FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageHistory SH
		ON SH.intCustomerStorageId = CS.intCustomerStorageId
			AND SH.strType = 'Transfer'
	LEFT JOIN tblSMUserSecurity US
		ON US.strUserName = SH.strUserName
	GROUP BY SH.strTransferTicket, CS.intEntityId, CS.intCompanyLocationId, CS.intStorageTypeId, CS.intItemId, CS.intItemUOMId, CS.intConcurrencyId, SH.intUserId,US.intEntityId
    
	UPDATE TS 
	SET [dtmTransferStorageDate] = ISNULL([dbo].[fnRemoveTimeOnDate](SH.dtmDistributionDate), [dtmTransferStorageDate]) 
	FROM tblGRTransferStorage TS
	INNER JOIN tblGRStorageHistory SH
	ON SH.strTransferTicket = TS.strTransferStorageTicket
		AND SH.strType = 'Transfer'	

	/*====SOURCE CUSTOMER STORAGES====*/
	INSERT INTO [dbo].[tblGRTransferStorageSourceSplit]
    (
        [intTransferStorageId]
        , [intSourceCustomerStorageId]
		, [intStorageTypeId]
        , [intStorageScheduleId]
        , [dblOriginalUnits]
        , [dblDeductedUnits]
        , [dblSplitPercent]
        , [intConcurrencyId]
    )
    SELECT
        [intTransferStorageId]          = TS.intTransferStorageId
        , [intSourceCustomerStorageId]  = CS.intCustomerStorageId
		, [intStorageTypeId]            = CS.intStorageTypeId
        , [intStorageScheduleId]        = CS.intStorageScheduleId
        , [dblOriginalUnits]            = CS.dblOriginalBalance
        , [dblDeductedUnits]            = ABS(SUM(SH.dblUnits))
        , [dblSplitPercent]             = ABS(ROUND((SUM(SH.dblUnits) / CS.dblOriginalBalance) * 100, 2))
        , [intConcurrencyId]            = CS.intConcurrencyId
    FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageHistory SH
		ON SH.intCustomerStorageId = CS.intCustomerStorageId
			AND SH.strType = 'Transfer'
	INNER JOIN tblGRTransferStorage TS
		ON TS.strTransferStorageTicket = SH.strTransferTicket
	GROUP BY TS.intTransferStorageId, CS.intCustomerStorageId, CS.intStorageTypeId, CS.intStorageScheduleId, CS.dblOriginalBalance, CS.intConcurrencyId

	/*===="TRANFERRED TO" CUSTOMER STORAGES====*/
	INSERT INTO [dbo].[tblGRTransferStorageSplit]
    (
        [intTransferStorageId]
        , [intTransferToCustomerStorageId]
        , [intEntityId]
        , [intCompanyLocationId]
        , [intStorageTypeId]
        , [intStorageScheduleId]
		, [intContractDetailId]
		, [dblSplitPercent]
		, [dblUnits]
		, [intConcurrencyId]
    )
    SELECT
        [intTransferStorageId]              = TS.intTransferStorageId
        , [intTransferToCustomerStorageId]  = CS.intCustomerStorageId
        , [intEntityId]                     = CS.intEntityId
        , [intCompanyLocationId]            = CS.intCompanyLocationId
        , [intStorageTypeId]                = CS.intStorageTypeId
        , [intStorageScheduleId]            = CS.intStorageScheduleId
		, [intContractDetailId]             = NULL --NULL FOR NOW; APPLICATION OF DP CONTRACT IS NOT YET IMPLEMENTED
		, [dblSplitPercent]                 = ROUND(((CS.dblOriginalBalance / TotalUnits.dblUnits) * 100), 2)
		, [dblUnits]                        = CS.dblOriginalBalance
		, [intConcurrencyId]                = CS.intConcurrencyId
    FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageHistory SH
		ON SH.intCustomerStorageId = CS.intCustomerStorageId
			AND SH.strType = 'From Transfer'
	INNER JOIN tblGRTransferStorage TS
		ON TS.strTransferStorageTicket = SH.strTransferTicket
	INNER JOIN (
				SELECT 
					A.intTransferStorageId,
					SUM(dblOriginalUnits) dblUnits
				FROM tblGRTransferStorageSourceSplit A 
				INNER JOIN tblGRTransferStorage B 
					ON B.intTransferStorageId = A.intTransferStorageId
				GROUP BY A.intTransferStorageId
        ) TotalUnits ON TotalUnits.intTransferStorageId = TS.intTransferStorageId
        
	PRINT 'END Migrating Transfer Storage data to Main tables'

	/****update data in tblGRStorageHistoryId****/
	PRINT 'START Updating intTransferStorageId.tblGRStorageHistory and intTicketId.tblGRStorageHistory'

	UPDATE SH
	SET SH.intTransferStorageId = TS.intTransferStorageId
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRTransferStorage TS
		ON TS.strTransferStorageTicket = SH.strTransferTicket

	UPDATE tblGRStorageHistory SET intTicketId = NULL WHERE strType = 'From Transfer'

	UPDATE CS
	SET CS.strStorageTicketNumber = TS.strTransferStorageTicket
		, CS.ysnTransferStorage = 1
	FROM tblGRCustomerStorage CS
	INNER JOIN (
				tblGRTransferStorageSplit SS
				INNER JOIN tblGRTransferStorage TS
					ON TS.intTransferStorageId = SS.intTransferStorageId
				)
		ON SS.intTransferToCustomerStorageId = CS.intCustomerStorageId

    END

	PRINT 'END Updating intTransferStorageId.tblGRStorageHistory and intTicketId.tblGRStorageHistory'
GO