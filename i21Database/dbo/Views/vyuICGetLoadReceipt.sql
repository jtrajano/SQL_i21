CREATE VIEW [dbo].[vyuICGetLoadReceipt]
AS

SELECT Receipt.intLoadReceiptId
	, dblOrderedQuantity  = CASE WHEN ISNULL(LoadSchedule.dblQuantity,0) = 0 AND SupplyPoint.strGrossOrNet = 'Net' THEN Receipt.dblNet
								WHEN ISNULL(LoadSchedule.dblQuantity,0) = 0 AND SupplyPoint.strGrossOrNet = 'Gross' THEN Receipt.dblGross
								WHEN ISNULL(LoadSchedule.dblQuantity,0) <> 0 THEN LoadSchedule.dblQuantity END
FROM tblTRLoadReceipt Receipt
LEFT JOIN tblTRSupplyPoint SupplyPoint ON SupplyPoint.intSupplyPointId = Receipt.intSupplyPointId
LEFT JOIN vyuICLoadContainers LoadSchedule ON LoadSchedule.intLoadDetailId = Receipt.intLoadDetailId