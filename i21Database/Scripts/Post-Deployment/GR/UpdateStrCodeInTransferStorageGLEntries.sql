PRINT 'BEGIN UPDATING strCode IN TRANSFER STORAGE GL ENTRIES'

-- Update strCode in tblGLDetail for DP to OS and OS to DP transfers.
IF EXISTS(
    SELECT TOP 1 1
    FROM 
        tblICInventoryTransaction t 
        INNER JOIN tblICItem i 
            ON t.intItemId = i.intItemId
        INNER JOIN tblGLDetail gd
            ON t.strTransactionId = gd.strTransactionId 
            AND t.strBatchId = gd.strBatchId
            AND t.intInventoryTransactionId = gd.intJournalLineNo 
        CROSS APPLY (
            SELECT TOP 1 
                gd2.intGLDetailId 
                ,gd2.strDescription 
            FROM 
                tblGLDetail gd2
            WHERE
                gd2.strTransactionId = gd.strTransactionId
                AND gd2.strBatchId = gd.strBatchId
                AND gd2.intJournalLineNo = gd.intJournalLineNo 
                AND gd2.strDescription LIKE '%' + i.strItemNo + '%'
        ) validICGL
    WHERE
        t.strTransactionId LIKE 'TRA%'
        AND gd.strCode = 'TRA'
)
BEGIN
    UPDATE gd
    SET
        gd.strCode = 'IC'
    FROM 
        tblICInventoryTransaction t 
        INNER JOIN tblICItem i 
            ON t.intItemId = i.intItemId
        INNER JOIN tblGLDetail gd
            ON t.strTransactionId = gd.strTransactionId 
            AND t.strBatchId = gd.strBatchId
            AND t.intInventoryTransactionId = gd.intJournalLineNo 
        CROSS APPLY (
            SELECT TOP 1 
                gd2.intGLDetailId 
                ,gd2.strDescription 
            FROM 
                tblGLDetail gd2
            WHERE
                gd2.strTransactionId = gd.strTransactionId
                AND gd2.strBatchId = gd.strBatchId
                AND gd2.intJournalLineNo = gd.intJournalLineNo 
                AND gd2.strDescription LIKE '%' + i.strItemNo + '%'
        ) validICGL
    WHERE
        t.strTransactionId LIKE 'TRA%'
        AND gd.strCode = 'TRA'
END

-- For update strCode in GL entries for DP to DP transfers
IF EXISTS(
    SELECT TOP 1 1
	FROM tblGRTransferStorage TS
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageId = TS.intTransferStorageId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRStorageType ST_FROM
		ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
		AND ST_FROM.ysnDPOwnedType = 1
	INNER JOIN tblGRStorageType ST_TO
		ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
		AND ST_TO.ysnDPOwnedType = 1
	INNER JOIN tblGLDetail GD
		ON GD.intTransactionId = TS.intTransferStorageId
		AND GD.strTransactionId = TS.strTransferStorageTicket
		AND GD.strDescription NOT LIKE '%Charges from%'
		AND GD.strCode = 'TRA'
)
BEGIN
    UPDATE GD
        SET GD.strCode = 'IC'
    FROM tblGRTransferStorage TS
    INNER JOIN tblGRTransferStorageReference TSR
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRCustomerStorage CS_TO
        ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
        AND ST_FROM.ysnDPOwnedType = 1
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
        AND ST_TO.ysnDPOwnedType = 1
    INNER JOIN tblGLDetail GD
        ON GD.intTransactionId = TS.intTransferStorageId
        AND GD.strTransactionId = TS.strTransferStorageTicket
        AND GD.strDescription NOT LIKE '%Charges from%'
        AND GD.strCode = 'TRA'
END
PRINT 'END UPDATING strCode IN TRANSFER STORAGE GL ENTRIES'
GO