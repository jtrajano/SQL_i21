CREATE TABLE [dbo].[tblRKM2MConfiguration]
(
	[intM2MConfigurationId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
	[intItemId] INT NOT NULL,
	[strContractType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strAdjustmentType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL,
	[intContractBasisId] INT NULL,
   	[intFreightTermId] INT NULL,
	[intMTMPointId] INT NULL,
    CONSTRAINT [PK_tblRKM2MConfiguration_intM2MConfigurationId] PRIMARY KEY ([intM2MConfigurationId]), 
    CONSTRAINT [FK_tblRKM2MConfiguration_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),	
    CONSTRAINT [FK_tblRKM2MConfiguration_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]), 
    CONSTRAINT [AK_tblRKM2MConfiguration] UNIQUE ([intItemId], [strContractType], [strAdjustmentType], [intFreightTermId], [intMTMPointId]) 
)