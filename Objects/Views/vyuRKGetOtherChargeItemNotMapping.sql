CREATE VIEW vyuRKGetOtherChargeItemNotMapping

AS

SELECT c.intM2MConfigurationId
	, c.intFreightTermId
	, c.intItemId
	, strItemNo
	, strFreightTerm
	, 0 as intConcurrencyId
FROM tblRKM2MConfiguration  c
JOIN tblICItem i on i.intItemId = c.intItemId
JOIN tblSMFreightTerms ft on ft.intFreightTermId = c.intFreightTermId