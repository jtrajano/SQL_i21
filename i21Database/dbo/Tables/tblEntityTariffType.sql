CREATE TABLE [dbo].[tblEntityTariffType]
(
	[intEntityTariffTypeId] INT NOT NULL Identity(1,1),
	[strTariffType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,		
    [intConcurrencyId]  INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblEntityTariffType] PRIMARY KEY CLUSTERED ([intEntityTariffTypeId] ASC),
	CONSTRAINT [UK_tblEntityTariffType_strTariffType] UNIQUE NONCLUSTERED ([strTariffType] ASC),
);