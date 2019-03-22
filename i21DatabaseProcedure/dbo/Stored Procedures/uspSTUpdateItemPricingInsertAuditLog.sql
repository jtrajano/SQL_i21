CREATE PROCEDURE [dbo].[uspSTUpdateItemPricingInsertAuditLog]
	@currentUserId AS INT
AS
BEGIN

DECLARE @strJson AS NVARCHAR(MAX) = ''
DECLARE @strJsonRemoveComma AS NVARCHAR(MAX) = ''

-- ===================================================================================
-- tblICItemPricings
DECLARE @strStandardCostLog AS NVARCHAR(MAX) = ''
DECLARE @strSalePriceLog AS NVARCHAR(MAX) = ''
DECLARE @ItemPricingCombineRemoveComma AS NVARCHAR(MAX) = ''
DECLARE @strItemPricingRowDataLogRemoveComma AS NVARCHAR(MAX) = ''
DECLARE @strItemPricingRowDataLog AS NVARCHAR(MAX) = ''
DECLARE @strItemPricingRowDataFormatLog AS NVARCHAR(MAX) = ''
DECLARE @strItemPricingRowDataFinalLog AS NVARCHAR(MAX) = ''
DECLARE @strItemPricingFinalLog AS NVARCHAR(MAX) = ''

DECLARE @strDblStandardCost AS NVARCHAR(MAX) =
N'{	
    "change":"dblStandardCost",
    "from":"{FROM}",
    "to":"{TO}",
    "leaf":true,
    "iconCls":"small-gear",
    "isField":true,
    "keyValue":{KEYVALUE},
    "associationKey":"tblICItemPricings",
    "changeDescription":"Standard Cost",
    "hidden":false
},'

DECLARE @strDblSalePrice AS NVARCHAR(MAX) =
N'{
    "change":"dblSalePrice",
    "from":"{FROM}",
    "to":"{TO}",
    "leaf":true,
    "iconCls":"small-gear",
    "isField":true,
    "keyValue":{KEYVALUE},
    "associationKey":"tblICItemPricings",
    "changeDescription":"Retail Price",
    "hidden":false
},'


DECLARE @strTblICItemPricingRowData AS NVARCHAR(MAX) =
N'{
    "action":"Updated",
    "change":"Updated - Record: {UPDATEDRECORD}",
    "keyValue":{KEYVALUE},
    "iconCls":"small-tree-modified",
    "children":[
	{CHILDREN}
	]
},'


DECLARE @strTblICItemPricing AS NVARCHAR(MAX) =
N'{
    "change":"tblICItemPricings",
    "children":[
	{CHILDREN}
	],
    "iconCls":"small-tree-grid",
    "changeDescription":"Pricing"
},'
-- ===================================================================================




-- ===================================================================================
-- tblICItemSpecialPricing
DECLARE @strUnitAfterDiscountLog AS NVARCHAR(MAX) = ''
DECLARE @strBeginDateLog AS NVARCHAR(MAX) = ''
DECLARE @strEndDateLog AS NVARCHAR(MAX) = ''
DECLARE @ItemSpecialPricingCombineRemoveComma AS NVARCHAR(MAX) = '' 
DECLARE @strItemSpecialPricingRowDataLogRemoveComma AS NVARCHAR(MAX) = ''
DECLARE @strItemSpecialPricingRowDataLog AS NVARCHAR(MAX) = ''
DECLARE @strItemSpecialPricingRowDataFormatLog AS NVARCHAR(MAX) = ''
DECLARE @strItemSpecialPricingRowDataFinalLog AS NVARCHAR(MAX) = ''
DECLARE @strItemSpecialPricingFinalLog AS NVARCHAR(MAX) = ''

DECLARE @strDblUnitAfterDiscount AS NVARCHAR(MAX) =
N'{
   "change":"dblUnitAfterDiscount",
   "from":"{FROM}",
   "to":"{TO}",
   "leaf":true,
   "iconCls":"small-gear",
   "isField":true,
   "keyValue":{KEYVALUE},
   "associationKey":"tblICItemSpecialPricings",
   "changeDescription":"Retail Price",
   "hidden":false
},'

DECLARE @strDtmBeginDate AS NVARCHAR(MAX) =
N'{
   "change":"dtmBeginDate",
   "from":"{FROM}",
   "to":"{TO}",
   "leaf":true,
   "iconCls":"small-gear",
   "isField":true,"keyValue":{KEYVALUE},
   "associationKey":"tblICItemSpecialPricings",
   "changeDescription":"Begin Date",
   "hidden":false
},'

DECLARE @strDtmEndDate AS NVARCHAR(MAX) =
N'{
   "change":"dtmEndDate",
   "from":"{FROM}",
   "to":"{TO}",
   "leaf":true,
   "iconCls":"small-gear",
   "isField":true,
   "keyValue":{KEYVALUE},
   "associationKey":"tblICItemSpecialPricings",
   "changeDescription":"End Date",
   "hidden":false
},'

DECLARE @strTblICItemSpecialPricingRowData AS NVARCHAR(MAX) =
N'{
   "action":"Updated",
   "change":"Updated - Record: {UPDATEDRECORD}",
   "keyValue":{KEYVALUE},
   "iconCls":"small-tree-modified",
   "children":[
	{CHILDREN}
	]
},'

DECLARE @strTbltblICItemSpecialPricing AS NVARCHAR(MAX) =
N'{
    "change":"tblICItemSpecialPricings",
    "children":[
	{CHILDREN}
	],
    "iconCls":"small-tree-grid",
    "changeDescription":"Promotional Pricing"
},'


-- ===================================================================================



DECLARE @strAuditLogMaster AS NVARCHAR(MAX) =
N'{
    "action":"Updated",
    "change":"Updated - {UPDATEDRECORD}",
    "keyValue":{KEYVALUE},
    "iconCls":"small-tree-modified",
    "children":[
	{CHILDREN}
	]
}'


-- ##################################################################################
-- tblICItemPricing row data
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


DECLARE @intId AS INT
        , @strLocation AS NVARCHAR(250)
		, @strUpc NVARCHAR(50)
		, @strItemDescription NVARCHAR(250)
		, @strChangeDescription NVARCHAR(100)
		, @strOldData NVARCHAR(MAX)
		, @strNewData NVARCHAR(MAX)
		, @intParentId INT
		, @intChildId INT

-- ################################################## #01
WHILE EXISTS(SELECT * FROM @tblTemp)
BEGIN
	SELECT TOP 1 @intParentId = intParentId FROM @tblTemp


	-- ########################################
	--              START  CLEAR
	-- ########################################
	--tblICItemPricing
	SET @strItemPricingRowDataFinalLog = ''
	SET @ItemPricingCombineRemoveComma = ''
	SET @strItemPricingRowDataFormatLog = ''
	SET @strItemPricingRowDataLog = ''

	--tblICItemSpecialPricing
	SET @strItemSpecialPricingRowDataFinalLog = ''
	SET @ItemSpecialPricingCombineRemoveComma = ''
	SET @strItemSpecialPricingRowDataFormatLog = ''
	SET @strItemSpecialPricingRowDataLog = ''
	-- ########################################
	--               END CLEAR
	-- ########################################



	-- ################################################## #02
	WHILE EXISTS(SELECT * FROM @tblTemp WHERE intParentId = @intParentId)
	BEGIN
		SELECT TOP 1 
			 @intChildId = intChildId
		FROM @tblTemp 
		WHERE intParentId = @intParentId

		SET @strStandardCostLog = ''
		SET @strSalePriceLog = ''
		SET @strUnitAfterDiscountLog = ''
		SET @strBeginDateLog = ''
		SET @strEndDateLog = ''

		-- ##################################################################
		--    UNIQUE row combination ParentId, ChangeDescription, Location 
		-- ##################################################################
		WHILE EXISTS(SELECT * FROM @tblTemp WHERE intParentId = @intParentId AND intChildId = @intChildId)
		BEGIN
			SELECT TOP 1 
			@intId = intId
			, @strLocation = strLocation
			, @strItemDescription = strItemDescription
			, @strOldData = strOldData
			, @strNewData = strNewData
			, @strChangeDescription = strChangeDescription
			FROM @tblTemp 
			WHERE intParentId = @intParentId
			AND intChildId = @intChildId

			IF(@strChangeDescription = 'Standard Cost' OR @strChangeDescription = 'Retail Price')
			BEGIN
				IF(@strChangeDescription = 'Standard Cost')
				BEGIN
					SET @strStandardCostLog = @strDblStandardCost
					SET @strStandardCostLog = REPLACE(REPLACE(REPLACE(@strStandardCostLog, '{KEYVALUE}', @intChildId), '{TO}', @strNewData), '{FROM}', @strOldData)

				END
				ELSE IF(@strChangeDescription = 'Retail Price')
				BEGIN
					SET @strSalePriceLog = @strDblSalePrice
					SET @strSalePriceLog = REPLACE(REPLACE(REPLACE(@strSalePriceLog, '{KEYVALUE}', @intChildId), '{TO}', @strNewData), '{FROM}', @strOldData)
				END
			END
			ELSE IF(@strChangeDescription = 'Sales Price' OR @strChangeDescription = 'Sales start date' OR @strChangeDescription = 'Sales end date')
			BEGIN
				IF(@strChangeDescription = 'Sales Price')
				BEGIN
					SET @strUnitAfterDiscountLog = @strDblUnitAfterDiscount
					SET @strUnitAfterDiscountLog = REPLACE(REPLACE(REPLACE(@strUnitAfterDiscountLog, '{KEYVALUE}', @intChildId), '{TO}', @strNewData), '{FROM}', @strOldData)
				END
				ELSE IF(@strChangeDescription = 'Sales start date')
				BEGIN
					SET @strBeginDateLog = @strDtmBeginDate
					SET @strBeginDateLog = REPLACE(REPLACE(REPLACE(@strBeginDateLog, '{KEYVALUE}', @intChildId), '{TO}', CAST(CONVERT(DATETIME, @strNewData) AS NVARCHAR(30))), '{FROM}', CAST(CONVERT(DATETIME, @strOldData) AS NVARCHAR(30)))
				END
				ELSE IF(@strChangeDescription = 'Sales end date')
				BEGIN
					SET @strEndDateLog = @strDtmEndDate
					SET @strEndDateLog = REPLACE(REPLACE(REPLACE(@strEndDateLog, '{KEYVALUE}', @intChildId), '{TO}', CAST(CONVERT(DATETIME, @strNewData) AS NVARCHAR(30))), '{FROM}', CAST(CONVERT(DATETIME, @strOldData) AS NVARCHAR(30)))
				END
			END

			

			DELETE FROM @tblTemp 
			--WHERE intId = @intId
			WHERE intParentId = @intParentId
			AND intChildId = @intChildId
			AND strChangeDescription = @strChangeDescription
			AND strLocation = @strLocation
		END

		-- Check if has Value
		IF(@strStandardCostLog != '' OR @strSalePriceLog != '')
		BEGIN
			SET @ItemPricingCombineRemoveComma = @strStandardCostLog + CHAR(13) + @strSalePriceLog
			SET @ItemPricingCombineRemoveComma = left(@ItemPricingCombineRemoveComma, len(@ItemPricingCombineRemoveComma)-1)
			SET @strItemPricingRowDataFormatLog = @strTblICItemPricingRowData
			SET @strItemPricingRowDataLog = @strItemPricingRowDataLog + REPLACE(REPLACE(@strItemPricingRowDataFormatLog, '{CHILDREN}', @ItemPricingCombineRemoveComma), '{UPDATEDRECORD}', @strLocation)
		END

		-- Check if has value
		IF(@strUnitAfterDiscountLog != '' OR @strBeginDateLog != '' OR @strEndDateLog != '')
		BEGIN
			SET @ItemSpecialPricingCombineRemoveComma = @strUnitAfterDiscountLog + CHAR(13) + @strBeginDateLog + CHAR(13) + @strEndDateLog
			SET @ItemSpecialPricingCombineRemoveComma = left(@ItemSpecialPricingCombineRemoveComma, len(@ItemSpecialPricingCombineRemoveComma)-1)
			SET @strItemSpecialPricingRowDataFormatLog = @strTblICItemSpecialPricingRowData
			SET @strItemSpecialPricingRowDataLog = @strItemSpecialPricingRowDataLog + REPLACE(REPLACE(@strItemSpecialPricingRowDataFormatLog, '{CHILDREN}', @ItemSpecialPricingCombineRemoveComma), '{UPDATEDRECORD}', @strLocation)
		END

		DELETE FROM @tblTemp 
		WHERE intChildId = @intChildId
		AND intParentId = @intParentId

	END

	-- Final
	IF(@strItemPricingRowDataLog != '')
	BEGIN
		SET @strItemPricingRowDataLogRemoveComma = left(@strItemPricingRowDataLog, len(@strItemPricingRowDataLog)-1)
		SET @strItemPricingFinalLog = @strTblICItemPricing
		SET @strItemPricingRowDataFinalLog = @strItemPricingRowDataFinalLog + REPLACE(REPLACE(@strItemPricingFinalLog, '{CHILDREN}', @strItemPricingRowDataLogRemoveComma), '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
	END
	
	IF(@strItemSpecialPricingRowDataLog != '')
	BEGIN
		SET @strItemSpecialPricingRowDataLogRemoveComma = left(@strItemSpecialPricingRowDataLog, len(@strItemSpecialPricingRowDataLog)-1)
		SET @strItemSpecialPricingFinalLog = @strTbltblICItemSpecialPricing
		SET @strItemSpecialPricingRowDataFinalLog = @strItemSpecialPricingRowDataFinalLog + REPLACE(REPLACE(@strItemSpecialPricingFinalLog, '{CHILDREN}', @strItemSpecialPricingRowDataLogRemoveComma), '{KEYVALUE}', CAST(@intChildId AS NVARCHAR(50)))
	END

	
	SET @strJsonRemoveComma = @strItemPricingRowDataFinalLog + CHAR(13) + @strItemSpecialPricingRowDataFinalLog
	SET @strJsonRemoveComma = left(@strJsonRemoveComma, len(@strJsonRemoveComma)-1)
	SET @strJson = @strAuditLogMaster
	SET @strJson = REPLACE(REPLACE(@strJson, '{CHILDREN}', @strJsonRemoveComma), '{KEYVALUE}', CAST(@intParentId AS NVARCHAR(50)))
	

	INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
	VALUES(
			'Updated'
			, 'Inventory.view.Item'
			, @intParentId
			, ''
			, null
			, @strJson
			, GETUTCDATE()
			, @currentUserId
			, 1
		)

	-- Remove from Loop #01
	DELETE FROM @tblTemp 
	WHERE intParentId = @intParentId
END
-- ##################################################################################


--PRINT REPLACE(REPLACE(@strTest, '{0}', 'Makati'), '{1}', '21')
--PRINT FORMATMESSAGE('Hello %s, %i', 'Henry', 30)

END