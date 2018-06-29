CREATE TABLE [dbo].[tblSMCustomLabel]
(
	[intCustomLabelId]	INT IDENTITY (1, 1) NOT NULL,
    [strLabel]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustomLabel]	NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]  INT NOT NULL,
	CONSTRAINT [PK_tblSMCustomLabel] PRIMARY KEY CLUSTERED ([intCustomLabelId] ASC)
)
