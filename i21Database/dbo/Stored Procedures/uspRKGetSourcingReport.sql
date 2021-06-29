CREATE PROCEDURE dbo.uspRKGetSourcingReport
	@ContractFromDate	NVARCHAR(50)	= ''		-- This should be in @DateFormat format. If it leave as blank it will be automatically set to 01/01/1900. Default is blank.
	,@ContractToDate	NVARCHAR(50)	= ''		-- This should be in @DateFormat format. Default value is today's date. *Required field.
	,@Commodity			NVARCHAR(100)	= ''		-- *Required field.
	,@UOM				NVARCHAR(100)	= ''		-- *Required field.
	,@Currency			NVARCHAR(100)	= ''		-- *Required field.
	,@Book				NVARCHAR(100)	= ''
	,@SubBook			NVARCHAR(100)	= ''
	,@AOPYear			NVARCHAR(100)	= ''
	,@ByProducer		BIT				= 0			-- Defailt value is 0
	,@DateFormat		NVARCHAR(100)	= ''		-- It can be dd/MM/yyyy or MM/dd/yyyy. Default date format is MM/dd/yyyy
AS
--=====================================
-- Actual data gathering starts here
--=====================================
BEGIN TRY

DECLARE @dtmFromDate DATETIME = NULL
	, @dtmToDate DATETIME = NULL
	, @intCommodityId INT = NULL
	, @intUnitMeasureId INT = NULL
	, @ysnVendorProducer BIT = NULL
	, @intBookId INT = NULL
	, @intSubBookId INT = NULL
	, @strYear NVARCHAR(10) = NULL
	, @dtmAOPFromDate DATETIME = NULL
	, @dtmAOPToDate DATETIME = NULL
	, @intCurrencyId INT = NULL
	, @ErrorMessage  NVARCHAR(4000)
    , @ErrorSeverity INT 
    , @ErrorState    INT
	, @strCustomErrorMsg NVARCHAR(4000) = ''

IF @DateFormat = ''
BEGIN
	SET @DateFormat = 'MM/dd/yyyy'
END

IF @DateFormat = 'dd/MM/yyyy'	
BEGIN
	SET @dtmFromDate = CONVERT(DATETIME,@ContractFromDate,103) 
	SET @dtmToDate = CONVERT(DATETIME,@ContractToDate,103)
END
IF @DateFormat = 'MM/dd/yyyy'	
BEGIN
	SET @dtmFromDate = CONVERT(DATETIME,@ContractFromDate,101) 
	SET @dtmToDate = CONVERT(DATETIME,@ContractToDate,101)
END


IF ISNULL(@dtmFromDate,'') = ''
BEGIN
	SET @dtmFromDate = '01-01-1900'
END


SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = @Commodity
SELECT @intUnitMeasureId = intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure CUM INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId WHERE CUM.intCommodityId = @intCommodityId AND UM.strUnitMeasure = @UOM
SELECT @intCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency = @Currency


IF ISNULL(@Book,'') = ''
BEGIN
	SET @intBookId = 0
END

IF ISNULL(@SubBook,'') = ''
BEGIN
	SET @intSubBookId = 0
END

IF ISNULL(@AOPYear,'') = ''
BEGIN
	SET @strYear = 0
	SET @dtmAOPFromDate = '1900-01-01'
	SET @dtmAOPToDate = '1900-01-01'
END
ELSE
BEGIN
	SELECT TOP 1 
		@strYear = strYear
		,@dtmAOPFromDate = dtmFromDate
		,@dtmAOPToDate = dtmToDate 
	FROM vyuRKAOP 
	WHERE  intCommodityId = @intCommodityId AND strYear = @AOPYear
END


SET @ysnVendorProducer = @ByProducer



--Parameters validation

IF ISNULL(@dtmToDate,'')  = ''
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Contract To Date is invalid.' + CHAR(10);
END

IF @intCommodityId IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Commodity is invalid.' + CHAR(10);
END

IF @intUnitMeasureId IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'UOM is invalid.' + CHAR(10);
END

IF @intCurrencyId IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Currency is invalid.' + CHAR(10);
END


IF ISNULL(@strCustomErrorMsg,'') <> ''
BEGIN
	RAISERROR ( @strCustomErrorMsg ,16,1)
END

DECLARE @tmpRawData AS TABLE (
	intRowNum INT
	, strName NVARCHAR(MAX)
	, strLocationName NVARCHAR(100)
	, dblQty NUMERIC(24,2)
	, dblTotPurchased NUMERIC(24,2)
	, dblCompanySpend NUMERIC(24,2)
	, dblStandardQty NUMERIC(24,2)
)

DECLARE @GetStandardQty AS TABLE (intRowNum INT
		, intContractDetailId INT
		, strEntityName NVARCHAR(MAX)
		, intContractHeaderId INT
		, strContractSeq NVARCHAR(100)
		, dblQty NUMERIC(24,10)
		, dblReturnQty NUMERIC(24,10)
		, dblBalanceQty NUMERIC(24,10)
		, dblNoOfLots NUMERIC(24,10)
		, dblFuturesPrice NUMERIC(24,10)
		, dblSettlementPrice NUMERIC(24,10)
		, dblBasis NUMERIC(24,10)
		, dblRatio NUMERIC(24,10)
		, dblPrice NUMERIC(24,10)
		, dblTotPurchased NUMERIC(24,10)
		, dblStandardRatio NUMERIC(24,10)
		, dblStandardQty NUMERIC(24,10)
		, intItemId INT
		, dblStandardPrice NUMERIC(24,10)
		, dblPPVBasis NUMERIC(24,10)
		, dblNewPPVPrice NUMERIC(24,10)
		, dblStandardValue NUMERIC(24,10)
		, dblPPV NUMERIC(24,10)
		, dblPPVNew NUMERIC(24,10)
		, strLocationName NVARCHAR(100)
		, strPricingType NVARCHAR(100)
		, strItemNo NVARCHAR(100)
		, strProductType NVARCHAR(100)
		, strCurrency NVARCHAR(100)
		, strUnitMeasure NVARCHAR(100))
	
INSERT INTO @GetStandardQty(intRowNum
	, intContractDetailId
	, strEntityName
	, intContractHeaderId
	, strContractSeq
	, dblQty
	, dblReturnQty
	, dblBalanceQty
	, dblNoOfLots
	, dblFuturesPrice
	, dblSettlementPrice
	, dblBasis
	, dblRatio
	, dblPrice
	, dblTotPurchased
	, dblStandardRatio
	, dblStandardQty
	, intItemId
	, dblStandardPrice
	, dblPPVBasis
	, strLocationName
	, dblNewPPVPrice
	, dblStandardValue
	, dblPPV
	, dblPPVNew
	, strPricingType
	, strItemNo
	, strProductType
	, strCurrency
	, strUnitMeasure)
EXEC [uspRKSourcingReportDetail] @dtmFromDate = @dtmFromDate
	, @dtmToDate = @dtmToDate
	, @intCommodityId = @intCommodityId
	, @intUnitMeasureId = @intUnitMeasureId
	, @strEntityName = NULL
	, @ysnVendorProducer = @ysnVendorProducer
	, @intBookId = @intBookId
	, @intSubBookId = @intSubBookId
	, @strYear = @strYear
	, @dtmAOPFromDate = @dtmAOPFromDate
	, @dtmAOPToDate = @dtmAOPToDate
	, @strLocationName = ''
	, @intCurrencyId = @intCurrencyId


INSERT INTO @tmpRawData(
	intRowNum
	,strName
	,strLocationName
	,dblQty
	,dblTotPurchased
	,dblCompanySpend
	,dblStandardQty
)
SELECT
	intRowNum = CAST(ROW_NUMBER() OVER (ORDER BY strEntityName) AS INT) 
	, strEntityName strName
	, strLocationName
	, dblQty = SUM(dblBalanceQty)
	, dblTotPurchased = SUM(dblTotPurchased)
	, dblCompanySpend = (SUM(dblTotPurchased) / SUM(CASE WHEN ISNULL(SUM(dblTotPurchased), 0) = 0 THEN 1 ELSE SUM(dblTotPurchased) END) OVER ()) * 100
	, dblStandardQty = SUM(dblStandardQty)
FROM @GetStandardQty
GROUP BY strEntityName
	, strEntityName
	, strLocationName

--====================================
-- Actual data gathering ends here
--=====================================

--===========================================================================================================================================================================================================
--																								Results Ouput
--===========================================================================================================================================================================================================


--===========================
-- SOURCING REPORT - SUMMARY
--===========================

SELECT 
	'Supplier name' = strName
	,'Location' = strLocationName
	,'Total Purchase Volumes' = dblQty
	,'Total Standard Volumes' = dblStandardQty
	,'Total Purchased Value' = dblTotPurchased
	,'% Spent' = dblCompanySpend
FROM @tmpRawData
ORDER BY intRowNum

END TRY

BEGIN CATCH

	 SELECT 
        @ErrorMessage = ERROR_MESSAGE(), 
        @ErrorSeverity = ERROR_SEVERITY(), 
        @ErrorState = ERROR_STATE();

    -- return the error inside the CATCH block
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH