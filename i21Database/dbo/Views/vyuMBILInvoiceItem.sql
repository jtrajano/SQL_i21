CREATE VIEW [dbo].[vyuMBILInvoiceItem]
	AS
	
SELECT InvoiceSite.*
	, InvoiceItem.intInvoiceItemId
	, InvoiceItem.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, InvoiceItem.intItemUOMId
	, UOM.strUnitMeasure
	, InvoiceItem.dblQuantity
	, InvoiceItem.dblPrice
	, InvoiceItem.intContractDetailId
	, ContractHeader.strContractNumber
	, ContractDetail.intContractSeq
FROM tblMBILInvoiceItem InvoiceItem
LEFT JOIN vyuMBILInvoiceSite InvoiceSite ON InvoiceSite.intInvoiceSiteId = InvoiceItem.intInvoiceSiteId
LEFT JOIN tblICItem Item ON Item.intItemId = InvoiceItem.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InvoiceItem.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = InvoiceItem.intContractDetailId
LEFT JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId