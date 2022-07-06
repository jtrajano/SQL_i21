CREATE TABLE [dbo].[tblCRMBrandIntegrationLog]
(
	[intBrandIntegrationLogId]  INT IDENTITY(1,1) NOT NULL,
	[intBrandId]				INT			      NOT NULL,
	[intOpportunityId]			INT			      NULL,
	[dtmIntegrationDate]		DATETIME NULL,
	[strStatus]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strAPIMessage]				NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strAction]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int]	NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMBrandIntegrationLog_intBrandIntegrationLogId] PRIMARY KEY CLUSTERED ([intBrandIntegrationLogId] ASC),
    CONSTRAINT [FK_tblCRMBrandIntegrationLog_tblCRMBrand_intBrandId] FOREIGN KEY ([intBrandId]) REFERENCES [dbo].[tblCRMBrand] ([intBrandId]) ON DELETE CASCADE
)

GO