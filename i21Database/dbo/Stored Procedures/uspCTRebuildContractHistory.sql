CREATE PROCEDURE [dbo].[uspCTRebuildContractHistory]
	@intContractHeaderId	INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX),
			@intUniqueId INT,
			@intContractDetailId INT,
			@strContractNumber NVARCHAR(20),
			@dblHistorySchedQuantity NUMERIC(18,6),
			@ysnLoad BIT = 0

	DECLARE @Contract TABLE 
	(  
		intUniqueId	INT IDENTITY(1,1),
		dblHistorySchedQuantity NUMERIC(18,6),
		strContractNumber NVARCHAR(20)
	)

	DECLARE @temporary TABLE 
	(  
		intId INT IDENTITY PRIMARY KEY,
		intSequenceUsageHistoryId INT,
		dblTransactionQuantity NUMERIC(18,6),
		intContractHeaderId INT,
		intContractDetailId INT
	)

	DECLARE @history TABLE 
	(  
		intId INT IDENTITY PRIMARY KEY,
		intSequenceUsageHistoryId INT,
		dblOldValue NUMERIC(18,6),
		dblTransactionQuantity NUMERIC(18,6),
		dblNewValue NUMERIC(18,6),
		intContractDetailId INT
	)

	DECLARE @ContractDetail TABLE 
	(  
		intContractDetailId INT
	)
	----------------------------------------------------------

	IF EXISTS(SELECT TOP 1 1 FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId AND ysnLoad = 1)
	BEGIN
		SET @ysnLoad = 1
	END

	INSERT INTO @ContractDetail
	SELECT intContractDetailId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @intContractHeaderId
	ORDER BY intContractDetailId ASC

	SELECT	@intContractDetailId = MIN(intContractDetailId) FROM @ContractDetail 
	WHILE	ISNULL(@intContractDetailId,0) > 0 
	BEGIN

		--Start Rebuild Balance------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO @Contract
		SELECT *
		FROM
		(
			-- With not equal to 0 Balance
			SELECT SUM (dblTransactionQuantity) AS HistorySchedQuantity, C.strContractNumber
			FROM vyuCTSequenceUsageHistory  A
			INNER JOIN tblCTContractDetail  B ON A.intContractDetailId = B.intContractDetailId
			INNER JOIN tblCTContractHeader  C ON C.intContractHeaderId = B.intContractHeaderId
			INNER JOIN tblCTContractStatus  D ON D.intContractStatusId = B.intContractStatusId
			OUTER APPLY (SELECT TOP 1 CASE WHEN (dblOldValue - dblTransactionQuantity) < 0 AND dblNewValue = 0 
											THEN 'Unfix' 
											ELSE 'Fixed' 
										   END AS strStatus 
						FROM vyuCTSequenceUsageHistory 
						WHERE intContractDetailId = B.intContractDetailId 
						AND strFieldName = 'Balance'
						AND ysnDeleted = 0 
						ORDER BY intSequenceUsageHistoryId DESC) E
			WHERE strFieldName ='Balance'
			AND D.strContractStatus = 'Open'
			AND C.intContractHeaderId = @intContractHeaderId
			AND B.intContractDetailId = @intContractDetailId
			GROUP BY C.strContractNumber,B.intContractSeq,B.dblScheduleQty,D.strContractStatus,E.strStatus
		) tbl

		SELECT	@intUniqueId = MIN(intUniqueId) FROM @Contract

		WHILE	ISNULL(@intUniqueId,0) > 0
		BEGIN
	
			SELECT	@strContractNumber = strContractNumber, @dblHistorySchedQuantity = dblHistorySchedQuantity FROM @Contract WHERE intUniqueId = @intUniqueId

			-- INSERT TO TEMPORARY TABLE TO CALCULATE RUNNING BALANCE
			IF @ysnLoad = 1
			BEGIN
				INSERT @temporary
				SELECT -1
					,CASE WHEN intPricingTypeId = 5 THEN 0 ELSE intNoOfLoad END
					,intContractHeaderId
					,intContractDetailId
				FROM tblCTContractDetail
				WHERE intContractDetailId = @intContractDetailId
			END
			ELSE
			BEGIN
				INSERT @temporary
				SELECT -1
					,CASE WHEN intPricingTypeId = 5 THEN 0 ELSE dblQuantity END
					,intContractHeaderId
					,intContractDetailId
				FROM tblCTContractDetail
				WHERE intContractDetailId = @intContractDetailId
			END


			INSERT @temporary
			SELECT intSequenceUsageHistoryId,
			dblTransactionQuantity, 
			b.intContractHeaderId,
			a.intContractDetailId
			FROM tblCTSequenceUsageHistory a
			INNER JOIN tblCTContractHeader b ON a.intContractHeaderId = b.intContractHeaderId
			INNER JOIN tblCTContractDetail c ON a.intContractDetailId = c.intContractDetailId
			WHERE a.strFieldName = 'Balance'
			AND c.intContractStatusId = 1
			AND b.strContractNumber = @strContractNumber
			AND c.intContractDetailId = @intContractDetailId
			ORDER BY a.dtmTransactionDate ASC

			INSERT INTO @history(intSequenceUsageHistoryId, dblOldValue, dblTransactionQuantity, dblNewValue, intContractDetailId)
			SELECT a.intSequenceUsageHistoryId
			,dblOldVlaue = (a.dblTransactionQuantity - sum(b.dblTransactionQuantity)) *-1
			,a.dblTransactionQuantity
			,dblNewValue = sum(b.dblTransactionQuantity)
			,a.intContractDetailId
			FROM @temporary a
			INNER JOIN @temporary b 
			ON a.intId >= b.intId
			AND a.intContractHeaderId = b.intContractHeaderId
			AND a.intContractDetailId = b.intContractDetailId
			GROUP BY a.intId,a.intSequenceUsageHistoryId,a.dblTransactionQuantity,a.intContractHeaderId,a.intContractDetailId

			UPDATE a SET dblOldValue = b.dblOldValue, dblNewValue = b.dblNewValue, dblBalance = b.dblNewValue
			FROM tblCTSequenceUsageHistory a
			INNER JOIN @history b ON a.intSequenceUsageHistoryId = b.intSequenceUsageHistoryId
			WHERE a.intContractDetailId = @intContractDetailId

			UPDATE a SET dblBalance = dblNewValue
			FROM tblCTSequenceHistory a
			INNER JOIN @history b ON a.intSequenceUsageHistoryId = b.intSequenceUsageHistoryId
			WHERE a.intContractDetailId = @intContractDetailId

			IF @ysnLoad = 1
			BEGIN
				UPDATE a SET dblBalanceLoad = b.dblNewValue
				FROM tblCTContractDetail a
				INNER JOIN (SELECT TOP 1 * FROM @history ORDER BY intId DESC) b ON a.intContractDetailId = b.intContractDetailId
				WHERE a.intContractDetailId = @intContractDetailId
			END
			ELSE
			BEGIN
				UPDATE a SET dblBalance = b.dblNewValue
				FROM tblCTContractDetail a
				INNER JOIN (SELECT TOP 1 * FROM @history ORDER BY intId DESC) b ON a.intContractDetailId = b.intContractDetailId
				WHERE a.intContractDetailId = @intContractDetailId
			END
	
			DELETE FROM @history
			DELETE FROM @temporary
	
			SELECT @intUniqueId = MIN(intUniqueId) FROM @Contract WHERE intUniqueId > @intUniqueId
		END
		--End Rebuild Balance--------------------------------------------------------------------------------------------------------------------------------------

		DELETE FROM @Contract

		--Start Rebuild Quantity------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO @Contract
		SELECT *
		FROM
		(
			-- With not equal to 0 Scheduled Quantity
			SELECT SUM (dblTransactionQuantity) AS HistorySchedQuantity, C.strContractNumber
			FROM vyuCTSequenceUsageHistory    A
			INNER JOIN tblCTContractDetail  B ON A.intContractDetailId = B.intContractDetailId
			INNER JOIN tblCTContractHeader  C ON C.intContractHeaderId = B.intContractHeaderId
			INNER JOIN tblCTContractStatus    D ON D.intContractStatusId = B.intContractStatusId
			OUTER APPLY (SELECT TOP 1 CASE WHEN (dblOldValue - dblTransactionQuantity) < 0 AND dblNewValue = 0 
											THEN 'Unfix' 
											ELSE 'Fixed' 
										   END AS strStatus 
						FROM vyuCTSequenceUsageHistory 
						WHERE intContractDetailId = B.intContractDetailId 
						AND strFieldName = 'Scheduled Quantity'
						AND ysnDeleted = 0 
						ORDER BY intSequenceUsageHistoryId DESC) E
			WHERE strFieldName ='Scheduled Quantity'
			AND D.strContractStatus = 'Open'
			AND C.intContractHeaderId = @intContractHeaderId
			AND B.intContractDetailId = @intContractDetailId
			GROUP BY C.strContractNumber,B.intContractSeq,B.dblScheduleQty,D.strContractStatus,E.strStatus
		) tbl

		SELECT	@intUniqueId = MIN(intUniqueId) FROM @Contract

		WHILE	ISNULL(@intUniqueId,0) > 0
		BEGIN
	
			SELECT	@strContractNumber = strContractNumber, @dblHistorySchedQuantity = dblHistorySchedQuantity FROM @Contract WHERE intUniqueId = @intUniqueId

			INSERT @temporary
			SELECT intSequenceUsageHistoryId,
			dblTransactionQuantity, 
			b.intContractHeaderId,
			a.intContractDetailId
			FROM tblCTSequenceUsageHistory a
			INNER JOIN tblCTContractHeader b ON a.intContractHeaderId = b.intContractHeaderId
			INNER JOIN tblCTContractDetail c ON a.intContractDetailId = c.intContractDetailId
			WHERE a.strFieldName = 'Scheduled Quantity'
			AND c.intContractStatusId = 1
			AND b.strContractNumber = @strContractNumber
			AND c.intContractDetailId = @intContractDetailId
			ORDER BY a.dtmTransactionDate ASC

			INSERT INTO @history(intSequenceUsageHistoryId, dblOldValue, dblTransactionQuantity, dblNewValue, intContractDetailId)
			SELECT a.intSequenceUsageHistoryId
			,dblOldVlaue = (a.dblTransactionQuantity - sum(b.dblTransactionQuantity)) *-1
			,a.dblTransactionQuantity
			,dblNewValue = sum(b.dblTransactionQuantity)
			,a.intContractDetailId
			FROM @temporary a
			INNER JOIN @temporary b 
			ON a.intId >= b.intId
			AND a.intContractHeaderId = b.intContractHeaderId
			AND a.intContractDetailId = b.intContractDetailId
			GROUP BY a.intId,a.intSequenceUsageHistoryId,a.dblTransactionQuantity,a.intContractHeaderId,a.intContractDetailId

			UPDATE a SET dblOldValue = b.dblOldValue, dblNewValue = b.dblNewValue
			FROM tblCTSequenceUsageHistory a
			INNER JOIN @history b ON a.intSequenceUsageHistoryId = b.intSequenceUsageHistoryId
			WHERE a.intContractDetailId = @intContractDetailId
				
			UPDATE a SET dblScheduleQty = dblNewValue
			FROM tblCTSequenceHistory a
			INNER JOIN @history b ON a.intSequenceUsageHistoryId = b.intSequenceUsageHistoryId
			WHERE a.intContractDetailId = @intContractDetailId

			UPDATE SUH SET dblBalance = BAL.dblBalance
			FROM tblCTSequenceUsageHistory SUH
			OUTER APPLY 
			(
				SELECT TOP 1 dblBalance 
				FROM tblCTSequenceUsageHistory 
				WHERE strFieldName = 'Balance' 
				AND intContractDetailId = SUH.intContractDetailId 
				AND dtmTransactionDate < SUH.dtmTransactionDate
				ORDER BY dtmTransactionDate DESC
			) BAL
			WHERE strFieldName = 'Scheduled Quantity'
			AND strScreenName = 'Inventory Receipt'
			AND intContractDetailId = @intContractDetailId

			DELETE FROM @history
			DELETE FROM @temporary
	
			SELECT @intUniqueId = MIN(intUniqueId) FROM @Contract WHERE intUniqueId > @intUniqueId
		END
		--End Rebuild Quantity--------------------------------------------------------------------------------------------------------------------------------------
		
		SELECT @intContractDetailId = MIN(intContractDetailId) FROM @ContractDetail WHERE intContractDetailId > @intContractDetailId
	END

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH