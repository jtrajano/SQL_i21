CREATE TABLE [dbo].[tblTMWorkToDo] (
    [intWorkToDoID]     INT IDENTITY (1, 1) NOT NULL,
    [intWorkToDoItemID] INT NOT NULL,
    [intWorkOrderID]    INT NOT NULL,
    [ysnCompleted]      BIT NULL,
    [intConcurrencyId]  INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMWorkToDo] PRIMARY KEY CLUSTERED ([intWorkToDoID] ASC),
    CONSTRAINT [FK_tblTMWorkToDo_tblTMWork] FOREIGN KEY ([intWorkOrderID]) REFERENCES [dbo].[tblTMWorkOrder] ([intWorkOrderID]),
    CONSTRAINT [FK_tblTMWorkToDo_tblTMWorkToDoItem] FOREIGN KEY ([intWorkToDoItemID]) REFERENCES [dbo].[tblTMWorkToDoItem] ([intToDoItemID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkToDo',
    @level2type = N'COLUMN',
    @level2name = N'intWorkToDoID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Work To Do Item ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkToDo',
    @level2type = N'COLUMN',
    @level2name = N'intWorkToDoItemID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Work Order ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkToDo',
    @level2type = N'COLUMN',
    @level2name = N'intWorkOrderID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if completed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkToDo',
    @level2type = N'COLUMN',
    @level2name = N'ysnCompleted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkToDo',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'