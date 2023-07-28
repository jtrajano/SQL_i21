--liquibase formatted sql

-- changeset Von:vyuICGetStorageUnitByLocation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetStorageUnitByLocation]
AS

SELECT su.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetStorageLocation su
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = su.intLocationId



