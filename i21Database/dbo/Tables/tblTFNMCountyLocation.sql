CREATE TABLE [dbo].[tblTFNMCountyLocation]
(
    [intCompanyLocationId] INT  IDENTITY (1, 1) NOT NULL,
    [strCounty] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    CONSTRAINT [PK_tblTFNMCountyLocation] PRIMARY KEY ([intCompanyLocationId])
)
