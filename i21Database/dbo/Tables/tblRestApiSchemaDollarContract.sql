CREATE TABLE [dbo].[tblRestApiSchemaDollarContract]
(
    guiRestApiSchemaId UNIQUEIDENTIFIER NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    strCustomerNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    dtmContractDate DATETIME NULL,
    dtmExpirationDate DATETIME NULL,
    strEntryContract NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    strContract NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    strFreightTerm NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    strCountry NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    strTerms NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    strSalesperson NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    ysnIsSigned BIT NULL,
    ysnIsPrinted BIT NULL,
    strContractText NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    strLineOfBusiness NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    dtmDueDate DATETIME NULL,
    dblContractValue NUMERIC(38, 20) NOT NULL,
    strCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT PK_tblRestApiSchemaDollarContract PRIMARY KEY (guiRestApiSchemaId)
)