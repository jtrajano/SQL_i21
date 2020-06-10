CREATE TABLE [dbo].[tblSTRevertHolder] (

    [intRevertHolderId]					INT				IDENTITY (1, 1) NOT NULL,
	[intEntityId]						INT				NOT NULL,
	[dtmDateTimeModifiedFrom]			DATETIME		NOT NULL,
	[dtmDateTimeModifiedTo]				DATETIME		NOT NULL,
	[intMassUpdatedRowCount]			INT				NOT NULL,
	[intRevertType]						INT				NOT NULL,			-- *** Note: 1=Update Item Data,	2=Update Item Pricing
	[strOriginalFilterCriteria]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[strOriginalUpdateValues]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]					INT				NULL DEFAULT ((0))
    CONSTRAINT [PK_tblSTRevertHolder] PRIMARY KEY CLUSTERED ([intRevertHolderId] ASC)
);