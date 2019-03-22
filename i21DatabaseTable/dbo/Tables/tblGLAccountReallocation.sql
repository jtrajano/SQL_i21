CREATE TABLE [dbo].[tblGLAccountReallocation] (
    [intAccountReallocationId] INT           IDENTITY (1, 1) NOT NULL,
    [strName]                  NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intCurrencyId] INT NULL, 
	[intConcurrencyId]         INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountReallocation] PRIMARY KEY CLUSTERED ([intAccountReallocationId] ASC),
	CONSTRAINT [FK_tblGLAccountReallocation_tblSMCurrency] FOREIGN KEY([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID])
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocation', @level2type=N'COLUMN',@level2name=N'intAccountReallocationId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocation', @level2type=N'COLUMN',@level2name=N'strName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocation', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocation', @level2type=N'COLUMN',@level2name=N'intCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountReallocation', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO