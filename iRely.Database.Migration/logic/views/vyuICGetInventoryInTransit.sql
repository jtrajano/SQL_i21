--liquibase formatted sql

-- changeset Von:vyuICGetInventoryInTransit.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetInventoryInTransit]
AS

SELECT	* 
FROM	vyuICGetInventoryValuation
WHERE	ysnInTransit = 1



