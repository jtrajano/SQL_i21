CREATE PROCEDURE [dbo].[uspMFGetTraceabilityInboundShipmentFromContract]
	@intContractId int
AS
SET NOCOUNT ON;

Select DISTINCT 'In Shipment' AS strTransactionName,s.intLoadId,s.strLoadNumber,'' AS strLotAlias,0 intItemId,'' strItemNo,'' strDescription,
0 intCategoryId,'' strCategoryCode,s.dblQuantity,
s.strUnitMeasure strUOM,
NULL AS dtmTransactionDate,0 intParentLotId,s.strVendor,'IS' AS strType
from vyuLGLoadContainerReceiptContracts s Join tblLGLoad l on s.intLoadId=l.intLoadId 
Where s.intPContractHeaderId=@intContractId AND l.intShipmentType=1
