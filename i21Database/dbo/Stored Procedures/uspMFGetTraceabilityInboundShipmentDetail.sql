CREATE PROCEDURE [dbo].[uspMFGetTraceabilityInboundShipmentDetail]
	@intShipmentId int,
	@intDirectionId int
AS

SET NOCOUNT ON;

	Select DISTINCT 'In Shipment' AS strTransactionName,s.intLoadId,s.strLoadNumber,'' AS strLotAlias,0 intItemId,'' strItemNo,'' strDescription,
	0 intCategoryId,'' strCategoryCode,s.dblQuantity,
	s.strUnitMeasure strUOM,
	NULL AS dtmTransactionDate,s.strVendor,'IS' AS strType
	from vyuLGLoadContainerReceiptContracts s Join tblLGLoad l on s.intLoadId=l.intLoadId 
	Where s.intLoadId=@intShipmentId AND l.intShipmentType=1
