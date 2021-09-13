--!!!!!!!!! ---------- DO NOT RUN, MODIFY OR DELETE THIS FILE --------------- !!!!!!

/**
This is a boilerplate for creating an import transformation SP in i21 API.
**/
CREATE PROCEDURE dbo.uspApiSchemaTransformBoilerplate (
      @guiApiUniqueId UNIQUEIDENTIFIER -- A GUID-typed value that is a unique ID for the import session
    , @guiLogId UNIQUEIDENTIFIER       -- A GUID-typed value that is created by the API before the import process executes this SP
)
AS

/**

This simple example shows how to do data transformations of customer records from an external source.
First, the raw data are inserted into a specific table after a request is called from the API endpoint. 
This table is called the staging table that holds the raw data. This table must have the following fields, as shown below, that are used to
reference it in this stored procedure.

1. guiUniqueId UNIQUEIDENTIFIER NOT NULL    -> This is a reference to the @guiApiUniqeId parameter.
2. intRowNumber INT NULL                    -> This holds the row number of the record in the source file.

**/

-- Example:
-- NOTE: Don't put the creation of this schema table in this stored procedure, place it in a separate file. I just put it in here to show you an example.
CREATE TABLE [dbo].[tblApiSchemaCustomer] (
      [guiApiUniqueId] UNIQUEIDENTIFIER NOT NULL
    , [intRowNumber] INT NULL

    --- The rest of the fields that are specific to customer
    , [strEntityNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
    , [strEntityName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , [ysnActive] BIT NULL
    , [dblCreditLimit] NUMERIC(38, 20)
    , [dblARBalance] NUMERIC(38, 20)
);

/*

Errors, warnings and other messages can be inserted into the log tables: tblApiImportLog & tblApiImportLogDetail.
You don't have to create a record for the tblApiImportLog since it's already created for you. That's why you have a
reference to its ID, which is the @guiLogId, in the parameters of this stored procedure. All you need to do is create and insert records
the tblApiImportLogDetail table and reference it to its parent ID (@guiLogId).

The import process involves three stages: 
    (1) Validate     - You need to perform validations here and errors must be inserted into the log table.
    (2) Transform    - The actual logic for finding the lookups and inserting the data into the actual table.
    (3) Finalize     - You can do other tasks here like updating the status of the log, call external SPs, etc. You can also do some cleanups here if necessary.

*/

-- VALIDATE
-- Here you validate and insert the logs to the import log detail table.
INSERT INTO tblApiImportLogDetail (guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogId = @guiLogId
    , strField = 'Entity No'
    , strValue = sc.strEntityNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sc.intRowNumber
    , strMessage = 'The customer with an Entity No: ' + ISNULL(sc.strEntityName, '') + ' already exists.'
FROM tblApiSchemaCustomer sc
WHERE sc.guiApiUniqueId = @guiApiUniqueId  -- Always filter it with the guiApiUniqueId otherwise you will get the data from other sessions.
    AND EXISTS (SELECT * FROM tblARCustomer WHERE strCustomerNumber = sc.strEntityNo)


-- TRANSFORM
-- Depending on your business requirements, you can skip the transformation stage if necessary.
-- For example if there are validation errors and you don't want to anything to be imported. You can add a GOTO statement or IF conditions, etc.
INSERT INTO tblARCustomer (strCustomerNumber, ysnActive, dblCreditLimit, dblARBalance)
SELECT sc.strEntityNo, sc.ysnActive, sc.dblCreditLimit, sc.dblARBalance
FROM tblApiSchemaCustomer sc
WHERE sc.guiApiUniqueId = @guiApiUniqueId -- Don't forget to filter it with the @guiApiUniqueId

-- Finalize
-- You can do some other statements here like if you want to update the status of the primary log header or if you want to
-- update the number of successful/failed imports, etc.
DECLARE @intTotalRowsImported INT
SET @intTotalRowsImported = (
    SELECT COUNT(*) 
    FROM tblCTItemContractHeader h
    INNER JOIN tblCTItemContractDetail d ON h.intItemContractHeaderId = d.intItemContractHeaderId 
    WHERE h.guiApiUniqueId = @guiApiUniqueId
)

UPDATE tblApiImportLog
SET 
      strStatus = 'Completed'
    , strResult = CASE WHEN @intTotalRowsImported = 0 THEN 'Failed' ELSE 'Success' END
    , intTotalRecordsCreated = @intTotalRowsImported
    , intTotalRowsImported = @intTotalRowsImported
    , dtmImportFinishDateUtc = GETUTCDATE()
WHERE guiApiImportLogId = @guiLogId
