CREATE TABLE dbo.tblApiSchemaTransformProperty (
      intPropertyId INT IDENTITY(1, 1) NOT NULL PRIMARY KEY
    , guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    , strPropertyName NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL
    , varPropertyValue SQL_VARIANT NOT NULL
)