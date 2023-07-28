--liquibase formatted sql

-- changeset Von:vyuICGetStorageBinDetailsByLocation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetStorageBinDetailsByLocation]
AS
SELECT b.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetStorageBinDetails b
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = b.intCompanyLocationId



