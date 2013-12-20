CREATE TABLE [dbo].[tblTMInventoryStatusType] (
    [intConcurrencyID]         INT           CONSTRAINT [DEF_tblTMInventoryStatusType_intConcurrencyID] DEFAULT ((0)) NULL,
    [intInventoryStatusTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strInventoryStatusType]   NVARCHAR (70) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMInventoryStatusType_strInventoryStatusType] DEFAULT ('') NOT NULL,
    [ysnDefault]               BIT           CONSTRAINT [DEF_tblTMInventoryStatusType_ysnDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMInventoryStatusType] PRIMARY KEY CLUSTERED ([intInventoryStatusTypeID] ASC)
);

