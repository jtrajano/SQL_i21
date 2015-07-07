CREATE TABLE [dbo].[tblEntityTariff]
(
	[intEntityTariffId]				INT IDENTITY(1,1) NOT NULL,
	[intEntityId]					INT,
	[strDescription]				NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]    INT            CONSTRAINT [DF_tblEntityTariff_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityTariff] PRIMARY KEY CLUSTERED ([intEntityTariffId] ASC),     
	CONSTRAINT [FK_dbo_tblEntityTariff_tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE
)
