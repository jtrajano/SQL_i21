CREATE TABLE [dbo].[tblCTPlannedPurchases]
(
	[intPlannedPurchaseID] INT NOT NULL IDENTITY, 
	[intItemId] INT NOT NULL,
	[intUnitMeasureId] INT NOT NULL,
	[strMonth] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strYear] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dblQuantity] NUMERIC(18, 6),

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblCTPlannedPurchases_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblCTPlannedPurchases_dtmLastModified] DEFAULT GetDate(),

	CONSTRAINT [PK_tblCTPlannedPurchases] PRIMARY KEY ([intPlannedPurchaseID])
)