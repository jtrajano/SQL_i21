CREATE PROCEDURE [dbo].[uspRKGetGLAccountsForPosting]
	@intCommodityId INT
	, @intLocationId INT
AS

BEGIN

	DECLARE @intUnrealizedGainOnBasisId INT
		, @intUnrealizedGainOnFuturesId INT
		, @intUnrealizedGainOnCashId INT
		, @intUnrealizedGainOnRatioId INT
		, @intUnrealizedLossOnBasisId INT
		, @intUnrealizedLossOnFuturesId INT
		, @intUnrealizedLossOnCashId INT
		, @intUnrealizedLossOnRatioId INT
		, @intUnrealizedGainOnInventoryBasisIOSId INT
		, @intUnrealizedGainOnInventoryFuturesIOSId INT
		, @intUnrealizedGainOnInventoryCashIOSId INT
		, @intUnrealizedGainOnInventoryRatioIOSId INT
		, @intUnrealizedLossOnInventoryBasisIOSId INT
		, @intUnrealizedLossOnInventoryFuturesIOSId INT
		, @intUnrealizedLossOnInventoryCashIOSId INT
		, @intUnrealizedLossOnInventoryRatioIOSId INT
		, @intUnrealizedGainOnInventoryIntransitIOSId INT
		, @intUnrealizedLossOnInventoryIntransitIOSId INT
		, @intUnrealizedGainOnInventoryIOSId INT
		, @intUnrealizedLossOnInventoryIOSId INT
		, @intFuturesGainOrLossRealizedId INT
		, @intFuturesGainOrLossRealizedOffsetId INT
		, @strUnrealizedGainOnBasisId NVARCHAR(50)
		, @strUnrealizedGainOnFuturesId NVARCHAR(50)
		, @strUnrealizedGainOnCashId NVARCHAR(50)
		, @strUnrealizedGainOnRatioId NVARCHAR(50)
		, @strUnrealizedLossOnBasisId NVARCHAR(50)
		, @strUnrealizedLossOnFuturesId NVARCHAR(50)
		, @strUnrealizedLossOnCashId NVARCHAR(50)
		, @strUnrealizedLossOnRatioId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryBasisIOSId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryFuturesIOSId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryCashIOSId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryRatioIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryBasisIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryFuturesIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryCashIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryRatioIOSId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryIntransitIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryIntransitIOSId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryIOSId NVARCHAR(50)
		, @strFuturesGainOrLossRealizedId NVARCHAR(50)
		, @strFuturesGainOrLossRealizedOffsetId NVARCHAR(50)
		, @UseCompanyPref BIT

	IF (SELECT intPostToGLId FROM tblRKCompanyPreference) = 1
	BEGIN
		SET @UseCompanyPref = CAST(1 AS BIT)
		SELECT @intUnrealizedGainOnBasisId = intUnrealizedGainOnBasisId
			, @intUnrealizedGainOnFuturesId = intUnrealizedGainOnFuturesId
			, @intUnrealizedGainOnCashId = intUnrealizedGainOnCashId
			, @intUnrealizedGainOnRatioId = intUnrealizedGainOnRatioId
			, @intUnrealizedLossOnBasisId = intUnrealizedLossOnBasisId
			, @intUnrealizedLossOnFuturesId = intUnrealizedLossOnFuturesId
			, @intUnrealizedLossOnCashId = intUnrealizedLossOnCashId
			, @intUnrealizedLossOnRatioId = intUnrealizedLossOnRatioId
			, @intUnrealizedGainOnInventoryBasisIOSId = intUnrealizedGainOnInventoryBasisIOSId
			, @intUnrealizedGainOnInventoryFuturesIOSId = intUnrealizedGainOnInventoryFuturesIOSId
			, @intUnrealizedGainOnInventoryCashIOSId = intUnrealizedGainOnInventoryCashIOSId
			, @intUnrealizedGainOnInventoryRatioIOSId = intUnrealizedGainOnInventoryRatioIOSId
			, @intUnrealizedLossOnInventoryBasisIOSId = intUnrealizedLossOnInventoryBasisIOSId
			, @intUnrealizedLossOnInventoryFuturesIOSId = intUnrealizedLossOnInventoryFuturesIOSId
			, @intUnrealizedLossOnInventoryCashIOSId = intUnrealizedLossOnInventoryCashIOSId
			, @intUnrealizedLossOnInventoryRatioIOSId = intUnrealizedLossOnInventoryRatioIOSId
			, @intUnrealizedGainOnInventoryIntransitIOSId = intUnrealizedGainOnInventoryIntransitIOSId
			, @intUnrealizedLossOnInventoryIntransitIOSId = intUnrealizedLossOnInventoryIntransitIOSId
			, @intUnrealizedGainOnInventoryIOSId = intUnrealizedGainOnInventoryIOSId
			, @intUnrealizedLossOnInventoryIOSId = intUnrealizedLossOnInventoryIOSId
			, @intFuturesGainOrLossRealizedId = intFuturesGainOrLossRealizedId
			, @intFuturesGainOrLossRealizedOffsetId = intFuturesGainOrLossRealizedOffsetId
		FROM tblRKCompanyPreference	
	END 
	ELSE
	BEGIN
		SET @UseCompanyPref = CAST(0 AS BIT)
		SELECT DISTINCT c.intAccountId
			, strAccountCategory
		INTO #tmpAcctCategory
		FROM tblICCommodityAccountM2M c
		INNER JOIN tblGLAccountCategory cat ON c.intAccountCategoryId = cat.intAccountCategoryId
		WHERE c.intCommodityId = @intCommodityId

		SELECT TOP 1 @intUnrealizedGainOnBasisId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Basis'
		SELECT TOP 1 @intUnrealizedGainOnFuturesId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Futures'
		SELECT TOP 1 @intUnrealizedGainOnCashId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Cash'
		SELECT TOP 1 @intUnrealizedGainOnRatioId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Ratio'
		SELECT TOP 1 @intUnrealizedLossOnBasisId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Basis'
		SELECT TOP 1 @intUnrealizedLossOnFuturesId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Futures'
		SELECT TOP 1 @intUnrealizedLossOnCashId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Cash'
		SELECT TOP 1 @intUnrealizedLossOnRatioId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Ratio'
		SELECT TOP 1 @intUnrealizedGainOnInventoryBasisIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Basis (Inventory Offset)'
		SELECT TOP 1 @intUnrealizedGainOnInventoryFuturesIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Futures (Inventory Offset)'
		SELECT TOP 1 @intUnrealizedGainOnInventoryCashIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Cash (Inventory Offset)'
		SELECT TOP 1 @intUnrealizedGainOnInventoryRatioIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Ratio (Inventory Offset)'
		SELECT TOP 1 @intUnrealizedLossOnInventoryBasisIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Basis (Inventory Offset)'
		SELECT TOP 1 @intUnrealizedLossOnInventoryFuturesIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Futures (Inventory Offset)'
 		SELECT TOP 1 @intUnrealizedLossOnInventoryCashIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Cash (Inventory Offset)'
		SELECT TOP 1 @intUnrealizedLossOnInventoryRatioIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Ratio (Inventory Offset)'
		SELECT TOP 1 @intUnrealizedGainOnInventoryIntransitIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Intransit (Inventory Offset)'
		SELECT TOP 1 @intUnrealizedLossOnInventoryIntransitIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Intransit (Inventory Offset)'
		SELECT TOP 1 @intUnrealizedGainOnInventoryIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Gain on Inventory (Inventory Offset)' 			
		SELECT TOP 1 @intUnrealizedLossOnInventoryIOSId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Unrealized Loss on Inventory (Inventory Offset)'
		SELECT TOP 1 @intFuturesGainOrLossRealizedId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Futures Gain or Loss Realized'
		SELECT TOP 1 @intFuturesGainOrLossRealizedOffsetId = intAccountId FROM #tmpAcctCategory WHERE strAccountCategory = 'Futures Gain or Loss Realized Offset'

		DROP TABLE #tmpAcctCategory
	END


	SELECT strCategory = 'intUnrealizedGainOnBasisId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Basis', @intUnrealizedGainOnBasisId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedGainOnFuturesId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Futures', @intUnrealizedGainOnFuturesId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedGainOnCashId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Cash', @intUnrealizedGainOnCashId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedGainOnRatioId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Ratio', @intUnrealizedGainOnRatioId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnBasisId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Basis', @intUnrealizedLossOnBasisId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnFuturesId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Futures', @intUnrealizedLossOnFuturesId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnCashId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Cash', @intUnrealizedLossOnCashId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnRatioId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Ratio', @intUnrealizedLossOnRatioId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedGainOnInventoryBasisIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Basis (Inventory Offset)', @intUnrealizedGainOnInventoryBasisIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedGainOnInventoryFuturesIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Futures (Inventory Offset)', @intUnrealizedGainOnInventoryFuturesIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedGainOnInventoryCashIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Cash (Inventory Offset)', @intUnrealizedGainOnInventoryCashIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedGainOnInventoryRatioIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Ratio (Inventory Offset)', @intUnrealizedGainOnInventoryRatioIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnInventoryBasisIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Basis (Inventory Offset)', @intUnrealizedLossOnInventoryBasisIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnInventoryFuturesIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Futures (Inventory Offset)', @intUnrealizedLossOnInventoryFuturesIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnInventoryCashIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Cash (Inventory Offset)', @intUnrealizedLossOnInventoryCashIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnInventoryRatioIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Ratio (Inventory Offset)', @intUnrealizedLossOnInventoryRatioIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedGainOnInventoryIntransitIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Intransit (Inventory Offset)', @intUnrealizedGainOnInventoryIntransitIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnInventoryIntransitIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Intransit (Inventory Offset)', @intUnrealizedLossOnInventoryIntransitIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedGainOnInventoryIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Gain on Inventory (Inventory Offset)', @intUnrealizedGainOnInventoryIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intUnrealizedLossOnInventoryIOSId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Unrealized Loss on Inventory (Inventory Offset)', @intUnrealizedLossOnInventoryIOSId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intFuturesGainOrLossRealizedId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Futures Gain or Loss Realized', @intFuturesGainOrLossRealizedId, @intCommodityId, @intLocationId)

	UNION ALL SELECT strCategory = 'intFuturesGainOrLossRealizedOffsetId'
		, intAccountId
		, strAccountNo
		, ysnHasError
		, strErrorMessage
	FROM dbo.fnRKGetAccountIdForLocationLOB('Futures Gain or Loss Realized Offset', @intFuturesGainOrLossRealizedOffsetId, @intCommodityId, @intLocationId)
END