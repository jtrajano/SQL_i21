CREATE TABLE [dbo].[tblApiSchemaTransformMappedField] (
      guiId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY
    , guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    , strKeyField NVARCHAR (400) COLLATE Latin1_General_CI_AS NOT NULL
    , strTargetField NVARCHAR (400) COLLATE Latin1_General_CI_AS NOT NULL
    , strSourceField NVARCHAR (400) COLLATE Latin1_General_CI_AS NOT NULL
    , strTemplateField NVARCHAR (400) COLLATE Latin1_General_CI_AS NOT NULL
)