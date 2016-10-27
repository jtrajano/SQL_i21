CREATE TABLE [dbo].[tblGLAccountSystem](
	[intAccountSystemId]			INT IDENTITY(1,1)	NOT NULL,
	[strAccountSystemDescription]	NVARCHAR(50)		COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]				INT					NULL,
 CONSTRAINT [PK_tblGLAccountSystem] PRIMARY KEY CLUSTERED 
(
	[intAccountSystemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


