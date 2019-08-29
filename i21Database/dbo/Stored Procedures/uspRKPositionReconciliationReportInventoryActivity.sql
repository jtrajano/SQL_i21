CREATE PROCEDURE uspRKPositionReconciliationReportInventoryActivity
	@intCommodityId INT 
	,@dtmFromTransactionDate DATE 
	,@dtmToTransactionDate DATE
	,@intQtyUOMId INT = NULL

AS

--DECLARE
--@intCommodityId INT  = 1
--	,@dtmFromTransactionDate DATE  = '07/01/2019'
--	,@dtmToTransactionDate DATE = '07/31/2019'
--	,@intQtyUOMId INT = NULL


BEGIN

	DECLARE @InHouse TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, dblInvIn NUMERIC(24,10)
		, dblInvOut NUMERIC(24,10)
		, dblAdjustments NUMERIC(24,10)
		, dblInventoryCount NUMERIC(24,10)
		, dblBalanceInv NUMERIC(24,10)
		, strTransactionId NVARCHAR(50)
		, intTransactionId INT
		, strDistribution NVARCHAR(10)
		, dblSalesInTransit NUMERIC(24,10)
		, strTransactionType NVARCHAR(50)
	)

	INSERT INTO @InHouse (dtmDate
		, dblInvIn
		, dblInvOut
		, dblAdjustments
		, dblInventoryCount
		, strTransactionId
		, intTransactionId
		, strDistribution
		, dblBalanceInv
		, dblSalesInTransit
		, strTransactionType
	)
	EXEC uspRKGetInHouse
		 @dtmFromTransactionDate  = @dtmFromTransactionDate
		, @dtmToTransactionDate  = @dtmToTransactionDate
		, @intCommodityId  = @intCommodityId
		, @intItemId  = null
		, @strPositionIncludes  = NULL
		, @intLocationId  = NULL

	SELECT  
		intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate, Id ASC))
		,dtmTransactionDate =  dtmDate
		,dblInvIn = CASE 
						WHEN dblAdjustments IS NOT NULL AND dblAdjustments > 0 THEN 
							dblAdjustments 
						WHEN dblInventoryCount IS NOT NULL AND dblInventoryCount > 0 THEN 
							dblInventoryCount 
						ELSE 
							ISNULL(dblInvIn,0) 
					END
		,dblInvOut = CASE 
						WHEN dblAdjustments IS NOT NULL AND dblAdjustments < 0 THEN 
							dblAdjustments 
						WHEN dblInventoryCount IS NOT NULL AND dblInventoryCount < 0 THEN 
							dblInventoryCount 
						ELSE
							ISNULL(dblInvOut,0)
					END
		,strTransactionType
		,strTransactionId
		,intTransactionId
	INTO #tmpInventoryActivity
	FROM @InHouse
	WHERE (dtmDate IS NOT NULL
		AND dblInvIn IS NOT NULL
		OR dblInvOut IS NOT NULL
		OR dblAdjustments IS NOT NULL
		OR dblInventoryCount IS NOT NULL
		OR strTransactionId IS NOT NULL
		OR intTransactionId IS NOT NULL
		OR strDistribution IS NOT NULL)


	SELECT	intRowNum 
	INTO #tempDateRange
	FROM #tmpInventoryActivity AS d

	declare @tblRunningBalance as table (
		intRowNum  INT  NULL
		,dblInvBalance  NUMERIC(18,6)
	)

	Declare @intRowNum int
			,@dblInvBeginBalance  NUMERIC(18,6)

	SELECT @dblInvBeginBalance =  dblBalanceInv
	FROM @InHouse
	WHERE dtmDate IS NULL

	insert into @tblRunningBalance(
		intRowNum
		,dblInvBalance
	)
	values(null,@dblInvBeginBalance)
	

	While (Select Count(*) From #tempDateRange) > 0
	Begin

		Select Top 1 @intRowNum = intRowNum From #tempDateRange

		insert into @tblRunningBalance(
			intRowNum
			,dblInvBalance
		)
		select @intRowNum
			,@dblInvBeginBalance + ( dblInvIn - dblInvOut)  
		from #tmpInventoryActivity 
		WHERE intRowNum = @intRowNum
	
		select 
			@dblInvBeginBalance = dblInvBalance 
		from @tblRunningBalance where intRowNum = @intRowNum
						
		Delete #tempDateRange Where intRowNum = @intRowNum

	End

	SELECT
		IA.intRowNum
		,dtmTransactionDate
		,dblInvIn
		,dblInvOut
		,dblInvBalance
		,strTransactionType
		,strTransactionId
		,intTransactionId
	FROM #tmpInventoryActivity IA
	FULL JOIN @tblRunningBalance RB on RB.intRowNum = IA.intRowNum
	ORDER BY IA.dtmTransactionDate


	DROP TABLE #tmpInventoryActivity
	DROP TABLE #tempDateRange

END