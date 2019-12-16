
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICItemPricingLevel]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'intCompanyLocationPricingLevelId' AND OBJECT_ID = OBJECT_ID(N'tblICItemPricingLevel')) 
    BEGIN
		EXEC('ALTER TABLE [tblICItemPricingLevel] ADD [intCompanyLocationPricingLevelId] INT NULL')
    END

	BEGIN 
		EXEC ('
			UPDATE ipl
			SET 
				ipl.[intCompanyLocationPricingLevelId] = spl.intCompanyLocationPricingLevelId	
			FROM 
				tblICItemPricingLevel ipl LEFT JOIN tblICItemLocation il
					ON ipl.intItemLocationId = il.intItemLocationId	
				LEFT JOIN tblSMCompanyLocation cl
					ON cl.intCompanyLocationId = il.intLocationId
				LEFT JOIN tblSMCompanyLocationPricingLevel spl 
					ON spl.strPricingLevelName = ipl.strPriceLevel
					AND spl.intCompanyLocationId = il.intLocationId
			WHERE
				ipl.intCompanyLocationPricingLevelId IS NULL 
				AND spl.strPricingLevelName IS NOT NULL 		
		')
	END 
END 
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICItemPricingLevel]') AND type in (N'U')) 
BEGIN 
	EXEC(
		'IF EXISTS (SELECT TOP 1 1 FROM tblICItemPricingLevel WHERE intCompanyLocationPricingLevelId IS NULL)
		RAISERROR(''Please contact IC team. Auto data fix for item pricing failed. It needs a custom data fix before upgrading to this build.'', 16, 1);'
	)
END

GO
