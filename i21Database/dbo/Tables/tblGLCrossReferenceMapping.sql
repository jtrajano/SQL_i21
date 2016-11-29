CREATE TABLE [dbo].[tblGLCrossReferenceMapping](
	[intCrossReferenceMappingId] [int] IDENTITY(1,1) NOT NULL,
	[strOldAccountId] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intAccountId] INT NULL,
	[intAccountSystemId] INT NULL,
	[ysnOutbound] BIT NULL,
	[ysnInbound] BIT NULL,
	[intConcurrencyId] INT
 CONSTRAINT [PK_tblGLCrossReferenceMapping] PRIMARY KEY CLUSTERED 
(
	[intCrossReferenceMappingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblGLCrossReferenceMapping]  WITH CHECK ADD  CONSTRAINT [FK_tblGLCrossReferenceMapping_tblGLAccount] FOREIGN KEY([intAccountId])
REFERENCES [dbo].[tblGLAccount] ([intAccountId])
GO

ALTER TABLE [dbo].[tblGLCrossReferenceMapping] CHECK CONSTRAINT [FK_tblGLCrossReferenceMapping_tblGLAccount]
GO

ALTER TABLE [dbo].[tblGLCrossReferenceMapping]  WITH CHECK ADD  CONSTRAINT [FK_tblGLCrossReferenceMapping_tblGLAccountSystem] FOREIGN KEY([intAccountSystemId])
REFERENCES [dbo].[tblGLAccountSystem] ([intAccountSystemId])
GO

ALTER TABLE [dbo].[tblGLCrossReferenceMapping] CHECK CONSTRAINT [FK_tblGLCrossReferenceMapping_tblGLAccountSystem]
GO

