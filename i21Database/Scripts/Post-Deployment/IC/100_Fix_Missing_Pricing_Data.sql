-- Sync Pricing
PRINT 'Recreating missing item pricing data...';

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICSyncItemLocationPricing]') AND type in (N'P', N'PC'))
	EXEC [dbo].[uspICSyncItemLocationPricing]

PRINT 'Recreating missing item pricing data...done.';

PRINT 'Update outdated pricing level names'

UPDATE p
SET p.strPriceLevel = cp.strPricingLevelName
FROM tblICItemPricingLevel p
	INNER JOIN vyuICGetItemPricingLevel v ON v.intItemPricingLevelId = p.intItemPricingLevelId
	INNER JOIN tblSMCompanyLocationPricingLevel cp ON cp.intCompanyLocationPricingLevelId = v.intCompanyLocationPricingLevelId

PRINT 'Update outdated pricing level names...done'