﻿CREATE TABLE [dbo].[tblSCDisconnectedImportLog]
(
    [intDisconnectedImportLogId] INT IDENTITY(1,1) NOT NULL,
    [strFileName] NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS  NULL ,
    [intRecordId] INT NULL,
    [dtmDate] DATETIME NOT NULL,
    [ysnSuccess] BIT NOT NULL DEFAULT(0),
    [strBatchNo] NVARCHAR(200)   COLLATE Latin1_General_CI_AS  NULL,
    [strMessage] NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS  NULL,
    [ysnFromSchedule] BIT NOT NULL DEFAULT(0),
    [intConcurrencyId] INT NOT NULL DEFAULT(0)
    CONSTRAINT [PK_dbo.tblSCDisconnectedImportLog] PRIMARY KEY CLUSTERED ([intDisconnectedImportLogId] ASC)
  

)