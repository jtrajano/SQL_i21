--liquibase formatted sql

-- changeset Von:vyuICGetLocationBinsByLocation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetLocationBinsByLocation]
AS
SELECT b.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetLocationBins b
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = b.intLocationId



