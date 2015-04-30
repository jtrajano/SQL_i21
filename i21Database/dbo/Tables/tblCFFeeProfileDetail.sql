CREATE TABLE [dbo].[tblCFFeeProfileDetail] (
    [intFeeProfileDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intFeeProfileId]       INT            NULL,
    [intFeeId]              INT            NULL,
    [strDescription]        NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [dtmEndDate]            DATETIME       NULL,
    [dtmStartDate]          DATETIME       NULL,
    [intConcurrencyId]      INT            CONSTRAINT [DF_tblCFFeeProfileDetail_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFFeeProfileDetail] PRIMARY KEY CLUSTERED ([intFeeProfileDetailId] ASC),
    CONSTRAINT [FK_tblCFFeeProfileDetail_tblCFFee] FOREIGN KEY ([intFeeId]) REFERENCES [dbo].[tblCFFee] ([intFeeId]),
    CONSTRAINT [FK_tblCFFeeProfileDetail_tblCFFeeProfile] FOREIGN KEY ([intFeeProfileId]) REFERENCES [dbo].[tblCFFeeProfile] ([intFeeProfileId]) ON DELETE CASCADE
);



