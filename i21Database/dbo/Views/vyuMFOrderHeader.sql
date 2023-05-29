CREATE VIEW [dbo].[vyuMFOrderHeader]
/****************************************************************
	Title: Order Header / Pick List Order Header
	Description: Detailed Pick List Order Header
	JIRA: MFG-5056
	Created By: Jonathan Valenzuela
	Date: 05/11/2023
*****************************************************************/
AS
	SELECT OrderHeader.intOrderHeaderId
		 , OrderHeader.intOrderStatusId
		 , OrderHeader.intOrderTypeId
		 , OrderHeader.intOrderDirectionId
		 , OrderHeader.strOrderNo
		 , OrderHeader.strReferenceNo
		 , OrderHeader.intStagingLocationId
		 , OrderHeader.intDockDoorLocationId
		 , OrderHeader.strComment
		 , OrderHeader.dtmOrderDate
		 , OrderHeader.intCreatedById
		 , OrderHeader.dtmCreatedOn
		 , OrderHeader.intLastUpdateById
		 , OrderHeader.dtmLastUpdateOn
		 , WorkOrder.dtmPlannedDate						AS dtmRequiredDate
		 , OrderType.strOrderType
		 , (CASE WHEN ISNULL(Customer.strEntityNo, '') = '' THEN ''
				 ELSE Customer.strEntityNo + ' - ' + Customer.strName
			END)										AS strCustomer
		 , StagingLocation.strName						AS strStagingLocationName
		 , DockDoorLocation.strName						AS strDockDoorLocationName
		 , Item.strItemNo + ' - ' + Item.strDescription AS strItemDescription
		 , StageWorkOrder.dblPlannedQty					AS dblQuantity
		 , UnitOfMeasure.strUnitMeasure
	FROM tblMFOrderHeader AS OrderHeader
	LEFT JOIN tblMFOrderType AS OrderType ON OrderHeader.intOrderTypeId = OrderType.intOrderTypeId 
	LEFT JOIN tblMFOrderStatus AS OrderStatus ON OrderHeader.intOrderStatusId = OrderStatus.intOrderStatusId
	LEFT JOIN tblMFStageWorkOrder AS StageWorkOrder ON OrderHeader.intOrderHeaderId = StageWorkOrder.intOrderHeaderId
	LEFT JOIN tblMFWorkOrder AS WorkOrder ON StageWorkOrder.intWorkOrderId = WorkOrder.intWorkOrderId
	LEFT JOIN tblEMEntity AS Customer ON WorkOrder.intCustomerId = Customer.intEntityId
	LEFT JOIN tblICStorageLocation AS StagingLocation ON OrderHeader.intStagingLocationId = StagingLocation.intStorageLocationId
	LEFT JOIN tblICStorageLocation AS DockDoorLocation ON OrderHeader.intDockDoorLocationId = DockDoorLocation.intStorageLocationId
	LEFT JOIN tblICItem AS Item ON WorkOrder.intItemId = Item.intItemId
	LEFT JOIN tblICItemUOM AS ItemUOM ON WorkOrder.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure AS UnitOfMeasure ON ItemUOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
GO


