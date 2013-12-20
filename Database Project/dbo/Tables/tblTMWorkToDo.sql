CREATE TABLE [dbo].[tblTMWorkToDo] (
    [intWorkToDoID]     INT IDENTITY (1, 1) NOT NULL,
    [intWorkToDoItemID] INT NOT NULL,
    [intWorkOrderID]    INT NOT NULL,
    [ysnCompleted]      BIT NULL,
    [intConcurrencyID]  INT NULL,
    CONSTRAINT [PK_tblTMWorkToDo] PRIMARY KEY CLUSTERED ([intWorkToDoID] ASC),
    CONSTRAINT [FK_tblTMWorkToDo_tblTMWork] FOREIGN KEY ([intWorkOrderID]) REFERENCES [dbo].[tblTMWorkOrder] ([intWorkOrderID]),
    CONSTRAINT [FK_tblTMWorkToDo_tblTMWorkToDoItem] FOREIGN KEY ([intWorkToDoItemID]) REFERENCES [dbo].[tblTMWorkToDoItem] ([intToDoItemID])
);

