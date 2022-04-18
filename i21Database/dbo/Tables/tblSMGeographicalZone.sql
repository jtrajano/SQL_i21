CREATE TABLE [dbo].[tblSMGeographicalZone]
(
	[intGeographicalZoneId]		INT NOT NULL PRIMARY KEY IDENTITY, 
    [strName]					NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription]			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId]			INT NOT NULL DEFAULT 1, 

    CONSTRAINT [AK_tblSMGeographicalZone_strName] UNIQUE ([strName])
)
