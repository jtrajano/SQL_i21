CREATE TABLE [dbo].[tblTMInventoryStatusType] (
    [intConcurrencyId]         INT           DEFAULT 1 NOT NULL,
    [intInventoryStatusTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strInventoryStatusType]   NVARCHAR (70) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]               BIT           DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMInventoryStatusType] PRIMARY KEY CLUSTERED ([intInventoryStatusTypeID] ASC)
);

