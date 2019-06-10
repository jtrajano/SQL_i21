CREATE VIEW [dbo].[vyuTRLoadDistributionDetailInfo]
	AS 
SELECT DD.intLoadDistributionDetailId
	, DD.intLoadDistributionHeaderId
	, DD.intItemId
	, IL.strItemNo
	, intStockUOMId = IL.intIssueUOMId
	, strStockUOM = IL.strIssueUOM
	, DD.intContractDetailId
	, CD.strContractNumber
	, DD.intTaxGroupId
	, TG.strTaxGroup
FROM tblTRLoadDistributionDetail DD
LEFT JOIN tblTRLoadDistributionHeader DH ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
LEFT JOIN vyuICGetItemLocation IL ON IL.intItemId = DD.intItemId AND IL.intLocationId = DH.intCompanyLocationId
LEFT JOIN vyuCTContractDetailView CD ON CD.intContractDetailId = DD.intContractDetailId
LEFT JOIN tblSMTaxGroup TG ON TG.intTaxGroupId = DD.intTaxGroupId 
