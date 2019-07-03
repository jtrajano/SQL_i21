CREATE TABLE [dbo].[tblSTRevertHolder] (

    [intRevertHolderId]					INT				IDENTITY (1, 1) NOT NULL,
	[intEntityId]						INT				NOT NULL,
	[dtmDateTimeModifiedFrom]			DATETIME		NOT NULL,
	[dtmDateTimeModifiedTo]				DATETIME		NOT NULL,
	[intMassUpdatedRowCount]			INT				NOT NULL,
	[strOriginalFilterCriteria]			NVARCHAR(MAX)	NULL,
	[strOriginalUpdateValues]			NVARCHAR(MAX)	NULL,
    [intConcurrencyId]					INT				NULL DEFAULT ((0))
    CONSTRAINT [PK_tblSTRevertHolder] PRIMARY KEY CLUSTERED ([intRevertHolderId] ASC)
);