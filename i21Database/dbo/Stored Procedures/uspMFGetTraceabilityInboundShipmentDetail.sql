CREATE PROCEDURE [dbo].[uspMFGetTraceabilityInboundShipmentDetail]
	@intShipmentId int,
	@intDirectionId int
AS

SET NOCOUNT ON;

	Select DISTINCT 'In Shipment' AS strTransactionName,s.intShipmentId,CONVERT(varchar,s.intTrackingNumber) + ' / ' + CONVERT(varchar,s.strBLNumber),'' AS strLotAlias,0 intItemId,'' strItemNo,'' strDescription,
	0 intCategoryId,'' strCategoryCode,SUM(s.dblQuantity),
	s.strUnitMeasure strUOM,
	NULL AS dtmTransactionDate,s.strVendor,'IS' AS strType
	from vyuLGShipmentContainerReceiptContracts s
	Where s.intShipmentId=@intShipmentId
	Group By intShipmentId,intTrackingNumber,strBLNumber,strUnitMeasure,strVendor
