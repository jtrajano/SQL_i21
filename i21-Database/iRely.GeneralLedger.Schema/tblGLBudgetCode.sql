CREATE TABLE [dbo].[tblGLBudgetCode] (
    [intBudgetCode]               INT            IDENTITY (1, 1) NOT NULL,
    [ysnDefault]                  BIT            CONSTRAINT [DF__tblGLBudg__ysnDe__76818E95] DEFAULT ((0)) NULL,
    [strBudgetCode]               NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strBudgetEnglishDescription] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]            INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLBudgetCode] PRIMARY KEY CLUSTERED ([intBudgetCode] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetCode', @level2type=N'COLUMN',@level2name=N'intBudgetCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Default' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetCode', @level2type=N'COLUMN',@level2name=N'ysnDefault' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget Code (string)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetCode', @level2type=N'COLUMN',@level2name=N'strBudgetCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget English Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetCode', @level2type=N'COLUMN',@level2name=N'strBudgetEnglishDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetCode', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO