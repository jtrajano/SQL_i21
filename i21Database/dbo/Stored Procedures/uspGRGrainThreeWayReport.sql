CREATE PROCEDURE [dbo].[uspGRGrainThreeWayReport]
--	@emailProfileName AS NVARCHAR(MAX) = NULL
--	,@emailRecipient AS NVARCHAR(MAX) = NULL
	@xmlParam NVARCHAR(MAX)
AS
SET FMTONLY OFF

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE 
(
	[fieldname] NVARCHAR(50)
	,[condition] NVARCHAR(20)
	,[from] NVARCHAR(MAX)
	,[to] NVARCHAR(MAX)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
)
DECLARE @xmlDocumentId AS INT

EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH 
(
	[fieldname] NVARCHAR(50)
	,[condition] NVARCHAR(20)
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
)

DECLARE @intCommodityId INT
DECLARE @strCommodityCode NVARCHAR(100)
DECLARE @intCompanyLocationId INT
DECLARE @strLocationName NVARCHAR(200)

SELECT @intCommodityId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intCommodityId'

DECLARE @Locations AS TABLE (
	intCompanyLocationId INT
	,strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
DECLARE @Commodities AS TABLE (
	intCommodityId INT
	,strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
)


DECLARE @table1 TABLE
(
	Valuation_Stock_Quantity DECIMAL(18,6)
	,DPR_CompanyOwned DECIMAL(18,6)
	,DIFF DECIMAL(18,6)
)

DECLARE @table2 TABLE
(
	Inventory_Stock_Quantity DECIMAL(18,6)
	,DPR_CustomerOwned DECIMAL(18,6)
	,DIFF DECIMAL(18,6)
)

DECLARE @table3 TABLE
(
	strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strStorageType NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblDPR DECIMAL(18,6)
	,dblGrainBalance_view DECIMAL(18,6)
	,DIFF_DPR_VS_GRAIN_VIEW DECIMAL(18,6)
)

DECLARE @FinalReport AS TABLE
(
	strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblInventoryCompanyOwned DECIMAL(18,6) DEFAULT 0
	,dblInventoryStockDetails DECIMAL(18,6) DEFAULT 0
	,dblDPRCompanyOwned DECIMAL(18,6) DEFAULT 0
	,dblDPRCustomerOwned DECIMAL(18,6) DEFAULT 0
	,dblDiffCompanyOwned DECIMAL(18,6) DEFAULT 0
	,dblDiffCustomerOwned DECIMAL(18,6) DEFAULT 0
	,dblDPRDelayedPricing DECIMAL(18,6) DEFAULT 0
	,dblDPROpenStorage DECIMAL(18,6) DEFAULT 0
	,dblDPRWarehouseReceipt DECIMAL(18,6) DEFAULT 0
	,dblDPRTerminal DECIMAL(18,6) DEFAULT 0
	,dblDPRGrainBank DECIMAL(18,6) DEFAULT 0
	,dblGrainDelayedPricing DECIMAL(18,6) DEFAULT 0
	,dblGrainOpenStorage DECIMAL(18,6) DEFAULT 0
	,dblGrainWarehouseReceipt DECIMAL(18,6) DEFAULT 0
	,dblGrainTerminal DECIMAL(18,6) DEFAULT 0
	,dblGrainGrainBank DECIMAL(18,6) DEFAULT 0
	,dblDiffDelayedPricing DECIMAL(18,6) DEFAULT 0
	,dblDiffOpenStorage DECIMAL(18,6) DEFAULT 0
	,dblDiffWarehouseReceipt DECIMAL(18,6) DEFAULT 0
	,dblDiffTerminal DECIMAL(18,6) DEFAULT 0
	,dblDiffGrainBank DECIMAL(18,6) DEFAULT 0

)

INSERT INTO @Locations
--SELECT TOP 2 * FROM (
SELECT DISTINCT intCompanyLocationId, strLocationName FROM tblSMCompanyLocation --WHERE ysnActive = 1--) A

--select * from @Locations

INSERT INTO @Commodities
SELECT DISTINCT intCommodityId, strCommodityCode FROM vyuGRStorageSearchView WHERE intCommodityId = ISNULL(@intCommodityId,intCommodityId)

INSERT INTO @FinalReport ( strCommodityCode, strLocationName )
SELECT C.strCommodityCode,strLocationName FROM @Locations L OUTER APPLY (SELECT * FROM @Commodities) C

WHILE EXISTS(SELECT 1 FROM @Commodities)
BEGIN
	SELECT TOP 1
		@intCommodityId		= intCommodityId
		,@strCommodityCode	= strCommodityCode
	FROM @Commodities

	DELETE FROM @table3
	INSERT INTO @table3
	SELECT * FROM dbo.fnGRDPRvsGrain(@intCommodityId)

	SELECT @intCompanyLocationId = MIN(intCompanyLocationId) FROM @Locations

	WHILE @intCompanyLocationId > 0
	BEGIN
		SELECT @strLocationName = strLocationName FROM @Locations WHERE intCompanyLocationId = @intCompanyLocationId
		
		/****Inventory Valuation vs DPR Company Owned****/
		DELETE FROM @table1
		INSERT INTO @table1
		SELECT * FROM dbo.fnGRValuationSummaryVsDPRCompanyOwned(@strLocationName,@strCommodityCode,@intCommodityId)

		UPDATE Fin
		SET dblInventoryCompanyOwned = t.Valuation_Stock_Quantity
			,dblDPRCompanyOwned = t.DPR_CompanyOwned
			,dblDiffCompanyOwned = t.DIFF
		FROM @FinalReport Fin
		OUTER APPLY (
			SELECT * FROM @table1
		) t
		WHERE Fin.strLocationName = @strLocationName
			AND Fin.strCommodityCode = @strCommodityCode

		/****Inventory Stocks vs DPR Customer Owned****/
		DELETE FROM @table2
		INSERT INTO @table2
		SELECT * FROM dbo.fnGRInventoryStocksVSDPRStorage(@strLocationName,@strCommodityCode,@intCommodityId)

		UPDATE Fin
		SET dblInventoryStockDetails = t.Inventory_Stock_Quantity
			,dblDPRCustomerOwned = t.DPR_CustomerOwned
			,dblDiffCustomerOwned = t.DIFF
		FROM @FinalReport Fin
		OUTER APPLY (
			SELECT * FROM @table2
		) t
		WHERE Fin.strLocationName = @strLocationName
			AND Fin.strCommodityCode = @strCommodityCode

		/****DPR vs Grain Storage****/
		DECLARE @tblStorageTypes AS TABLE
		(
			strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblDPR DECIMAL(18,6)
			,dblGrainBalance_view DECIMAL(18,6)
			,DIFF_DPR_VS_GRAIN_VIEW DECIMAL(18,6)
		)
		
		/*******DELAYED PRICING********/
		DELETE FROM @tblStorageTypes
		INSERT INTO @tblStorageTypes
		SELECT strLocationName,dblDPR,dblGrainBalance_view,DIFF_DPR_VS_GRAIN_VIEW
		FROM @table3
		WHERE strStorageType = 'DELAYED PRICING'
			AND strLocationName = @strLocationName

		UPDATE Fin
		SET dblDPRDelayedPricing = DP.dblDPR
			,dblGrainDelayedPricing = DP.dblGrainBalance_view
			,dblDiffDelayedPricing = DP.DIFF_DPR_VS_GRAIN_VIEW
		FROM @FinalReport Fin
		INNER JOIN @tblStorageTypes DP
			ON DP.strLocationName = Fin.strLocationName
		WHERE Fin.strCommodityCode = @strCommodityCode		
		
		/*******OPEN STORAGE********/
		DELETE FROM @tblStorageTypes
		INSERT INTO @tblStorageTypes
		SELECT strLocationName,dblDPR,dblGrainBalance_view,DIFF_DPR_VS_GRAIN_VIEW
		FROM @table3
		WHERE strStorageType = 'OPEN STORAGE'
			AND strLocationName = @strLocationName

		UPDATE Fin
		SET dblDPROpenStorage = OS.dblDPR
			,dblGrainOpenStorage = OS.dblGrainBalance_view
			,dblDiffOpenStorage = OS.DIFF_DPR_VS_GRAIN_VIEW
		FROM @FinalReport Fin
		INNER JOIN @tblStorageTypes OS
			ON OS.strLocationName = Fin.strLocationName
		WHERE Fin.strCommodityCode = @strCommodityCode
		
		/*******WAREHOUSE RECEIPT********/
		DELETE FROM @tblStorageTypes
		INSERT INTO @tblStorageTypes
		SELECT strLocationName,dblDPR,dblGrainBalance_view,DIFF_DPR_VS_GRAIN_VIEW
		FROM @table3
		WHERE strStorageType = 'WAREHOUSE RECEIPT'
			AND strLocationName = @strLocationName

		UPDATE Fin
		SET dblDPRWarehouseReceipt = WR.dblDPR
			,dblGrainWarehouseReceipt = WR.dblGrainBalance_view
			,dblDiffWarehouseReceipt = WR.DIFF_DPR_VS_GRAIN_VIEW
		FROM @FinalReport Fin
		INNER JOIN @tblStorageTypes WR
			ON WR.strLocationName = Fin.strLocationName
		WHERE Fin.strCommodityCode = @strCommodityCode
		
		/*******TERMINAL********/
		DELETE FROM @tblStorageTypes
		INSERT INTO @tblStorageTypes
		SELECT strLocationName,dblDPR,dblGrainBalance_view,DIFF_DPR_VS_GRAIN_VIEW
		FROM @table3
		WHERE strStorageType = 'TERMINAL'
			AND strLocationName = @strLocationName

		UPDATE Fin
		SET dblDPRTerminal = TE.dblDPR
			,dblGrainTerminal = TE.dblGrainBalance_view
			,dblDiffTerminal= TE.DIFF_DPR_VS_GRAIN_VIEW
		FROM @FinalReport Fin
		INNER JOIN @tblStorageTypes TE
			ON TE.strLocationName = Fin.strLocationName
		WHERE Fin.strCommodityCode = @strCommodityCode
		
		/*******GRAIN BANK********/
		DELETE FROM @tblStorageTypes
		INSERT INTO @tblStorageTypes
		SELECT strLocationName,dblDPR,dblGrainBalance_view,DIFF_DPR_VS_GRAIN_VIEW
		FROM @table3
		WHERE strStorageType = 'GRAIN BANK'
			AND strLocationName = @strLocationName

		UPDATE Fin
		SET dblDPRGrainBank = GB.dblDPR
			,dblGrainGrainBank = GB.dblGrainBalance_view
			,dblDiffGrainBank = GB.DIFF_DPR_VS_GRAIN_VIEW
		FROM @FinalReport Fin
		INNER JOIN @tblStorageTypes GB
			ON GB.strLocationName = Fin.strLocationName
		WHERE Fin.strCommodityCode = @strCommodityCode

		SELECT @intCompanyLocationId = MIN(intCompanyLocationId) FROM @Locations WHERE intCompanyLocationId > @intCompanyLocationId
	END

	DELETE FROM @Commodities WHERE intCommodityId = @intCommodityId
END

SELECT * 
FROM @FinalReport 
WHERE dblInventoryCompanyOwned <> 0
	OR dblInventoryStockDetails <> 0
	OR dblDPRCompanyOwned <> 0
	OR dblDPRCustomerOwned <> 0
	OR dblDiffCompanyOwned <> 0
	OR dblDiffCustomerOwned <> 0
	OR dblDPRDelayedPricing <> 0
	OR dblDPROpenStorage <> 0
	OR dblDPRWarehouseReceipt <> 0
	OR dblDPRTerminal <> 0
	OR dblDPRGrainBank <> 0
	OR dblGrainDelayedPricing <> 0
	OR dblGrainOpenStorage <> 0
	OR dblGrainWarehouseReceipt <> 0
	OR dblGrainTerminal <> 0
	OR dblGrainGrainBank <> 0
	OR dblDiffDelayedPricing <> 0
	OR dblDiffOpenStorage <> 0
	OR dblDiffWarehouseReceipt <> 0
	OR dblDiffTerminal <> 0
	OR dblDiffGrainBank <> 0 
ORDER BY strCommodityCode