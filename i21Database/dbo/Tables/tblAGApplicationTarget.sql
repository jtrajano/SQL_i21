CREATE TABLE [dbo].[tblAGApplicationTarget]
(
 [intApplicationTargetId] INT IDENTITY (1, 1) NOT NULL,
 [strTargetNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS  NULL,
 [strTargetName] NVARCHAR(150) COLLATE Latin1_General_CI_AS  NULL,
 [strTargetDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS  NULL,
 [strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL,
 [intConcurrencyId] INT NOT NULL DEFAULT(0),
 CONSTRAINT [PK_dbo.tblAGApplicationTarget_intApplicationTargetId] PRIMARY KEY CLUSTERED ([intApplicationTargetId] ASC)
 )