﻿UPDATE tblCTCompanyPreference
SET ysnFreightTermCost = ISNULL(ysnFreightTermCost, 0)
	, ysnAutoCalculateFreightTermCost = ISNULL(ysnAutoCalculateFreightTermCost, 0)
	, ysnEnableRankShippingLine = ISNULL(ysnEnableRankShippingLine, 0)