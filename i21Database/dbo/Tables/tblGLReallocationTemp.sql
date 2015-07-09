CREATE TABLE [dbo].[tblGLReallocationTemp](
[intAccountReallocationId] [int] NOT NULL,
intPrimary [int] NULL,
intSecondary [int] NULL,
decPercentage [decimal](9, 6) NULL,
[intAccountId] [int] NULL,
strAccountId [nvarchar](20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]