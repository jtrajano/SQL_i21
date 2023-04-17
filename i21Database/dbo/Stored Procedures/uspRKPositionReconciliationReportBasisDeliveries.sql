CREATE PROCEDURE uspRKPositionReconciliationReportBasisDeliveries
	@strCommodityId NVARCHAR(100) 
	,@intContractTypeId INT --1 = Purchase, 2 = Sale 
	,@dtmFromTransactionDate DATE 
	,@dtmToTransactionDate DATE
	,@intQtyUOMId INT = NULL

AS

BEGIN

	DECLARE @strTransactionType NVARCHAR(50) = ''

	IF @intContractTypeId = 1
	BEGIN
		SET @strTransactionType = 'Purchase Basis Deliveries'
	END
	ELSE
	BEGIN
		SET @strTransactionType = 'Sales Basis Deliveries'
	END

	DECLARE @Commodity AS TABLE (
		 intCommodityId INT)
		
	
	INSERT INTO @Commodity(intCommodityId)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@strCommodityId, ',')

	DECLARE @BasisDeliveries AS TABLE (
		dtmTransactionDate  DATE  NULL
		,dblQuantity  NUMERIC(18,6)
		,dblRunningBalance  NUMERIC(18,6)
		,strTransactionId NVARCHAR(50)
		,intTransactionId INT
		,strContractSeq NVARCHAR(50)
		,intContractHeaderId INT
		,strTransactionType NVARCHAR(50)
		,intCommodityId INT
		,strCommodityCode NVARCHAR(100)
	)
	
	
	DECLARE @intCommodityId INT
		,@strCommodities NVARCHAR(MAX)
		,@strCommodityCode NVARCHAR(100)

	SELECT DISTINCT com.intCommodityId, strCommodityCode
	INTO #tempCommodity
	FROM @Commodity com
	INNER JOIN tblICCommodity iccom on iccom.intCommodityId = com.intCommodityId
	WHERE ISNULL(com.intCommodityId, '') <> ''

	--Build concatenated commodities to be used if begin balance only (no record from given date range)
	SELECT @strCommodities =  COALESCE(@strCommodities + ', ' + strCommodityCode, strCommodityCode) FROM #tempCommodity

	WHILE EXISTS(SELECT TOP 1 1 FROM #tempCommodity)
	BEGIN

		SELECT TOP 1 
			@intCommodityId = intCommodityId
			,@strCommodityCode = strCommodityCode
		FROM #tempCommodity
		
		INSERT INTO @BasisDeliveries(
			dtmTransactionDate
			,dblQuantity
			,dblRunningBalance  
			,strTransactionId
			,intTransactionId
			,strContractSeq
			,intContractHeaderId
			,strTransactionType
			,intCommodityId
			,strCommodityCode
		)
		SELECT
			dtmCreateDate
			,dblQuantity = dblQty
			,dblRunningBalance  = NULL
			,strTransactionId = strTransactionReferenceNo
			,intTransactionId = intTransactionReferenceId
			,strContractSeq = strContractNumber + '-' + CONVERT(NVARCHAR(10),intContractSeq)
			,intContractHeaderId
			,strTransactionType = strTransactionReference
			,intCommodityId
			,strCommodityCode
			
		FROM 
			dbo.fnRKGetBucketBasisDeliveries(@dtmToTransactionDate,@intCommodityId, NULL)
		WHERE intCommodityId = @intCommodityId
		AND strTransactionType  = @strTransactionType

		DELETE FROM #tempCommodity WHERE intCommodityId = @intCommodityId
	END 

	SELECT
		intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate ASC))
		,dtmTransactionDate
		,dblIncrease = CASE WHEN dblQuantity > 0 THEN dblQuantity ELSE 0 END
		,dblDecrease  = CASE WHEN dblQuantity < 0 THEN ABS(dblQuantity) ELSE 0 END
		,strTransactionId
		,intTransactionId
		,strContractSeq
		,intContractHeaderId
		,strTransactionType
		,intCommodityId
		,strCommodityCode
	INTO #tempBasisDeliveries
	FROM @BasisDeliveries
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) BETWEEN CONVERT(DATETIME, @dtmFromTransactionDate) AND CONVERT(DATETIME, @dtmToTransactionDate)
	ORDER BY dtmTransactionDate


	SELECT	intRowNum, dtmTransactionDate 
	INTO #tempDateRange
	FROM #tempBasisDeliveries AS d

	declare @tblRunningBalance as table (
		intRowNum  INT  NULL
		,dtmDate DATE
		,dblBasisDlvryBegBalance  NUMERIC(18,6)
		,dblBasisDlvryEndBalance  NUMERIC(18,6)
		,dblBasisDlvryBegBalForSummary NUMERIC(18,6)
		,dblBasisDlvryEndBalForSummary NUMERIC(18,6)
	)

	Declare @intRowNum int
			,@dtmCurDate DATE
			,@dtmPrevDate DATE
			,@dblBasisDlvryBalanceForward  NUMERIC(18,6)
			,@dblBasisDlvryBegBalForSummary NUMERIC(18,6)

	SELECT @dblBasisDlvryBalanceForward =  ISNULL(SUM(ISNULL(dblQuantity,0)),0)
	FROM @BasisDeliveries
	WHERE dtmTransactionDate < @dtmFromTransactionDate 
	
	IF NOT EXISTS (SELECT TOP 1 * FROM #tempDateRange)
	BEGIN
		GOTO BeginBalanceOnly
	END

	While (Select Count(*) From #tempDateRange) > 0
	Begin

		Select Top 1 
			@intRowNum = intRowNum 
			,@dtmCurDate = dtmTransactionDate
		From #tempDateRange

		insert into @tblRunningBalance(
			intRowNum
			,dtmDate
			,dblBasisDlvryBegBalance
			,dblBasisDlvryEndBalance
		)
		select @intRowNum
			,dtmTransactionDate
			,ISNULL(@dblBasisDlvryBalanceForward,0)
			,ISNULL(@dblBasisDlvryBalanceForward,0) + ( dblIncrease - dblDecrease)  
		from #tempBasisDeliveries 
		WHERE intRowNum = @intRowNum
	
		select 
			@dblBasisDlvryBalanceForward = dblBasisDlvryEndBalance 
		from @tblRunningBalance where intRowNum = @intRowNum
		
		IF @dtmCurDate <> @dtmPrevDate OR @dtmPrevDate IS NULL
		BEGIN
			SELECT @dblBasisDlvryBegBalForSummary =  dblBasisDlvryBegBalance
			FROM @tblRunningBalance
			WHERE dtmDate = @dtmCurDate
			
			UPDATE @tblRunningBalance 
			SET dblBasisDlvryBegBalForSummary = @dblBasisDlvryBegBalForSummary
				,dblBasisDlvryEndBalForSummary = @dblBasisDlvryBalanceForward
			WHERE dtmDate = @dtmCurDate

		END

		IF @dtmCurDate = @dtmPrevDate
		BEGIN
			UPDATE @tblRunningBalance 
			SET dblBasisDlvryEndBalForSummary = @dblBasisDlvryBalanceForward
			WHERE dtmDate = @dtmCurDate

			UPDATE @tblRunningBalance 
			SET dblBasisDlvryBegBalForSummary = @dblBasisDlvryBegBalForSummary
			WHERE dtmDate = @dtmCurDate
			AND dblBasisDlvryBegBalForSummary IS NULL
		END

		SET @dtmPrevDate = @dtmCurDate
		
		Delete #tempDateRange Where intRowNum = @intRowNum

	End

	SELECT
		BD.intRowNum
		,dtmTransactionDate
		,dblBasisDlvryBegBalance
		,dblIncrease
		,dblDecrease
		,dblBasisDlvryEndBalance
		,strTransactionType
		,strTransactionId
		,intTransactionId
		,strContractSeq
		,intContractHeaderId
		,strCommodityCode
		,dblBasisDlvryBegBalForSummary
		,dblBasisDlvryEndBalForSummary
	FROM #tempBasisDeliveries BD
	FULL JOIN @tblRunningBalance RB on RB.intRowNum = BD.intRowNum
	ORDER BY BD.dtmTransactionDate

	GOTO ExitRoutine

	BeginBalanceOnly:

	IF @dblBasisDlvryBalanceForward IS NOT NULL
	BEGIN
		SELECT
			 intRowNum = 1
			,dtmTransactionDate = NULL
			,dblBasisDlvryBegBalance = @dblBasisDlvryBalanceForward
			,dblIncrease = NULL
			,dblDecrease = NULL
			,dblBasisDlvryEndBalance = @dblBasisDlvryBalanceForward
			,strTransactionType = 'Balance Forward'
			,strTransactionId = 'Balance Forward'
			,intTransactionId = NULL
			,strContractSeq = 'Balance Forward'
			,intContractHeaderId = NULL
			,strCommodityCode = @strCommodities
			,dblBasisDlvryBegBalForSummary = @dblBasisDlvryBalanceForward
			,dblBasisDlvryEndBalForSummary = @dblBasisDlvryBalanceForward
	END


	ExitRoutine:
	DROP TABLE #tempBasisDeliveries
	DROP TABLE #tempDateRange
	DROP TABLE #tempCommodity
END