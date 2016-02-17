CREATE PROCEDURE [dbo].[uspMFGetTraceabilityInboundShipmentFromContract]
	@intContractId int
AS
SET NOCOUNT ON;

Select DISTINCT 'In Shipment' AS strTransactionName,s.intShipmentId,CONVERT(varchar,s.intTrackingNumber) + ' / ' + CONVERT(varchar,s.strBLNumber),'' AS strLotAlias,0 intItemId,'' strItemNo,'' strDescription,
0 intCategoryId,'' strCategoryCode,SUM(s.dblQuantity),
s.strUnitMeasure strUOM,
NULL AS dtmTransactionDate,0 intParentLotId,s.strVendor,'IS' AS strType
from vyuLGShipmentContainerReceiptContracts s
Where s.intContractHeaderId=@intContractId
Group By intShipmentId,intTrackingNumber,strBLNumber,strUnitMeasure,strVendor
