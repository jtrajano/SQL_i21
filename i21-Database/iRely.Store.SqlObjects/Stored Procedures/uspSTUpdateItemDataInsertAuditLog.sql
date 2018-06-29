CREATE PROCEDURE [dbo].[uspSTUpdateItemDataInsertAuditLog]
	@currentUserId AS INT
AS
BEGIN

DECLARE @intAccountCategoryId INT
DECLARE @JsonStringAuditLog AS NVARCHAR(MAX) = ''
DECLARE @intKeyId AS INT
DECLARE @intParentId INT
DECLARE @intChildId AS INT
DECLARE @strFromData AS NVARCHAR(1000) = ''
DECLARE @strToData AS NVARCHAR(1000) = ''
DECLARE @strChangeDescription AS NVARCHAR(1000) = ''
DECLARE @strJsonFormat AS NVARCHAR(MAX) =
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

DECLARE @strJsonFormatItemAccounts AS NVARCHAR(MAX) =
N'{
    "action": "Updated",
    "change": "Updated - Record: {TO}",
    "keyValue": {KEYVALUE},
    "iconCls": "small-tree-modified",
    "children": [
         {
             "change": "{CHANGECOLUMN}",
             "from": "{FROM}",
             "to": "{TO}",
             "leaf": true,
             "iconCls": "small-gear",
             "isField": true,
             "keyValue": {KEYVALUE},
             "associationKey": "tblICItemAccounts",
             "changeDescription": "Account Id",
             "hidden": false
          }
    ]
},'

DECLARE @strJsonFormatCreateNewItemAccounts AS NVARCHAR(MAX) =
N'{
	"action": "Created",
    "change": "Created - Record: {ACCOUNTID}",
    "keyValue": {CREATEDID},
    "iconCls": "small-new-plus",
    "leaf": true
},'

--===================================================================================================
-- START Declare tblICItemLocation
--===================================================================================================
DECLARE @strItemLocationAuditLogChildren AS NVARCHAR(MAX) = ''
DECLARE @strCompanyLocation AS NVARCHAR(1000) = ''
DECLARE @strItemLocationChangeColumnName AS NVARCHAR(1000) = ''
DECLARE @strItemLocationTempJson AS NVARCHAR(MAX) = ''
DECLARE @strItemLocationChildrenJson AS NVARCHAR(MAX) = ''
--===================================================================================================
-- END Declare tblICItemLocation
--===================================================================================================


--===================================================================================================
-- START Declare tblICItem
--===================================================================================================
DECLARE @strItemAuditLogChildren AS NVARCHAR(MAX) = ''
DECLARE @strItemNo AS NVARCHAR(1000) = ''
DECLARE @strItemChangeColumnName AS NVARCHAR(1000) = ''
DECLARE @strItemTempJson AS NVARCHAR(MAX) = ''
DECLARE @strItemChildrenJson AS NVARCHAR(MAX) = ''
--===================================================================================================
-- END Declare tblICItem
--===================================================================================================


--===================================================================================================
-- START Declare tblICItemAccount
--===================================================================================================
--UPDATE
DECLARE @strItemAccountAuditLogChildren AS NVARCHAR(MAX) = ''
DECLARE @strItemAccountChangeColumnName AS NVARCHAR(1000) = ''
DECLARE @strItemAccountTempJson AS NVARCHAR(MAX) = ''
DECLARE @strItemAccountChildrenJson AS NVARCHAR(MAX) = ''

--CREATE NEW
DECLARE @strNewItemAccountAuditLogChildren AS NVARCHAR(MAX) = ''
DECLARE @strNewItemAccountChangeColumnName AS NVARCHAR(1000) = ''
DECLARE @strNewItemAccountTempJson AS NVARCHAR(MAX) = ''
DECLARE @strNewItemAccountChildrenJson AS NVARCHAR(MAX) = ''
--===================================================================================================
-- END Declare tblICItemAccount
--===================================================================================================



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
	SELECT TOP 1 @intParentId = intParentId FROM @tblTemp
	SET @strItemTempJson = ''
	SET @strItemChildrenJson = ''
	
	SET @strItemAccountTempJson = ''
		SET @strItemAccountChildrenJson = ''

	WHILE EXISTS(SELECT * FROM @tblTemp WHERE intParentId = @intParentId)
	BEGIN
		SELECT TOP 1 @intChildId = intChildId FROM @tblTemp WHERE intParentId = @intParentId
		
		SET @strItemLocationTempJson = ''
		SET @strItemLocationChildrenJson = ''
		

		WHILE EXISTS(SELECT * FROM @tblTemp WHERE intChildId = @intChildId)
		BEGIN
			SELECT TOP 1 @intKeyId = intId FROM @tblTemp WHERE intChildId = @intChildId

			SELECT @strFromData = strOldData
				   , @strToData = strNewData 
				   , @strChangeDescription = strChangeDescription
			FROM @tblTemp 
			WHERE intId = @intKeyId

			--===================================================================================================
			-- START Audit Log tblICItemLocation
			--===================================================================================================
			-- FAMILY
			IF (@strChangeDescription = 'Family')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'strFamily')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Family')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- CLASS
			ELSE IF (@strChangeDescription = 'Class')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'strClass')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Class')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Product Code
			ELSE IF (@strChangeDescription = 'Product Code')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'strProductCode')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Product Code')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Tax Flag 1
			ELSE IF (@strChangeDescription = 'Tax Flag1')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnTaxFlag1')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Tax Flag 1')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Tax Flag 2
			ELSE IF (@strChangeDescription = 'Tax Flag2')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnTaxFlag2')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Tax Flag 2')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Tax Flag 3
			ELSE IF (@strChangeDescription = 'Tax Flag3')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnTaxFlag3')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Tax Flag 3')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Tax Flag 4
			ELSE IF (@strChangeDescription = 'Tax Flag4')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnTaxFlag4')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Tax Flag 4')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Promotional Item
			ELSE IF (@strChangeDescription = 'Promotional Item')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnPromotionalItem')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Promotional Item')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Deposit Required
			ELSE IF (@strChangeDescription = 'Deposit Required')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnDepositRequired')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Deposit Required')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Deposit PLU
			ELSE IF (@strChangeDescription = 'Deposit PLU')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'intDepositPLUId')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Deposit PLU')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Saleable
			ELSE IF (@strChangeDescription = 'Saleable')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnSaleable')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Saleable')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Quantity Required
			ELSE IF (@strChangeDescription = 'Quantity Required')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnQuantityRequired')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Quantity Required')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Scale Item
			ELSE IF (@strChangeDescription = 'Scale Item')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnScaleItem')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Scale Item')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Food Stampable
			ELSE IF (@strChangeDescription = 'Food Stampable')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnFoodStampable')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Food Stampable')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Returnable
			ELSE IF (@strChangeDescription = 'Returnable')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnReturnable')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Returnable')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Pre Priced
			ELSE IF (@strChangeDescription = 'Pre Priced')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnPrePriced')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Pre Priced')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Liquor Id Required
			ELSE IF (@strChangeDescription = 'Liquor Id Required')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnIdRequiredLiquor')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'ID Required (Liquor)')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Cigarette Id Required
			ELSE IF (@strChangeDescription = 'Cigarette Id Required')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnIdRequiredCigarette')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'ID Required (Cigarettes)')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Minimum Age
			ELSE IF (@strChangeDescription = 'Minimum Age')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'intMinimumAge')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Minimum Age')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Blue Law1
			ELSE IF (@strChangeDescription = 'Blue Law1')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnApplyBlueLaw1')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Apply Blue Law 1')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Blue Law2
			ELSE IF (@strChangeDescription = 'Blue Law2')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnApplyBlueLaw2')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Apply Blue Law 2')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Blue Law2
			ELSE IF (@strChangeDescription = 'Blue Law2')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnApplyBlueLaw2')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Apply Blue Law 2')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END


			--STOCK
			-- Counted Daily
			ELSE IF (@strChangeDescription = 'Counted Daily')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnCountedDaily')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Counted Daily')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Counted
			ELSE IF (@strChangeDescription = 'Counted')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'strCounted')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Counted')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Count By Serial No
			ELSE IF (@strChangeDescription = 'Count By Serial No')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'ysnCountBySINo')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Count by Serial Number')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Vendor Minimum Order Qty
			ELSE IF (@strChangeDescription = 'Vendor Minimum Order Qty')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'dblMinOrder')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Min Order')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Vendor Suggested Qty
			ELSE IF (@strChangeDescription = 'Vendor Suggested Qty')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'dblSuggestedQty')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Suggested Qty')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Inventory Group
			ELSE IF (@strChangeDescription = 'Inventory Group')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'intCountGroupId')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Inventory Count Group')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Min Qty On Hand
			ELSE IF (@strChangeDescription = 'Min Qty On Hand')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'dblReorderPoint')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Reorder Point')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			
			-- Vendor
			ELSE IF (@strChangeDescription = 'Vendor')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'strVendorName')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Vendor')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END

			-- Storage Location
			ELSE IF (@strChangeDescription = 'Storage Location')
			BEGIN
				SET @strItemLocationTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																	   , '{CHANGECOLUMN}', 'strSubLocationName')
				                                                       , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																	   , '{FROM}', @strFromData)
																	   , '{TO}', @strToData)
																	   , '{CHANGEDESC}', 'Storage Location')
				SET @strItemLocationChildrenJson = @strItemLocationChildrenJson + @strItemLocationTempJson
			END
			--===================================================================================================
			-- END Audit Log tblICItemLocation
			--===================================================================================================



			--===================================================================================================
			-- START Audit Log tblICItem
			--===================================================================================================
			-- 'Category'
			IF (@strChangeDescription = 'Category')
					BEGIN
						SET @strItemTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																			   , '{CHANGECOLUMN}', 'strCategoryCode')
																			   , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																			   , '{FROM}', @strFromData)
																			   , '{TO}', @strToData)
																			   , '{CHANGEDESC}', 'Category')
						SET @strItemChildrenJson = @strItemChildrenJson + @strItemTempJson
					END

				--'Count Code'
				ELSE IF (@strChangeDescription = 'Count Code')
					BEGIN
						SET @strItemTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormat
																			   , '{CHANGECOLUMN}', 'strCountCode')
																			   , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																			   , '{FROM}', @strFromData)
																			   , '{TO}', @strToData)
																			   , '{CHANGEDESC}', 'Count Code')
						SET @strItemChildrenJson = @strItemChildrenJson + @strItemTempJson
					END
			--===================================================================================================
			-- END Audit Log tblICItem
			--===================================================================================================




			--===================================================================================================
			-- START Audit Log tblICItemAccount
			--===================================================================================================
			-- 'Cost of Goods Sold Account'
			ELSE IF (@strChangeDescription = 'Cost of Goods Sold Account' OR @strChangeDescription = 'Sales Account')
					BEGIN
						SET @strItemAccountTempJson = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strJsonFormatItemAccounts
																			   , '{CHANGECOLUMN}', 'strAccountId')
																			   , '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
																			   , '{FROM}', @strFromData)
																			   , '{TO}', @strToData)
																			   , '{CHANGEDESC}', @strChangeDescription)
						SET @strItemAccountChildrenJson = @strItemAccountChildrenJson + @strItemAccountTempJson
					END

			ELSE IF (@strChangeDescription = 'Add New Cost of Goods Sold Account')
					BEGIN
						
						IF EXISTS(SELECT intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Cost of Goods')
							BEGIN
									SET @intAccountCategoryId =  (SELECT intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Cost of Goods')
									SET @strNewItemAccountTempJson = REPLACE(REPLACE(@strJsonFormatCreateNewItemAccounts
																						   , '{ACCOUNTID}', @strToData)
																						   , '{CREATEDID}', (SELECT intItemAccountId FROM tblICItemAccount WHERE intItemId = @intParentId AND intAccountCategoryId = @intAccountCategoryId))
									SET @strNewItemAccountChildrenJson = @strNewItemAccountChildrenJson + @strNewItemAccountTempJson
							END
						
					END
			ELSE IF (@strChangeDescription = 'Add New Sales Account')
					BEGIN
						IF EXISTS(SELECT intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Sales Account')
							BEGIN
									SET @intAccountCategoryId =  (SELECT intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = 'Sales Account')
									SET @strNewItemAccountTempJson = REPLACE(REPLACE(@strJsonFormatCreateNewItemAccounts
																						   , '{ACCOUNTID}', @strToData)
																						   , '{CREATEDID}', (SELECT intItemAccountId FROM tblICItemAccount WHERE intItemId = @intParentId AND intAccountCategoryId = @intAccountCategoryId))
									SET @strNewItemAccountChildrenJson = @strNewItemAccountChildrenJson + @strNewItemAccountTempJson
							END
					END
			--===================================================================================================
			-- END Audit Log tblICItemAccount
			--===================================================================================================




			DELETE FROM @tblTemp WHERE intId = @intKeyId
		END


		-- INSERT TO AUDIT LOG Group by intChildId
		-- tblICItemLocation
		IF(@strItemLocationChildrenJson != '')
			BEGIN
						SET @strCompanyLocation = (SELECT strLocationName FROM tblSMCompanyLocation
													WHERE intCompanyLocationId = 
													(
														SELECT intLocationId FROM tblICItemLocation
														WHERE intItemLocationId = @intChildId
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
							"keyValue": ' + CAST(@intChildId AS NVARCHAR(50)) + ', 
							"iconCls": "small-tree-modified",
							"children": [
							' + @strItemLocationChildrenJson + '
							]
						}'


						INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
						VALUES(
								'Updated'
								, 'Inventory.view.ItemLocation'
								, @intChildId
								, ''
								, null
								, @JsonStringAuditLog
								, GETUTCDATE()
								, @currentUserId
								, 1
						)
			END


		IF(@strNewItemAccountChildrenJson != '')
			BEGIN
						SET @strItemNo = ISNULL((SELECT strItemNo FROM tblICItem WHERE intItemId = @intParentId), '')

						SET @strNewItemAccountChildrenJson = left(@strNewItemAccountChildrenJson, len(@strNewItemAccountChildrenJson)-1)

						-- INSERT TO Audit Log
						SET @JsonStringAuditLog = 
						N'{
							"action": "Updated",
							"change": "Updated - Record: ' + @strItemNo + '",
							"keyValue": ' + CAST(@intParentId AS NVARCHAR(50)) + ',
							"iconCls": "small-tree-modified",
							"children": [
								{
									"change": "tblICItemAccounts",
									"children": [
										' + @strNewItemAccountChildrenJson + '
									],
									"iconCls": "small-tree-grid",
									"changeDescription": "GL Accounts can be set up for Category instead of every item. Only accounts specific to the item is required to be set up here. GL accounts setup in Item overrides Category."
								}
							]
						}'


						INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
						VALUES(
								'Updated'
								, 'Inventory.view.Item'
								, @intParentId
								, ''
								, null
								, @JsonStringAuditLog
								, GETUTCDATE()
								, @currentUserId
								, 1
						)
			END



		DELETE FROM @tblTemp WHERE intChildId = @intChildId
	END

	
	
	-- INSERT AuditLog (tblICItem)
	-- tblICItem
	IF(@strItemChildrenJson != '')
		BEGIN
				SET @strItemNo = (SELECT strItemNo FROM tblICItem WHERE intItemId = @intParentId)

				SET @strItemChildrenJson = left(@strItemChildrenJson, len(@strItemChildrenJson)-1)

				-- INSERT TO Audit Log
				SET @JsonStringAuditLog = 
				N'{
					"action": "Updated",
					"change": "Updated - Record: ' + @strItemNo + '",
					"keyValue": ' + CAST(@intParentId AS NVARCHAR(50)) + ', 
					"iconCls": "small-tree-modified",
					"children": [
					' + @strItemChildrenJson + '
					]
				}'


				INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
				VALUES(
						'Updated'
						, 'Inventory.view.Item'
						, @intParentId
						, ''
						, null
						, @JsonStringAuditLog
						, GETUTCDATE()
						, @currentUserId
						, 1
					 )
			END
	

	IF(@strItemAccountChildrenJson != '')
			BEGIN
						SET @strItemNo = ISNULL((SELECT strItemNo FROM tblICItem WHERE intItemId = @intParentId), '')

						SET @strItemAccountChildrenJson = left(@strItemAccountChildrenJson, len(@strItemAccountChildrenJson)-1)

						-- INSERT TO Audit Log
						SET @JsonStringAuditLog = 
						N'{
							"action": "Updated",
							"change": "Updated - Record: ' + @strItemNo + '",
							"keyValue": ' + CAST(@intParentId AS NVARCHAR(50)) + ',
							"iconCls": "small-tree-modified",
							"children": [
								' + @strItemAccountChildrenJson + '
							]
						}'


						INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
						VALUES(
								'Updated'
								, 'Inventory.view.Item'
								, @intParentId
								, ''
								, null
								, @JsonStringAuditLog
								, GETUTCDATE()
								, @currentUserId
								, 1
						)
			END




	DELETE FROM @tblTemp WHERE intParentId = @intParentId
END

END