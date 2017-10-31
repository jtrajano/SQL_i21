CREATE TABLE [dbo].[tblNRAdjustmentType]
(	
	[intAdjTypeId]			INT					IDENTITY (1, 1)	NOT NULL,
	[strAdjShowAs]			NVARCHAR(100)		COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId]			INT					NULL,
	[intConcurrencyId]		INT					NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblNRAdjustmentType_intAdjTypeId] PRIMARY KEY CLUSTERED ([intAdjTypeId] ASC)
)