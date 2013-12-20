CREATE TABLE [dbo].[tblRMSorts] (
    [intSortId]        INT            IDENTITY (1, 1) NOT NULL,
    [strSortField]     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intReportId]      INT            NULL,
    [intSortDirection] INT            NULL,
    [ysnRequired]      BIT            NULL,
    [intUserId]        INT            NULL,
    CONSTRAINT [PK_dbo.Sorts] PRIMARY KEY CLUSTERED ([intSortId] ASC)
);

