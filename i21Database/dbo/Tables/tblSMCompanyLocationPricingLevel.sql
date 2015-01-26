CREATE TABLE [dbo].[tblSMCompanyLocationPricingLevel]
(
	[intCompanyLocationPricingLevelId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[intCompanyLocationId] INT NOT NULL, 
    [strPricingLevelName] NCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMCompanyLocationPricingLevel_tblSMCompanyLocation] FOREIGN KEY (intCompanyLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId)
)
