﻿CREATE VIEW [dbo].[vyuMBILInvoiceItem]
	AS
	
SELECT Invoice.intInvoiceId
	,Invoice.strInvoiceNo
	,Invoice.intOrderId
	,Invoice.strOrderNumber
	,Invoice.intEntityCustomerId
	,Invoice.strCustomerNo
	,Invoice.strCustomerName
	,Invoice.intLocationId
	,Invoice.strLocationName
	,Invoice.strType
	,Invoice.dtmDeliveryDate
	,Invoice.dtmInvoiceDate
	,Invoice.intDriverId
	,Invoice.strDriverNo
	,Invoice.strDriverName
	,Invoice.intShiftId
	,Invoice.intShiftNumber
	,Invoice.strShiftNo
	,Invoice.strComments
	,Invoice.strVoidComments
	,Invoice.dblTotal
	,Invoice.intTermId
	,Invoice.strTerm
	,Invoice.ysnPosted
	,Invoice.ysnVoided
	,Invoice.dtmPostedDate
	,Invoice.dtmVoidedDate
	,Invoice.intPaymentMethodId
	,Invoice.strPaymentMethod
	,Invoice.strPaymentInfo
	,Invoice.inti21InvoiceId
	,Invoice.stri21InvoiceNo
	,Invoice.intConcurrencyId
	,Invoice.strStatus
	,Invoice.dblTotalTaxAmount
	,Invoice.dblTotalBefTax
	,Invoice.strAccountStatus
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
	, isnull(InvoiceItem.dblTaxTotal,0)dblTaxTotal
	, isnull(InvoiceItem.dblItemTotal,0)dblItemTotal
	--, isnull(tax.dblRate,0)dblRate
	--, tax.strCalculationMethod
	, InvoiceItem.intDispatchId
FROM tblMBILInvoiceItem InvoiceItem
LEFT JOIN vyuMBILInvoice Invoice ON Invoice.intInvoiceId = InvoiceItem.intInvoiceId
LEFT JOIN tblICItem Item ON Item.intItemId = InvoiceItem.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InvoiceItem.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = InvoiceItem.intContractDetailId
LEFT JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId
LEFT JOIN tblARInvoiceDetail i21InvoiceDetail ON i21InvoiceDetail.intInvoiceDetailId = InvoiceItem.inti21InvoiceDetailId
LEFT JOIN vyuMBILSite Site ON Site.intSiteId = InvoiceItem.intSiteId
--LEFT JOIN (
--			SELECT intInvoiceItemId,sum(dblRate)dblRate,strCalculationMethod
--		    FROM tblMBILInvoiceTaxCode 
--			GROUP BY intInvoiceItemId)tax on InvoiceItem.intInvoiceItemId = tax.intInvoiceItemId
