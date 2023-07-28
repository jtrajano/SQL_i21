--liquibase formatted sql

-- changeset Von:vyuICGetInventoryValuationByLocation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetInventoryValuationByLocation]
AS

SELECT v.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetInventoryValuation v
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = v.intLocationId



