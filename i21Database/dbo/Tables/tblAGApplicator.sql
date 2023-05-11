CREATE TABLE [dbo].[tblAGApplicator]
(
	[intEntityId]					INT            NOT NULL,
    [strApplicatorId]				NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strName]						NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strAddress]					NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
	[strCity]						NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strState]						NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strZipCode]					NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strLineOfBusiness]				NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
	[strFreightBilledBy]			NVARCHAR (15) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive]						BIT            DEFAULT ((1)) NOT NULL,
    [intConcurrencyId]				INT NOT NULL DEFAULT (1), 

    CONSTRAINT [PK_tblAGApplicator] PRIMARY KEY CLUSTERED ([intEntityId] ASC), 
    --CONSTRAINT [AK_tblAGApplicator_strApplicatorId] UNIQUE ([strApplicatorId]),
	CONSTRAINT [FK_dbo_tblAGApplicator_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
);