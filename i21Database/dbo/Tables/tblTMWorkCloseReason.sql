CREATE TABLE [dbo].[tblTMWorkCloseReason] (
    [intCloseReasonID] INT           IDENTITY (1, 1) NOT NULL,
    [strCloseReason]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnDefault]       BIT           NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMWorkCloseReason] PRIMARY KEY CLUSTERED ([intCloseReasonID] ASC),
    CONSTRAINT [UQ_tblTMWorkCloseReason_strCloseReason] UNIQUE NONCLUSTERED ([strCloseReason] ASC)
);

