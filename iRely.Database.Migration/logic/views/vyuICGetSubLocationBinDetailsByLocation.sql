--liquibase formatted sql

-- changeset Von:vyuICGetSubLocationBinDetailsByLocation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetSubLocationBinDetailsByLocation]
AS
SELECT b.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetSubLocationBinDetails b
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = b.intCompanyLocationId



