CREATE VIEW [dbo].[vyuICGetAdjustmentDetailSource]
AS

SELECT
Adjustment.intInventoryAdjustmentId,
Detail.intInventoryAdjustmentDetailId,
Adjustment.strAdjustmentNo,
Adjustment.intAdjustmentType,
intSourceId = Lot.intLotId,
strSourceTransactionNo = Lot.strLotNumber
FROM
tblICInventoryAdjustment Adjustment
INNER JOIN tblICInventoryAdjustmentDetail Detail
ON Adjustment.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
INNER JOIN tblICLot Lot
ON Lot.intLotId = COALESCE(Detail.intNewLotId, Detail.intLotId)