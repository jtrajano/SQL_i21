CREATE TABLE [dbo].[tblCFImportResult] (
    [intResultId]         INT            IDENTITY (1, 1) NOT NULL,
    [dtmImportDate]       DATETIME       NULL,
    [strSetupName]        NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [ysnSuccessful]       BIT            NULL,
    [strFailedReason]     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strOriginTable]      NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strOriginIdentityId] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strI21Table]         NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intI21IdentityId]    INT            NULL,
    [strUserId]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFImportResult_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFImportResult] PRIMARY KEY CLUSTERED ([intResultId] ASC)
);

