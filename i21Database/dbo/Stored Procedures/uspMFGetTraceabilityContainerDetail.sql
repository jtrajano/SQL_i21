CREATE PROCEDURE [dbo].[uspMFGetTraceabilityContainerDetail]
	@intContainerId int,
	@intDirectionId int
AS

SET NOCOUNT ON;

	Select DISTINCT 'Container' AS strTransactionName,s.intLoadContainerId,s.strContainerNumber,'' AS strLotAlias,s.intItemId,s.strItemNo,s.strItemDescription,
	0 intCategoryId,'' strCategoryCode,s.dblQuantity,
	s.strUnitMeasure strUOM,
	NULL AS dtmTransactionDate,s.intLoadId AS intParentLotId,s.strVendor,'CN' AS strType
	from vyuLGLoadContainerReceiptContracts s
	Where s.intLoadContainerId=@intContainerId

