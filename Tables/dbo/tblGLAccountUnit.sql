CREATE TABLE [dbo].[tblGLAccountUnit] (
    [intAccountUnitId] INT             IDENTITY (1, 1) NOT NULL,
    [strUOMCode]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strUOMDesc]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblLbsPerUnit]    DECIMAL (16, 4) NULL,
    [intConcurrencyId] INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountUnit] PRIMARY KEY CLUSTERED ([intAccountUnitId] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Unit Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountUnit', @level2type=N'COLUMN',@level2name=N'intAccountUnitId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unit Of Measure Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountUnit', @level2type=N'COLUMN',@level2name=N'strUOMCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unit Of Measure Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountUnit', @level2type=N'COLUMN',@level2name=N'strUOMDesc' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lbs Per Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountUnit', @level2type=N'COLUMN',@level2name=N'dblLbsPerUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountUnit', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO


