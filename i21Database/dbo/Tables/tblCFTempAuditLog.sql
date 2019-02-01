CREATE TABLE [dbo].[tblCFTempAuditLog] (
    [Type]       NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [TableName]  NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [PK]         INT            NULL,
    [FieldName]  NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [OldValue]   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [NewValue]   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [UpdateDate] DATETIME       NULL,
    [UserName]   NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL
);

