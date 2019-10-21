﻿CREATE VIEW vyuRKGetM2MConfigurationMapping

AS

SELECT c.intM2MConfigurationId
	, i.intItemId
	, i.strItemNo
	, c.intFreightTermId
	, ft.strFreightTerm
	, c.intConcurrencyId
	, strAdjustmentType
	, strContractType
FROM tblRKM2MConfiguration c
JOIN tblICItem i on c.intItemId = i.intItemId
JOIN tblSMFreightTerms ft on ft.intFreightTermId = c.intFreightTermId