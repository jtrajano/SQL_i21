CREATE TABLE [dbo].[tblEMEntityTariffType]
(
	[intEntityTariffTypeId] INT NOT NULL Identity(1,1),
	[strTariffType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,		
    [intConcurrencyId]  INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblEMEntityTariffType] PRIMARY KEY CLUSTERED ([intEntityTariffTypeId] ASC),
	CONSTRAINT [UK_tblEMEntityTariffType_strTariffType] UNIQUE NONCLUSTERED ([strTariffType] ASC),
);