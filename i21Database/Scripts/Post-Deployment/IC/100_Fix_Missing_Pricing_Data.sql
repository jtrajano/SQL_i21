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

DECLARE @InvalidPricing TABLE (
    [Item No] NVARCHAR(300),
    [Item Id] INT,
    [Pricing Level Id] INT,
    [Pricing Location] NVARCHAR(300),
    [Pricing Location Id] INT,
    [Pricing Level] NVARCHAR(300),
    [Lookup Level] NVARCHAR(300) NULL,
    [Lookup Pricing Level Id] INT NULL,
    [Lookup Location] NVARCHAR(300) NULL,
    [Lookup Location Id] INT NULL,
    [Proposed Pricing Level Id] INT NULL)

INSERT INTO @InvalidPricing
select 
      i.strItemNo [Item No]
    , i.intItemId [Item Id]
    , pl.intItemPricingLevelId [Pricing Level Id]
    , cl.strLocationName [Pricing Location]
    , il.intLocationId [Pricing Location Id]
    , pl.strPriceLevel [Pricing Level]
    , cpl.strPricingLevelName [Lookup Level]
    , pl.intCompanyLocationPricingLevelId [Lookup Pricing Level Id]
    , c2.strLocationName [Lookup Location]
    , c2.intCompanyLocationId [Lookup Location Id]
    , equivalent.intCompanyLocationPricingLevelId [Proposed Pricing Level Id]
from tblICItemPricingLevel pl
join tblICItem i on i.intItemId = pl.intItemId
join tblICItemLocation il on pl.intItemId = il.intItemId and pl.intItemLocationId = il.intItemLocationId
join tblSMCompanyLocation cl on cl.intCompanyLocationId = il.intLocationId
left join tblSMCompanyLocationPricingLevel cpl ON cpl.intCompanyLocationId = cl.intCompanyLocationId
    and cpl.intCompanyLocationPricingLevelId = pl.intCompanyLocationPricingLevelId
left join tblSMCompanyLocationPricingLevel cpl2 on cpl2.intCompanyLocationPricingLevelId = pl.intCompanyLocationPricingLevelId
left join tblSMCompanyLocation c2 on c2.intCompanyLocationId = cpl2.intCompanyLocationId
outer apply (
    SELECT TOP 1 xl.intCompanyLocationPricingLevelId
    FROM tblSMCompanyLocationPricingLevel xl
    WHERE xl.intCompanyLocationId = il.intLocationId
        AND LTRIM(RTRIM(LOWER(xl.strPricingLevelName))) = LTRIM(RTRIM(LOWER(pl.strPriceLevel)))
) equivalent
where cpl.strPricingLevelName IS NULL

-- Fix and match
UPDATE p
SET p.intCompanyLocationPricingLevelId = ip.[Proposed Pricing Level Id]
FROM tblICItemPricingLevel p
JOIN @InvalidPricing ip ON ip.[Pricing Level Id] = p.intItemPricingLevelId
WHERE ip.[Proposed Pricing Level Id] IS NOT NULL

PRINT 'Update outdated pricing level names...done'