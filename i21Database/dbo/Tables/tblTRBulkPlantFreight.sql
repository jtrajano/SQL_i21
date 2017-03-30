CREATE TABLE [dbo].[tblTRBulkPlantFreight] (
    [intBulkPlantFreightId]  INT             IDENTITY (1, 1) NOT NULL,  
	[intCompanyLocationId]		INT			NULL,
	[strZipCode]				NVARCHAR (12)   COLLATE Latin1_General_CI_AS NULL,
    [intCategoryId]      INT				NULL,
    [strFreightType]    NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[intShipViaId]       INT				NULL,
    [dblFreightAmount]  NUMERIC (18, 6) NULL,
    [dblFreightRate]    NUMERIC (18, 6) NULL,
	[dblFreightMiles]   NUMERIC (18, 6) NULL,        
    [dblMinimumUnits]   NUMERIC (18, 6) NULL,
	[intEntityTariffTypeId]			  INT			  NULL,
    [intConcurrencyId]  INT             NOT NULL,
    CONSTRAINT [PK_tblTRBulkPlantFreight] PRIMARY KEY CLUSTERED ([intBulkPlantFreightId] ASC),
	CONSTRAINT [FK_tblTRBulkPlantFreight_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	CONSTRAINT [FK_tblTRBulkPlantFreight_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia]([intEntityId]),		
	CONSTRAINT [FK_tblTRBulkPlantFreight_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [UK_tblTRBulkPlantFreight_reference_columns] UNIQUE NONCLUSTERED ([strZipCode] ASC, [intCategoryId] ASC,[intCompanyLocationId] ASC),		
	CONSTRAINT [FK_tblTRBulkPlantFreight_tblEMEntityTariffType_intEntityTariffTypeId] FOREIGN KEY ([intEntityTariffTypeId]) REFERENCES [dbo].[tblEMEntityTariffType] ([intEntityTariffTypeId])
    
);

