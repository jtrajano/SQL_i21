CREATE TABLE [dbo].[tblSMCompanyLocationSubLocation]
(
	[intCompanyLocationSubLocationId] INT NOT NULL IDENTITY , 
    [strSubLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strSubLocationDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strClassification] NVARCHAR(50) NOT NULL, 
    [strAddressKey] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSMCompanyLocationSubLocation] PRIMARY KEY ([intCompanyLocationSubLocationId])
)
