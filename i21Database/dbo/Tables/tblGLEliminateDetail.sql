CREATE TABLE [dbo].[tblGLEliminateDetail](
	[intEliminateDetailId]	INT IDENTITY(1,1) NOT NULL,
	[intEliminateId]		INT NOT NULL,
	[intAccount1Id]			INT NOT NULL,
	[intOffsetAccount1Id]	INT NULL,
	[dblBalance1]			NUMERIC(18, 6) NOT NULL,
	[intAccount2Id]			INT NOT NULL,
	[intOffsetAccount2Id]	INT NULL,
	[dblBalance2]			NUMERIC(18, 6) NOT NULL,
	[dblDifference]			NUMERIC(18, 6) NOT NULL,
	[intConcurrencyId]	    INT	NOT NULL DEFAULT ((1))
	CONSTRAINT [PK_tblGLEliminateDetail] PRIMARY KEY CLUSTERED ([intEliminateDetailId] ASC) 
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO