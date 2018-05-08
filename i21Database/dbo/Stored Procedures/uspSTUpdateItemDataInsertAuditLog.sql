CREATE PROCEDURE [dbo].[uspSTUpdateItemDataInsertAuditLog]
	@currentUserId AS INT
AS
BEGIN

DECLARE @JsonStringAuditLog AS NVARCHAR(MAX) = ''
DECLARE @strJsonRemoveComma AS NVARCHAR(MAX) = ''

--===================================================================================================
-- START Audit Log tblICItemLocation
--===================================================================================================
DECLARE @strCompanyLocation AS NVARCHAR(1000) = ''

DECLARE @strItemLocationAuditLogChildren AS NVARCHAR(MAX) = ''
DECLARE @strItemLocationFromData AS NVARCHAR(1000) = ''
DECLARE @strItemLocationToData AS NVARCHAR(1000) = ''
DECLARE @intItemLocationParentId INT
DECLARE @intItemLocationChildId AS INT
DECLARE @strItemLocationChangeColumnName AS NVARCHAR(1000) = ''
DECLARE @strItemLocationChangeDescription AS NVARCHAR(1000) = ''
DECLARE @strItemLocationTempJson AS NVARCHAR(MAX) = ''
DECLARE @strItemLocationChildrenJson AS NVARCHAR(MAX) = ''
DECLARE @intItemLocationId AS INT
DECLARE @strItemLocationJsonFormat AS NVARCHAR(MAX) =
N'{
	"change": "{CHANGECOLUMN}",
	"from": "{FROM}",
	"to": "{TO}",
	"leaf": true,
	"iconCls": "small-gear",
	"isField": true,
	"keyValue": {KEYVALUE},
	"changeDescription": "{CHANGEDESC}",
	"hidden": false
},'

DECLARE @tblTemp TABLE 
(
	intId INT NOT NULL IDENTITY
	, strLocation NVARCHAR(250)
	, strUpc NVARCHAR(50)
	, strItemDescription NVARCHAR(250)
	, strChangeDescription NVARCHAR(100)
	, strOldData NVARCHAR(MAX)
	, strNewData NVARCHAR(MAX)
	, intParentId INT
	, intChildId INT
)

INSERT INTO @tblTemp (strLocation, strUpc, strItemDescription, strChangeDescription, strOldData, strNewData, intParentId, intChildId)
SELECT DISTINCT strLocation, strUpc, strItemDescription, strChangeDescription, strOldData, strNewData, intParentId, intChildId
FROM #tempAudit
ORDER BY intParentId ASC


WHILE EXISTS(SELECT * FROM @tblTemp)
BEGIN
	SELECT TOP 1 @intItemLocationParentId = intParentId FROM @tblTemp
	

	WHILE EXISTS(SELECT * FROM @tblTemp WHERE intParentId = @intItemLocationParentId)
	BEGIN
		SELECT TOP 1 @intItemLocationChildId = intChildId FROM @tblTemp
		SET @strItemLocationTempJson = ''
		SET @strItemLocationChildrenJson = ''


		WHILE EXISTS(SELECT * FROM @tblTemp WHERE intChildId = @intItemLocationChildId)
		BEGIN
			SELECT TOP 1 @intItemLocationId = intId FROM @tblTemp

			SELECT @strItemLocationFromData = strOldData
				   , @strItemLocationToData = strNewData 
				   , @strItemLocationChangeDescription = strChangeDescription
			FROM @tblTemp 
			WHERE intId = @intItemLocationId

			-- FAMILY
			IF (@strItemLocationChangeDescription = 'Family')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'strFamily')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Family')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- CLASS
			ELSE IF (@strItemLocationChangeDescription = 'Class')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'strClass')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Class')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Product Code
			ELSE IF (@strItemLocationChangeDescription = 'Product Code')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'strProductCode')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Product Code')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Tax Flag 1
			ELSE IF (@strItemLocationChangeDescription = 'Tax Flag1')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnTaxFlag1')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Tax Flag 1')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Tax Flag 2
			ELSE IF (@strItemLocationChangeDescription = 'Tax Flag2')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnTaxFlag2')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Tax Flag 2')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Tax Flag 3
			ELSE IF (@strItemLocationChangeDescription = 'Tax Flag3')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnTaxFlag3')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Tax Flag 3')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Tax Flag 4
			ELSE IF (@strItemLocationChangeDescription = 'Tax Flag4')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnTaxFlag4')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Tax Flag 4')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Promotional Item
			ELSE IF (@strItemLocationChangeDescription = 'Promotional Item')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnPromotionalItem')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Promotional Item')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Deposit Required
			ELSE IF (@strItemLocationChangeDescription = 'Deposit Required')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnDepositRequired')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Deposit Required')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Deposit PLU
			ELSE IF (@strItemLocationChangeDescription = 'Deposit PLU')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'intDepositPLUId')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Deposit PLU')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Saleable
			ELSE IF (@strItemLocationChangeDescription = 'Saleable')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnSaleable')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Saleable')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Quantity Required
			ELSE IF (@strItemLocationChangeDescription = 'Quantity Required')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnQuantityRequired')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Quantity Required')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Scale Item
			ELSE IF (@strItemLocationChangeDescription = 'Scale Item')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnScaleItem')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Scale Item')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Food Stampable
			ELSE IF (@strItemLocationChangeDescription = 'Food Stampable')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnFoodStampable')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Food Stampable')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Returnable
			ELSE IF (@strItemLocationChangeDescription = 'Returnable')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnReturnable')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Returnable')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Pre Priced
			ELSE IF (@strItemLocationChangeDescription = 'Pre Priced')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnPrePriced')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Pre Priced')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Liquor Id Required
			ELSE IF (@strItemLocationChangeDescription = 'Liquor Id Required')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnIdRequiredLiquor')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'ID Required (Liquor)')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Cigarette Id Required
			ELSE IF (@strItemLocationChangeDescription = 'Cigarette Id Required')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnIdRequiredCigarette')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'ID Required (Cigarettes)')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Minimum Age
			ELSE IF (@strItemLocationChangeDescription = 'Minimum Age')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'intMinimumAge')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Minimum Age')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Blue Law1
			ELSE IF (@strItemLocationChangeDescription = 'Blue Law1')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnApplyBlueLaw1')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Apply Blue Law 1')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Blue Law2
			ELSE IF (@strItemLocationChangeDescription = 'Blue Law2')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnApplyBlueLaw2')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Apply Blue Law 2')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Blue Law2
			ELSE IF (@strItemLocationChangeDescription = 'Blue Law2')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnApplyBlueLaw2')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Apply Blue Law 2')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END


			--STOCK
			-- Counted Daily
			ELSE IF (@strItemLocationChangeDescription = 'Counted Daily')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnCountedDaily')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Counted Daily')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Counted
			ELSE IF (@strItemLocationChangeDescription = 'Counted')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'strCounted')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Counted')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Count By Serial No
			ELSE IF (@strItemLocationChangeDescription = 'Count By Serial No')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnCountBySINo')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Count by Serial Number')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Vendor Minimum Order Qty
			ELSE IF (@strItemLocationChangeDescription = 'Vendor Minimum Order Qty')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'dblMinOrder')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Min Order')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Vendor Suggested Qty
			ELSE IF (@strItemLocationChangeDescription = 'Vendor Suggested Qty')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'dblSuggestedQty')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Suggested Qty')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Inventory Group
			ELSE IF (@strItemLocationChangeDescription = 'Inventory Group')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'intCountGroupId')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Inventory Count Group')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Min Qty On Hand
			ELSE IF (@strItemLocationChangeDescription = 'Min Qty On Hand')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'dblReorderPoint')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Reorder Point')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			
			-- Vendor
			ELSE IF (@strItemLocationChangeDescription = 'Vendor')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'strVendorName')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Vendor')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Storage Location
			ELSE IF (@strItemLocationChangeDescription = 'Storage Location')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strItemLocationJsonFormat
																	   , '{CHANGECOLUMN}', 'strSubLocationName')
				                                                       , '{KEYVALUE}', CAST(@intItemLocationChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strItemLocationFromData)
																	   , '{TO}', @strItemLocationToData)
																	   , '{CHANGEDESC}', 'Storage Location')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END






			DELETE FROM @tblTemp WHERE intId = @intItemLocationId
		END


		--INSERT TO AUDIT LOG Group by intChildId
		IF(@strItemLocationChildrenJson != '')
			BEGIN
						SET @strCompanyLocation = (SELECT strLocationName FROM tblSMCompanyLocation
													WHERE intCompanyLocationId = 
													(
														SELECT intLocationId FROM tblICItemLocation
														WHERE intItemLocationId = @intItemLocationChildId
													)
												   )


						SET @strItemLocationChildrenJson = left(@strItemLocationChildrenJson, len(@strItemLocationChildrenJson)-1)


						-- @intItemLocationParentId = intItemId
						-- @intItemLocationChildId = intItemLocationId

						-- INSERT TO Audit Log
						SET @JsonStringAuditLog = 
						N'{
							"action": "Updated",
							"change": "Updated - Record: ' + @strCompanyLocation + '",
							"keyValue": ' + CAST(@intItemLocationChildId AS NVARCHAR(50)) + ', 
							"iconCls": "small-tree-modified",
							"children": [
							' + @strItemLocationChildrenJson + '
							]
						}'


						INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
						VALUES(
								'Updated'
								, 'Inventory.view.ItemLocation'
								, @intItemLocationChildId
								, ''
								, null
								, @JsonStringAuditLog
								, GETUTCDATE()
								, @currentUserId
								, 1
						)
			END

		DELETE FROM @tblTemp WHERE intChildId = @intItemLocationChildId
	END
END
--===================================================================================================
-- END Audit Log tblICItemLocation
--===================================================================================================
END