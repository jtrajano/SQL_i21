CREATE PROCEDURE [dbo].[uspCTItemContractUpdateRemainingDollarValue]
	@intItemContractHeaderId INT
	, @dblValueToUpdate        NUMERIC(18, 6)
	, @intUserId               INT
	, @intTransactionDetailId  INT
	, @strScreenName           NVARCHAR(50)
	, @strRowState             NVARCHAR(50)
	, @intInvoiceId            INT

AS

BEGIN TRY

    DECLARE @strItemContractNumber NVARCHAR(50)
		, @dblDollarValue NUMERIC(18, 6)
		, @dblAppliedDollarValue NUMERIC(18, 6)
		, @dblRemainingDollarValue NUMERIC(18, 6)
		, @dblNewRemainingDollarValue NUMERIC(18, 6)
		, @dblNewAppliedDollarValue NUMERIC(18, 6)
		, @strContractCategoryId NVARCHAR(50)
		, @ErrMsg NVARCHAR(MAX)

    IF NOT EXISTS (SELECT * FROM tblCTItemContractHeader WHERE intItemContractHeaderId = @intItemContractHeaderId)
	BEGIN
		SET @ErrMsg = 'Item contract is deleted by other user.'
		RAISERROR(@ErrMsg, 16, 1)
	END
	
	BEGINING:

    IF (UPPER(@strRowState) = 'DELETE')
	BEGIN
        SELECT @strItemContractNumber = H.strContractNumber
			, @dblDollarValue = ISNULL(H.dblDollarValue, 0)
			, @dblAppliedDollarValue = SUM(ISNULL(pp.dblAppliedInvoiceDetailAmount, 0))
			, @dblRemainingDollarValue = ISNULL(H.dblRemainingDollarValue, 0)
			, @strContractCategoryId = H.strContractCategoryId
        FROM tblCTItemContractHeader H
		LEFT JOIN tblARInvoiceDetail ID ON ID.intItemContractHeaderId = H.intItemContractHeaderId
			AND ID.intInvoiceId <> @intInvoiceId
		LEFT JOIN tblARPrepaidAndCredit pp ON pp.intPrepaymentId = ID.intInvoiceId
        WHERE H.intItemContractHeaderId = @intItemContractHeaderId
        GROUP BY H.strContractNumber
			, H.dblDollarValue
			, H.dblRemainingDollarValue
			, H.strContractCategoryId
    END
    ELSE
    BEGIN
        SELECT @strItemContractNumber = H.strContractNumber
			, @dblDollarValue = ISNULL(H.dblDollarValue, 0)
			, @dblAppliedDollarValue = SUM(ISNULL(pp.dblAppliedInvoiceDetailAmount, 0))
			, @dblRemainingDollarValue = ISNULL(H.dblRemainingDollarValue, 0)
			, @strContractCategoryId = H.strContractCategoryId
		FROM tblCTItemContractHeader H
		LEFT JOIN tblARInvoiceDetail ID ON ID.intItemContractHeaderId = H.intItemContractHeaderId
		LEFT JOIN tblARPrepaidAndCredit pp ON pp.intPrepaymentId = ID.intInvoiceId
		WHERE H.intItemContractHeaderId = @intItemContractHeaderId
		GROUP BY H.strContractNumber
			, H.dblDollarValue
			, H.dblRemainingDollarValue
			, H.strContractCategoryId
    END
	
	IF(@strContractCategoryId <> 'Dollar')
	BEGIN
		GOTO DontUpdateNonDollarContract
	END
	
	SET @dblNewRemainingDollarValue = @dblDollarValue - @dblAppliedDollarValue
	SET @dblNewAppliedDollarValue = @dblDollarValue - @dblNewRemainingDollarValue
	
	-- VALIDATION #1
    IF(@dblNewRemainingDollarValue < 0)
	BEGIN
		SET @ErrMsg = 'Available amount for the item contract ' + @strItemContractNumber + ' is ' + CONVERT(NVARCHAR(50), @dblRemainingDollarValue) + ', which is insufficient for this transaction.'
		RAISERROR(@ErrMsg, 16, 1)
	END
	
	-- VALIDATION #2
    IF(@dblNewRemainingDollarValue > @dblDollarValue)
	BEGIN
		SET @ErrMsg = 'Unable to return ' + CONVERT(NVARCHAR(50), @dblValueToUpdate) + ' amount to item contract ' + @strItemContractNumber + ' because this will exceed to its total value of ' + CONVERT(NVARCHAR(50), @dblDollarValue) + '.'
		RAISERROR(@ErrMsg, 16, 1)
	END
	
	-- UPDATE ITEM CONTRACT
    UPDATE tblCTItemContractHeader
	SET dblRemainingDollarValue = ISNULL(@dblNewRemainingDollarValue, 0)
		, dblAppliedDollarValue = ISNULL(@dblNewAppliedDollarValue, 0)
		, intConcurrencyId = intConcurrencyId + 1
	WHERE intItemContractHeaderId = @intItemContractHeaderId
	
	DontUpdateNonDollarContract:
END TRY
BEGIN CATCH
    SET @ErrMsg = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT');
END CATCH