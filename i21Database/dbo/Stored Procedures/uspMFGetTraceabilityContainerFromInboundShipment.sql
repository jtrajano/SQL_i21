CREATE PROCEDURE [dbo].[uspMFGetTraceabilityContainerFromInboundShipment]
	@intShipmentId int
AS
SET NOCOUNT ON;

Select DISTINCT 'Container' AS strTransactionName,s.intShipmentBLContainerId,s.strContainerNumber,'' AS strLotAlias,s.intItemId,s.strItemNo,s.strItemDescription,
0 intCategoryId,'' strCategoryCode,s.dblQuantity,
s.strUnitMeasure strUOM,
NULL AS dtmTransactionDate,s.intShipmentId AS intParentLotId,s.strVendor,'CN' AS strType
from vyuLGShipmentContainerReceiptContracts s
Where s.intShipmentId=@intShipmentId
