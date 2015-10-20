CREATE TABLE [dbo].[tblPATCustomerVolume]
(
	[intCategoryVolumeId] INT NOT NULL IDENTITY, 
    [intCustomerPatronId] INT NULL, 
    [intPatronageCategoryId] INT NULL, 
    [intFiscalYear] INT NULL, 
	[dtmLastActivityDate] DATETIME NULL,
    [dblVolume] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATCategoryVolume] PRIMARY KEY ([intCategoryVolumeId]) 
)
