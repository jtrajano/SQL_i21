CREATE PROCEDURE [dbo].[uspICSyncItemLocationPricing]
    @intItemId INT = NULL,
    @intUserId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

IF @intUserId IS NULL
BEGIN
    SELECT TOP 1 
		@intUserId = intEntityId 
	FROM 
		tblSMUserSecurity 		
	WHERE 
		strUserName IN ('irelyadmin', 'aussup')
    
	IF @intUserId IS NULL SET @intUserId = 1
END

DECLARE @Pricing TABLE (intItemId INT, intItemLocationId INT)

INSERT INTO @Pricing
SELECT i.intItemId, il.intItemLocationId
FROM tblICItem i
    INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
    OUTER APPLY (
        SELECT *
        FROM tblICItemPricing ip
        WHERE ip.intItemLocationId = il.intItemLocationId
    ) p
WHERE (i.intItemId = @intItemId OR @intItemId IS NULL) AND p.intItemPricingId IS NULL

INSERT INTO tblICItemPricing(intItemId, intItemLocationId, strPricingMethod, intCreatedByUserId, dtmDateCreated, intConcurrencyId)
SELECT intItemId, intItemLocationId, 'None', @intUserId, GETUTCDATE(), 1
FROM @Pricing

-- Audit Log
IF @@ROWCOUNT > 0
BEGIN
    DECLARE @strAuditItemNo NVARCHAR(200)
    DECLARE @strAuditLocation NVARCHAR(200)
    DECLARE @strAuditItemType NVARCHAR(50)
    DECLARE @intAuditItemId INT
    DECLARE @intAuditItemLocationId INT
    
    DECLARE db_cursor CURSOR FOR
    SELECT p.intItemId, p.intItemLocationId, i.strItemNo, c.strLocationName, i.strType
    FROM @Pricing p
        INNER JOIN tblICItem i ON i.intItemId = p.intItemId
        INNER JOIN tblICItemLocation il ON il.intItemLocationId = p.intItemLocationId
            AND il.intItemId = p.intItemId
        INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId

    OPEN db_cursor
    FETCH NEXT FROM db_cursor INTO @intAuditItemId, @intAuditItemLocationId, @strAuditItemNo, @strAuditLocation, @strAuditItemType
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @strDescription NVARCHAR(400)
        DECLARE @strScreenName NVARCHAR(50)

        IF @strAuditItemType = 'Bundle'
            SET @strScreenName = 'Inventory.view.Bundle'
        ELSE
            SET @strScreenName = 'Inventory.view.Item'

        SET @strDescription = 'Added missing pricing for ' + @strAuditItemNo + ' in ' + @strAuditLocation + '.'
        EXEC	dbo.uspSMAuditLog 
                    @keyValue = @intAuditItemId
                    ,@screenName = @strScreenName
                    ,@entityId = @intUserId
                    ,@actionType = 'Create Missing Pricing Entry'
                    ,@changeDescription = @strDescription
                    ,@fromValue = ''
                    ,@toValue = 'Pricing record'
        
        FETCH NEXT FROM db_cursor INTO @intAuditItemId, @intAuditItemLocationId, @strAuditItemNo, @strAuditLocation, @strAuditItemType
    END
    
    CLOSE db_cursor
    DEALLOCATE db_cursor
END