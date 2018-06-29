CREATE TABLE [dbo].[tblSMScreenLabel]
(
	[intScreenLabelId]	INT IDENTITY (1, 1) NOT NULL,
    [strLabel]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]  INT NOT NULL DEFAULT 0,
	CONSTRAINT [PK_tblSMScreenLabel] PRIMARY KEY CLUSTERED ([intScreenLabelId] ASC)
)
