CREATE TABLE [dbo].[tblSRDirectFilter]
(
	[intDirectFilterId] [int] NOT NULL IDENTITY(1, 1),
	[strFilter] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblSRDirectFilter] PRIMARY KEY CLUSTERED ([intDirectFilterId] ASC)
)
