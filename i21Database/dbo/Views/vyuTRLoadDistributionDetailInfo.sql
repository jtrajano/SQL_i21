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
	, DD.intSiteId
	, strSiteNumber = RIGHT('0000'+CAST(S.intSiteNumber AS NVARCHAR(4)),4) COLLATE Latin1_General_CI_AS
	, DD.intTMOId
	, strTMOrder = ISNULL(TMD.strOrderNumber, TMH.strOrderNumber)
FROM tblTRLoadDistributionDetail DD
LEFT JOIN tblTRLoadDistributionHeader DH ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
LEFT JOIN vyuICGetItemLocation IL ON IL.intItemId = DD.intItemId AND IL.intLocationId = DH.intCompanyLocationId
LEFT JOIN vyuCTContractDetailView CD ON CD.intContractDetailId = DD.intContractDetailId
LEFT JOIN tblSMTaxGroup TG ON TG.intTaxGroupId = DD.intTaxGroupId
LEFT JOIN tblTMSite S ON S.intSiteID = DD.intSiteId
LEFT JOIN tblTMDispatch TMD ON TMD.intDispatchID = DD.intTMOId
LEFT JOIN tblTMDispatchHistory TMH ON TMH.intDispatchId = DD.intTMOId