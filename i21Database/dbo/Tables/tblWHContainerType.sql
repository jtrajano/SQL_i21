CREATE TABLE [dbo].[tblWHContainerType]
(
		[intContainerTypeId]	INT	NOT NULL IDENTITY,
		[intConcurrencyId] INT NOT NULL,
		[strInternalCode]	NVARCHAR(32)	COLLATE Latin1_General_CI_AS NOT NULL, 
		[strContainerType]	NVARCHAR(32)	COLLATE Latin1_General_CI_AS NOT NULL, 
		[intDimensionUOMId]	INT	,
		[dblHeight]	FLOAT	,
		[dblWidth]	FLOAT	,
		[dblDepth]	FLOAT	,
		[intWeightUOMId]	INT	,
		[dblMaxWeight]	FLOAT	,
		[ysnLocked]	BIT DEFAULT 1	,
		[ysnIsDefault]	BIT DEFAULT 0	,
		[dblPalletWeight]	FLOAT	,
		[strContainerDescription]	NVARCHAR(100)	COLLATE Latin1_General_CI_AS NOT NULL, 
		[ysnIsReUsable]	BIT	,
		[ysnAllowMultipleItems]	BIT	,
		[ysnAllowMultipleLots]	BIT	,
		[ysnMergeOnMove]	BIT	,
		[intTareUOMId]	INT,
		[intCreatedUserId] [int] NULL,
		[dtmCreated] [datetime] NULL DEFAULT GetDate(),
		[intLastModifiedUserId] [int] NULL,
		[dtmLastModified] [datetime] NULL DEFAULT GetDate(),

CONSTRAINT [PK_tblWHContainerType_intContainerTypeId] PRIMARY KEY ([intContainerTypeId]), 

)
