CREATE TABLE [dbo].[tblNRAdjustmentType]
(	
	[intAdjTypeId] [INT] IDENTITY(1,1) NOT NULL,
	[strAdjShowAs] [NVARCHAR](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblNRAdjustmentType_intAdjTypeId] PRIMARY KEY CLUSTERED 
(
	[intAdjTypeId] ASC
) ON [PRIMARY]

) ON [PRIMARY]
