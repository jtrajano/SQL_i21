--liquibase formatted sql

-- changeset Von:vyuICGetStorageBinsByLocation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetStorageBinsByLocation]
AS

SELECT b.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetStorageBins b
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = b.intCompanyLocationId



