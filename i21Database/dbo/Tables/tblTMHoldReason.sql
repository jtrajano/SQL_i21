CREATE TABLE [dbo].[tblTMHoldReason] (
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    [intHoldReasonID]  INT           IDENTITY (1, 1) NOT NULL,
    [strHoldReason]    NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMHoldReason] PRIMARY KEY CLUSTERED ([intHoldReasonID] ASC)
);

