CREATE TABLE [dbo].[tblSMUpload] (
    [intUploadId]       INT              IDENTITY (1, 1) NOT NULL,
    [strFileName]       NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strFileIdentifier] UNIQUEIDENTIFIER NOT NULL,
    [strScreen]         NVARCHAR (50)    COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDateUploaded]   DATETIME         NOT NULL,
    [intConcurrencyId]  INT              NOT NULL,
    CONSTRAINT [PK_tblUpload] PRIMARY KEY CLUSTERED ([intUploadId] ASC)
);

