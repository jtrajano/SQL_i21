CREATE PROCEDURE dbo.uspApiForwardWorkOrders (@guiApiUniqueId UNIQUEIDENTIFIER)
AS

INSERT INTO tblApiRESTErrorLog(guiApiUniqueId, strError, strField, strValue, strLogLevel)
SELECT @guiApiUniqueId, 'Invalid itemId', 'itemId', CAST(c.intItemId AS NVARCHAR(50)), 'Error'
FROM tblApiCompletedWorkOrderStocked c WITH (NOLOCK)
LEFT JOIN tblICItem i ON i.intItemId = c.intItemId
WHERE c.guiApiUniqueId = @guiApiUniqueId
AND i.intItemId IS NULL

INSERT INTO tblApiRESTErrorLog(guiApiUniqueId, strError, strField, strValue, strLogLevel)
SELECT @guiApiUniqueId, 'Invalid locationId', 'locationId', CAST(c.intLocationId AS NVARCHAR(50)), 'Error'
FROM tblApiCompletedWorkOrderStocked c WITH (NOLOCK)
LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = c.intLocationId
WHERE c.guiApiUniqueId = @guiApiUniqueId
AND l.intCompanyLocationId IS NULL

INSERT INTO tblApiRESTErrorLog(guiApiUniqueId, strError, strField, strValue, strLogLevel)
SELECT @guiApiUniqueId, 'Invalid itemUOMId', 'itemUOMId', CAST(c.intItemUOMId AS NVARCHAR(50)), 'Error'
FROM tblApiCompletedWorkOrderStocked c WITH (NOLOCK)
LEFT JOIN tblICItemUOM l ON l.intItemUOMId = c.intItemUOMId
WHERE c.guiApiUniqueId = @guiApiUniqueId
AND l.intItemUOMId IS NULL

INSERT INTO tblApiRESTErrorLog(guiApiUniqueId, strError, strField, strValue, strLogLevel)
SELECT @guiApiUniqueId, 'Invalid storageLocationId', 'storageLocationId', CAST(c.intStorageLocationId AS NVARCHAR(50)), 'Error'
FROM tblApiCompletedWorkOrderStocked c WITH (NOLOCK)
LEFT JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = c.intStorageLocationId
WHERE c.guiApiUniqueId = @guiApiUniqueId
AND l.intCompanyLocationSubLocationId IS NULL

INSERT INTO tblApiRESTErrorLog(guiApiUniqueId, strError, strField, strValue, strLogLevel)
SELECT @guiApiUniqueId, 'Invalid storageUnitId', 'storageUnitId', CAST(c.intStorageUnitId AS NVARCHAR(50)), 'Error'
FROM tblApiCompletedWorkOrderStocked c WITH (NOLOCK)
LEFT JOIN tblICStorageLocation l ON l.intStorageLocationId = c.intStorageUnitId
WHERE c.guiApiUniqueId = @guiApiUniqueId
AND l.intStorageLocationId IS NULL

INSERT tblAPIWODetail (
	guiApiUniqueId,
    intBatchId,
    intItemId,
    dblQuantity,
    intQtyItemUOMId,
    intStorageLocationId,
    intSubLocationId,
    strLotNumber,
    intTransactionTypeId,
    strUserName,
    dtmDate,
    intCompanyLocationId,
    ysnProcessed,
    strWorkOrderNo,
    strMessage,
    strFeedStatus,
    ysnCompleted
)
SELECT
	@guiApiUniqueId,
    c.intBatchId,
    c.intItemId,
    c.dblQuantity,
	c.intItemUOMId,
	c.intStorageUnitId,
	c.intStorageLocationId,
	c.strLotNumber,
	c.intTransactionTypeId,
	c.strUserName,
	c.dtmDate,
	c.intLocationId,
	ISNULL(c.ysnProcessed, 0),
	c.strWorkOrderNo,
	c.strMessage,
	c.strFeedStatus,
	ISNULL(c.ysnCompleted, 0)
FROM tblApiCompletedWorkOrderStocked c WITH (NOLOCK)
WHERE c.guiApiUniqueId = @guiApiUniqueId

EXEC dbo.uspAPIProcessWorkOrder @guiApiUniqueId
EXEC dbo.uspAPIGetCompletedWorkOrder @guiApiUniqueId, ''

INSERT INTO tblApiRESTErrorLog (guiApiUniqueId, strError, strLogLevel)
SELECT @guiApiUniqueId, strMessage, 'Error'
FROM tblAPIWODetail d
WHERE d.guiApiUniqueId = @guiApiUniqueId
	AND d.ysnProcessed = 1
    AND d.strFeedStatus = 'Failed'

INSERT INTO tblApiRESTErrorLog (guiApiUniqueId, strValue, strError, strLogLevel, intLinePosition, intLineNumber)
SELECT @guiApiUniqueId, d.strWorkOrderNo, strMessage, 'Success', d.intItemId, wo.intWorkOrderId
FROM tblAPIWODetail d
JOIN tblMFWorkOrder wo ON wo.strWorkOrderNo = d.strWorkOrderNo
WHERE d.guiApiUniqueId = @guiApiUniqueId
	AND d.ysnProcessed = 1
    AND d.ysnCompleted = 1
    AND d.strFeedStatus = 'Success'