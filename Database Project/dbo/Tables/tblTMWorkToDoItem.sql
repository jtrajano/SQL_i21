CREATE TABLE [dbo].[tblTMWorkToDoItem] (
    [intToDoItemID]    INT           IDENTITY (1, 1) NOT NULL,
    [strToDoItem]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnDefault]       BIT           NULL,
    [intConcurrencyID] INT           NULL,
    CONSTRAINT [PK_tblTMToDoItem] PRIMARY KEY CLUSTERED ([intToDoItemID] ASC)
);

