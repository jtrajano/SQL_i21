CREATE TABLE [dbo].[tblCFTempAuditLog] (
    [Type]       NVARCHAR (100) NULL,
    [TableName]  NVARCHAR (200) NULL,
    [PK]         INT            NULL,
    [FieldName]  NVARCHAR (200) NULL,
    [OldValue]   NVARCHAR (MAX) NULL,
    [NewValue]   NVARCHAR (MAX) NULL,
    [UpdateDate] DATETIME       NULL,
    [UserName]   NVARCHAR (100) NULL
);

