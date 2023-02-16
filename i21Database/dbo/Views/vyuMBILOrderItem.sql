CREATE VIEW [dbo].[vyuMBILOrderItem]
	AS

SELECT [Order].intOrderId
	, [Order].strOrderNumber
	, [Order].strOrderStatus
	, [Order].dtmRequestedDate
	, [Order].intEntityId
	, [Order].strCustomerNumber
	, [Order].strCustomerName
	, [Order].intTermId
	, [Order].strTerm
	, [Order].strComments
	, [Order].intDriverId
	, [Order].strDriverNo
	, [Order].strDriverName
	, [Order].intRouteId
	, [Order].strRouteId
	, [Order].intSequence
	, [Order].intStopNumber
	, OrderItem.intSiteId
	, Site.intSiteNumber
	, strSiteDescription = Site.strDescription
	, case when RTRIM(
		LTRIM(
		  REPLACE(
			ISNULL(Site.strSiteAddress  , ''), 
			CHAR(10), 
			''
		  )
		)
	  ) <> '' then RTRIM(
		LTRIM(
		  REPLACE(
			REPLACE(
			  REPLACE(
				REPLACE(
				  REPLACE(
					REPLACE(
					  ISNULL(Site.strSiteAddress  , ''), 
					  CHAR(10), 
					  ''
					), 
					'''', 
					'.'
				  ), 
				  '\"', 
				  '.'
				), 
				CHAR(92), 
				''
			  ), 
			  '/', 
			  '.'
			), 
			CHAR(9), 
			''
		  )
		)
	  ) else '.' end strSiteAddress
	, Site.strCity
	, Site.strState
	, Site.strZipCode
	, OrderItem.intOrderItemId
	, OrderItem.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, OrderItem.intContractDetailId
	, ContractHeader.strContractNumber
	, ContractDetail.intContractSeq
	, OrderItem.intItemUOMId
	, strUOM = UOM.strUnitMeasure
	, OrderItem.dblQuantity
	, OrderItem.dblPrice
	, dblTotal = (OrderItem.dblQuantity * OrderItem.dblPrice)
FROM tblMBILOrderItem OrderItem
LEFT JOIN vyuMBILOrder [Order] ON [Order].intOrderId = OrderItem.intOrderId
LEFT JOIN tblICItem Item ON Item.intItemId = OrderItem.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = OrderItem.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblTMSite Site ON Site.intSiteID = OrderItem.intSiteId
LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = OrderItem.intContractDetailId
LEFT JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId