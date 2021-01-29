CREATE VIEW [dbo].[vyuMBILInvoiceItem]
	AS
	
SELECT Invoice.*
	, InvoiceItem.intInvoiceItemId
	, InvoiceItem.intSiteId
	, Site.intSiteNumber
	, Site.strSiteDescription
	, Site.strSiteAddress
	, Site.strCity
	, Site.strState
	, Site.strZipCode
	, Site.strCountry
	, strSiteStatus = dbo.fnMBILGetInvoiceStatus(NULL, InvoiceItem.intSiteId) COLLATE Latin1_General_CI_AS
	, InvoiceItem.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, InvoiceItem.intItemUOMId
	, UOM.strUnitMeasure
	, InvoiceItem.dblQuantity
	, InvoiceItem.dblPrice
	, InvoiceItem.dblPercentageFull
	, InvoiceItem.intContractDetailId
	, ContractHeader.strContractNumber
	, ContractDetail.intContractSeq
	, inti21InvoiceDetailId = InvoiceItem.inti21InvoiceDetailId
FROM tblMBILInvoiceItem InvoiceItem
LEFT JOIN vyuMBILInvoice Invoice ON Invoice.intInvoiceId = InvoiceItem.intInvoiceId
LEFT JOIN tblICItem Item ON Item.intItemId = InvoiceItem.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InvoiceItem.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = InvoiceItem.intContractDetailId
LEFT JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId
LEFT JOIN tblARInvoiceDetail i21InvoiceDetail ON i21InvoiceDetail.intInvoiceDetailId = InvoiceItem.inti21InvoiceDetailId
LEFT JOIN vyuMBILSite Site ON Site.intSiteId = InvoiceItem.intSiteId