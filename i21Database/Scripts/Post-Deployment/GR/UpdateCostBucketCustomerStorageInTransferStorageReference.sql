BEGIN TRY
    DROP FUNCTION dbo.fnGRGetCostBucketForDPtoDP_GRN2731;
END TRY
BEGIN CATCH
    -- PRINT 'Function fnGRGetCostBucketForDPtoDP_GRN2731 does not exist.';
END CATCH

GO

-- Create recursive function to get the customer storage with cost bucket for DP to DP transfers.
CREATE FUNCTION [dbo].[fnGRGetCostBucketForDPtoDP_GRN2731] (@intTransferStorageReferenceId INT)
RETURNS INT AS
BEGIN
    DECLARE @intCustomerStorageId INT, @intSourceTransferStorageReferenceId INT;

    SELECT TOP 1 @intCustomerStorageId = CS_FROM.intCustomerStorageId
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRCustomerStorage CS_FROM ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRCustomerStorage CS_TO ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_FROM ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId AND ST_FROM.ysnDPOwnedType = 1
    INNER JOIN tblGRStorageType ST_TO ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId AND ST_TO.ysnDPOwnedType = 1
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId

    -- Source transaction of the DP if it came from IR (Ticket)
    IF EXISTS (
        SELECT TOP 1 1
        FROM tblGRStorageHistory SH
        INNER JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SH.intCustomerStorageId
        INNER JOIN tblICInventoryReceipt IR ON SH.intInventoryReceiptId = IR.intInventoryReceiptId
        INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId AND IRI.intItemId = CS.intItemId
        WHERE CS.ysnTransferStorage = 0
        AND CS.intCustomerStorageId = @intCustomerStorageId
    )
    BEGIN
        RETURN @intCustomerStorageId;
    END

     -- Source transaction of the DP if it came from IR (Delivery Sheet)
    IF EXISTS (
        SELECT TOP 1 1
        FROM tblGRStorageInventoryReceipt
        WHERE intCustomerStorageId = @intCustomerStorageId
    )
    BEGIN
        RETURN @intCustomerStorageId;
    END

    -- Source transaction of the DP if it came from Transfer storage (OS to DP)
    IF EXISTS (
        SELECT TOP 1 1
        FROM tblGRTransferStorageReference TSR
        INNER JOIN tblGRTransferStorage TS ON TS.intTransferStorageId = TSR.intTransferStorageId
        INNER JOIN tblGRCustomerStorage CS_FROM ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
        INNER JOIN tblGRCustomerStorage CS_TO ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
        INNER JOIN tblGRStorageType ST_FROM ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId AND ST_FROM.ysnDPOwnedType = 0
        INNER JOIN tblGRStorageType ST_TO ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId AND ST_TO.ysnDPOwnedType = 1
        AND CS_TO.intCustomerStorageId = @intCustomerStorageId
    )
    BEGIN
        RETURN @intCustomerStorageId;
    END

    SELECT @intSourceTransferStorageReferenceId = intTransferStorageReferenceId
    FROM tblGRTransferStorageReference
    WHERE intToCustomerStorageId = @intCustomerStorageId

    RETURN dbo.fnGRGetCostBucketForDPtoDP_GRN2731(@intSourceTransferStorageReferenceId);
END

GO

PRINT 'BEGIN update of Cost Bucket Customer Storage in tblGRTransferStorageReference'

IF EXISTS (
    SELECT TOP 1 1
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRCustomerStorage CS_FROM ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRCustomerStorage CS_TO ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_FROM ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId AND ST_FROM.ysnDPOwnedType = 1
    INNER JOIN tblGRStorageType ST_TO ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId AND ST_TO.ysnDPOwnedType = 1
    WHERE TSR.intCostBucketCustomerStorageId IS NULL
)
BEGIN

    DECLARE @intTransferStorageReferenceId INT;
    
    BEGIN TRAN
        DECLARE CC CURSOR LOCAL FAST_FORWARD
        FOR
        SELECT TSR.intTransferStorageReferenceId
        FROM tblGRTransferStorageReference TSR
        INNER JOIN tblGRCustomerStorage CS_FROM ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
        INNER JOIN tblGRCustomerStorage CS_TO ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
        INNER JOIN tblGRStorageType ST_FROM ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId AND ST_FROM.ysnDPOwnedType = 1
        INNER JOIN tblGRStorageType ST_TO ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId AND ST_TO.ysnDPOwnedType = 1
        WHERE TSR.intCostBucketCustomerStorageId IS NULL
        
        OPEN CC;
        FETCH CC INTO @intTransferStorageReferenceId;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE tblGRTransferStorageReference
            SET intCostBucketCustomerStorageId = dbo.fnGRGetCostBucketForDPtoDP_GRN2731(@intTransferStorageReferenceId)
            WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId;

            FETCH CC INTO @intTransferStorageReferenceId;
        END
        CLOSE CC; DEALLOCATE CC;
    COMMIT TRAN

END

GO

DROP FUNCTION dbo.fnGRGetCostBucketForDPtoDP_GRN2731

GO

PRINT 'END update of Cost Bucket Customer Storage in tblGRTransferStorageReference'

GO