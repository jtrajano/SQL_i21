CREATE TABLE [dbo].[tblRKM2MConfiguration]
(
	[intM2MConfigurationId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
	[intItemId] INT NOT NULL,
	[strAdjustmentType] nvarchar(20)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intContractBasisId] INT NOT NULL,
   	CONSTRAINT [PK_tblRKM2MConfiguration_intM2MConfigurationId] PRIMARY KEY ([intM2MConfigurationId]), 
    CONSTRAINT [FK_tblRKM2MConfiguration_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblRKM2MConfiguration_tblCTContractBasis_intContractBasisId] FOREIGN KEY ([intContractBasisId]) REFERENCES [tblCTContractBasis]([intContractBasisId]),
    CONSTRAINT [UK_tblRKM2MConfiguration_tblICItem_intItemId] UNIQUE (intItemId,intContractBasisId)	
)