CREATE VIEW [dbo].[vyuTRGetLoadDistributionDetail]
	AS

SELECT DistDetail.intLoadDistributionDetailId
	, DistDetail.intLoadDistributionHeaderId
	, Header.intLoadHeaderId
	, Header.strTransaction
	, DistDetail.intItemId
	, ItemLocation.strItemNo
	, strItemDescription = ItemLocation.strDescription
	, intStockUOMId = ItemLocation.intIssueUOMId
	, strStockUOM = ItemLocation.strIssueUOM
	, DistDetail.intContractDetailId
	, Contract.strContractNumber
	, DistDetail.dblUnits
	, DistDetail.dblPrice
	, DistDetail.dblFreightRate
	, DistDetail.dblDistSurcharge
	, DistDetail.ysnFreightInPrice
	, DistDetail.intTaxGroupId
	, TaxGroup.strTaxGroup
	, DistDetail.strReceiptLink
	, DistDetail.intLoadDetailId
FROM tblTRLoadDistributionDetail DistDetail
LEFT JOIN tblTRLoadDistributionHeader DistHeader ON DistHeader.intLoadDistributionHeaderId = DistDetail.intLoadDistributionHeaderId
LEFT JOIN tblTRLoadHeader Header ON Header.intLoadHeaderId = DistHeader.intLoadHeaderId
LEFT JOIN vyuICGetItemLocation ItemLocation ON ItemLocation.intItemId = DistDetail.intItemId AND ItemLocation.intLocationId = DistHeader.intCompanyLocationId
LEFT JOIN vyuCTContractDetailView Contract ON Contract.intContractDetailId = DistDetail.intContractDetailId
LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = DistDetail.intTaxGroupId 