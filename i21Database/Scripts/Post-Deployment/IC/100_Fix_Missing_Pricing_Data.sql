-- Sync Pricing
PRINT 'Recreating missing item pricing data...';

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICSyncItemLocationPricing]') AND type in (N'P', N'PC'))
	EXEC [dbo].[uspICSyncItemLocationPricing]

PRINT 'Recreating missing item pricing data...done.';