GO
--BEGIN TRAN
    PRINT 'BEGIN Migrating Transfer Storage data to Main tables'
    --migrate all existing Transfer Storage to new tables
    --USE WHILE TO LOOP UNTIL THERE'S NO MORE intTransferStorageId missing in tblGRStorageHistory table
    --1. insert in transfer storage tables
    --2. update tblGRStorageHistory with the intTransferStorageId and strTransferTicketNumber
    --3. set intTicketId in tblGRStorageHistory to NULL
    
    IF NOT EXISTS(  SELECT TOP 1 1 
                    FROM tblGRTransferStorageReference TSR
                    JOIN tblGRStorageHistory SH
                        ON (TSR.intSourceCustomerStorageId = SH.intTicketId
                            AND TSR.intTransferToCustomerStorageId = SH.intCustomerStorageId
                            AND SH.strType = 'From Transfer') --TRANSFERRED TO
                            OR
                            (TSR.intSourceCustomerStorageId = SH.intCustomerStorageId
                            AND SH.strType = 'Transfer')--SOURCE
                )

	/*====TRANSFER STORAGE'S HEADER====*/
    INSERT INTO [dbo].[tblGRTransferStorage]
    (
        [strTransferStorageTicket]
        , [intEntityId]
        , [intCompanyLocationId]
        , [intStorageTypeId]
        , [intItemId]
        , [intItemUOMId]
        , [dblTotalUnits]
        , [intConcurrencyId]
    )
    SELECT
        [strTransferStorageTicket]  = SH.strTransferTicket
        , [intEntityId]             = CS.intEntityId
        , [intCompanyLocationId]    = CS.intCompanyLocationId
        , [intStorageTypeId]        = CS.intStorageTypeId
        , [intItemId]               = CS.intItemId
        , [intItemUOMId]            = CS.intItemUOMId
        , [dblTotalUnits]           = ABS(SUM(dblUnits))
        , [intConcurrencyId]        = CS.intConcurrencyId
    FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageHistory SH
		ON SH.intCustomerStorageId = CS.intCustomerStorageId
			AND SH.strType = 'Transfer'
	GROUP BY SH.strTransferTicket, CS.intEntityId, CS.intCompanyLocationId, CS.intStorageTypeId, CS.intItemId, CS.intItemUOMId, CS.intConcurrencyId

	UPDATE TS 
	SET [dtmTransferStorageDate] = [dbo].[fnRemoveTimeOnDate](SH.dtmDistributionDate) 
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
        , [intConcurrencyId]
    )
    SELECT
        [intTransferStorageId]          = TS.intTransferStorageId
        , [intSourceCustomerStorageId]  = CS.intCustomerStorageId
		, [intStorageTypeId]            = CS.intStorageTypeId
        , [intStorageScheduleId]        = CS.intStorageScheduleId
        , [dblOriginalUnits]            = CS.dblOriginalBalance
        , [dblDeductedUnits]            = ABS(SUM(SH.dblUnits))
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
		, [intContractDetailId]             = 0
		, [dblSplitPercent]                 = ROUND(((CS.dblOriginalBalance / TS.dblTotalUnits) * 100), 2)
		, [dblUnits]                        = CS.dblOriginalBalance
		, [intConcurrencyId]                = CS.intConcurrencyId
    FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageHistory SH
		ON SH.intCustomerStorageId = CS.intCustomerStorageId
			AND SH.strType = 'From Transfer'
	INNER JOIN tblGRTransferStorage TS
		ON TS.strTransferStorageTicket = SH.strTransferTicket
        
	PRINT 'END Migrating Transfer Storage data to Main tables'
	/****tblGRTransferStorageReference might no longer be needed*****/

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
		, CS.intTicketId = NULL
		, CS.intDeliverySheetId = NULL
	FROM tblGRCustomerStorage CS
	INNER JOIN (
				tblGRTransferStorageSplit SS
				INNER JOIN tblGRTransferStorage TS
					ON TS.intTransferStorageId = SS.intTransferStorageId
				)
		ON SS.intTransferToCustomerStorageId = CS.intCustomerStorageId


	PRINT 'END Updating intTransferStorageId.tblGRStorageHistory and intTicketId.tblGRStorageHistory'

	SELECT * FROM tblGRTransferStorage
	SELECT * FROM tblGRTransferStorageSourceSplit
	SELECT * FROM tblGRTransferStorageSplit

	select intTransferStorageId, intTicketId, strTransferTicket, * from tblGRStorageHistory where strType like '%transfer%'
	SELECT * FROM tblGRCustomerStorage

    
--ROLLBACK TRAN
GO

--EXEC [dbo].[uspGRDropCreateTransferTables]