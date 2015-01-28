CREATE TABLE [dbo].[tblSMCompanyLocationSubLocationCategory]
(
	[intCompanyLocationSubLocationCategoryId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intCompanyLocationSubLocationId] INT NOT NULL, 
    [intCategoryId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMCompanyLocationSubLocationCategory_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES tblSMCompanyLocationSubLocation([intCompanyLocationSubLocationId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMCompanyLocationSubLocationCategory_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES tblICCategory(intCategoryId) 
)
