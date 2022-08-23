CREATE TABLE [dbo].[tblSMTerritory] (
    [intTerritoryId]			    INT IDENTITY (1, 1) NOT NULL,    
    [intRegionId]                   INT NOT NULL,
    [strTerritory]			        NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
   
    [guiApiUniqueId]                UNIQUEIDENTIFIER NULL,
    [intConcurrencyId] 		        INT CONSTRAINT [DF_tblSMTerritory_ConcurrencyId] DEFAULT ((0)) NOT NULL,	

    CONSTRAINT [PK_tblSMTerritory] PRIMARY KEY CLUSTERED ([intTerritoryId] ASC),    
	CONSTRAINT [FK_tblSMTerritory_tblSMRegion] FOREIGN KEY ([intRegionId]) REFERENCES [tblSMRegion]([intRegionId]),
	CONSTRAINT [UQ_tblSMTerritory_Region_Territory] UNIQUE ([intRegionId], [strTerritory]),
);

GO

