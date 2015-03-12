CREATE TABLE [dbo].[tblTMWorkToDoItem] (
    [intToDoItemID]    INT           IDENTITY (1, 1) NOT NULL,
    [strToDoItem]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnDefault]       BIT           NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMToDoItem] PRIMARY KEY CLUSTERED ([intToDoItemID] ASC),
	CONSTRAINT [UQ_tblTMToDoItem_strToDoItem] UNIQUE NONCLUSTERED ([strToDoItem] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkToDoItem',
    @level2type = N'COLUMN',
    @level2name = N'intToDoItemID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'To Do Item',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkToDoItem',
    @level2type = N'COLUMN',
    @level2name = N'strToDoItem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if Default Data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkToDoItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkToDoItem',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'