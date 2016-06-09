CREATE PROCEDURE [dbo].[uspMFGetTraceabilityInboundShipmentDetail]
	@intShipmentId int,
	@intDirectionId int
AS

SET NOCOUNT ON;

	Select DISTINCT 'In Shipment' AS strTransactionName,s.intLoadId,s.strLoadNumber,'' AS strLotAlias,0 intItemId,'' strItemNo,'' strDescription,
	0 intCategoryId,'' strCategoryCode,s.dblQuantity,
	s.strUnitMeasure strUOM,
	NULL AS dtmTransactionDate,s.strVendor,'IS' AS strType
	from vyuLGLoadContainerReceiptContracts s
	Where s.intLoadId=@intShipmentId
