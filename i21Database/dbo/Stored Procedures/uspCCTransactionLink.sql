CREATE PROCEDURE [dbo].[uspCCTransactionLink]
	@intTransactionId INT,
	@ForDelete BIT = 0
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF 
BEGIN
    -- START TR-1611 - Sub ledger Transaction traceability
	IF (ISNULL(@ForDelete, 0) = 0)
    BEGIN
        DECLARE @intCreateLinkTransactionId INT, 
			@strCreateLinkTransactionNo NVARCHAR(50),
			@strCreateLinkTransactionType NVARCHAR(100),
			@strCreateLinkModuleName NVARCHAR(100)

		SELECT @intCreateLinkTransactionId = SH.intSiteHeaderId
			, @strCreateLinkTransactionNo = SH.strCcdReference
			, @strCreateLinkTransactionType  = 'Dealer Credit Card'
			, @strCreateLinkModuleName = 'Credit Card Reconciliation'
		FROM tblCCSiteHeader SH
		WHERE SH.intSiteHeaderId = @intTransactionId

		EXEC dbo.uspICAddTransactionLinkOrigin @intCreateLinkTransactionId, @strCreateLinkTransactionNo, @strCreateLinkTransactionType, @strCreateLinkModuleName

        -- DECLARE @tblTransactionLinks udtICTransactionLinks
        
        -- INSERT INTO @tblTransactionLinks (
        --     strOperation
        --     , intSrcId
        --     , strSrcTransactionNo
        --     , strSrcTransactionType
        --     , strSrcModuleName
        --     , intDestId
        --     , strDestTransactionNo
        --     , strDestTransactionType
        --     , strDestModuleName
        -- )    
        -- SELECT strOperation	= 'Create'
        --     , intSrcId = SH.intSiteHeaderId
        --     , strSrcTransactionNo = SH.strCcdReference
        --     , strSrcTransactionType = 'Dealer Credit Card'
        --     , strSrcModuleName  = 'Credit Card Reconciliation'
        --     , intDestId	= SH.intSiteHeaderId
        --     , strDestTransactionNo = SH.strCcdReference
        --     , strDestTransactionType = 'Dealer Credit Card'
        --     , strDestModuleName = 'Credit Card Reconciliation'
        -- FROM tblCCSiteHeader SH
		-- WHERE SH.intSiteHeaderId = @intTransactionId

        -- EXEC dbo.uspICAddTransactionLinks @tblTransactionLinks
    END
	ELSE
	BEGIN	
		DECLARE @strTransaction NVARCHAR(100) = NULL
        SELECT @strTransaction = strCcdReference FROM tblCCSiteHeader SH WHERE SH.intSiteHeaderId = @intTransactionId
		EXEC dbo.[uspICDeleteTransactionLinks] @intTransactionId, @strTransaction, 'Dealer Credit Card', 'Credit Card Reconciliation'
	END
    -- END TR-1611
END