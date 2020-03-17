CREATE VIEW [dbo].[vyuRKGetM2MCounterPartyExposure]

AS

SELECT cep.intM2MCounterPartyExposureId
    , cep.intM2MHeaderId
    , cep.intVendorId
	, strVendorName = e.strName
    , cep.strRating
    , cep.dblFixedPurchaseVolume
	, cep.dblUnfixedPurchaseVolume
	, cep.dblTotalCommittedVolume
	, cep.dblFixedPurchaseValue
	, cep.dblUnfixedPurchaseValue
	, cep.dblTotalCommittedValue
	, cep.dblTotalSpend
	, cep.dblShareWithSupplier
	, cep.dblMToM
	, cep.dblPotentialAdditionalVolume
	, cep.intConcurrencyId
FROM tblRKM2MCounterPartyExposure cep
LEFT JOIN tblEMEntity e ON e.intEntityId = cep.intVendorId