CREATE TABLE [dbo].[tblARSalespersonRegion] (
    [intSalespersonRegionId]		INT                 IDENTITY (1, 1) NOT NULL,
    [intEntitySalespersonId]        INT                 NOT NULL,
    [intRegionId]			        INT				    NULL,
    
    [intConcurrencyId]              INT                 DEFAULT(1) NOT NULL,
    [guiApiUniqueId]                UNIQUEIDENTIFIER    NULL,

    CONSTRAINT [PK_tblARSalespersonRegion] PRIMARY KEY CLUSTERED ([intSalespersonRegionId] ASC),
	CONSTRAINT [FK_tblARSalespersonRegion_tblARSalesperson] FOREIGN KEY ([intEntitySalespersonId]) REFERENCES [tblARSalesperson]([intEntityId]),
	CONSTRAINT [FK_tblARSalespersonRegion_tblSMRegion] FOREIGN KEY ([intRegionId]) REFERENCES [tblSMRegion]([intRegionId]),
	CONSTRAINT [UQ_tblARSalespersonRegion_entitySalespersonId_regionId] UNIQUE NONCLUSTERED ([intEntitySalespersonId] ASC, intRegionId)
	
);


