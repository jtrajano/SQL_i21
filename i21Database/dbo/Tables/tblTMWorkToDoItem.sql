CREATE TABLE [dbo].[tblTMWorkToDoItem] (
    [intToDoItemID]    INT           IDENTITY (1, 1) NOT NULL,
    [strToDoItem]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnDefault]       BIT           NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMToDoItem] PRIMARY KEY CLUSTERED ([intToDoItemID] ASC),
	CONSTRAINT [UQ_tblTMToDoItem_strToDoItem] UNIQUE NONCLUSTERED ([strToDoItem] ASC)
);

