CREATE TABLE [dbo].[tblNRNoteDescription]
(	
	[intDescriptionId]			INT				IDENTITY(1,1) NOT NULL,
	[strDescriptionName]		NVARCHAR(100)	COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescriptionComment]		NVARCHAR(255)	COLLATE Latin1_General_CI_AS NULL,
	[intEntityId]				INT				NULL,
	[intConcurrencyId]			INT				NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblNRNoteDescription_intDescriptionId] PRIMARY KEY CLUSTERED ([intDescriptionId] ASC)
)