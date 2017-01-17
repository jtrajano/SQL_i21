CREATE TABLE [dbo].[tblSMScreenLabel]
(
	[intScreenLabelId]	INT IDENTITY (1, 1) NOT NULL,
    [strLabel]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]  INT NOT NULL,
	CONSTRAINT [PK_tblSMScreenLabel] PRIMARY KEY CLUSTERED ([intScreenLabelId] ASC)
)
