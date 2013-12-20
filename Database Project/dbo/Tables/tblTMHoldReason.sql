CREATE TABLE [dbo].[tblTMHoldReason] (
    [intConcurrencyID] INT           CONSTRAINT [DEF_tblTMHoldReason_intConcurrencyID] DEFAULT ((0)) NULL,
    [intHoldReasonID]  INT           IDENTITY (1, 1) NOT NULL,
    [strHoldReason]    NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMHoldReason_strHoldReason] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMHoldReason] PRIMARY KEY CLUSTERED ([intHoldReasonID] ASC)
);

