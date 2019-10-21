CREATE TABLE [dbo].[tblNRNoteTransType]
(
	[intNoteTransTypeId]	INT				IDENTITY(1,1) NOT NULL,
    [strNoteTransTypeName]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId]		INT				NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblNRNoteTransType_intNoteTransTypeId] PRIMARY KEY CLUSTERED ([intNoteTransTypeId] ASC)
)