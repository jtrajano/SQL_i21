CREATE PROCEDURE [dbo].[uspBBPostBuyback]
	@intBuyBackId INT
	,@intUserId INT
	,@strPostingError NVARCHAR(MAX) OUTPUT
	,@strCreatedInvoices NVARCHAR(MAX) OUTPUT
AS
	--DECLARE @intBuyBackId INT
	--DECLARE @intUserId INT

	--SET @intBuyBackId = 29
	--SET @intUserId =1

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @LineItemTaxEntries LineItemTaxDetailStagingTable
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @CreatedIvoices NVARCHAR(MAX)
	DECLARE @UpdatedIvoices NVARCHAR(MAX)
	DECLARE @CompanyLocation INT
	DECLARE @ysnSuccess BIT
	SET @ysnSuccess = 0

	SET @CompanyLocation = dbo.fnGetUserDefaultLocation(@intUserId)

	INSERT INTO @EntriesForInvoice(
		[strSourceTransaction]
		,[intSourceId]
		,[strSourceId]
		,intEntityCustomerId
		,dtmDate
		,intEntityId
		,intCompanyLocationId
		,ysnPost
		,intItemId
		,[dblQtyShipped]
		,[dblPrice]
	)
	SELECT 
		[strSourceTransaction] = 'Direct'
		,[intSourceId] = A.intBuybackId
		,[strSourceId] = A.strReimbursementNo
		,intEntityCustomerId = A.intEntityId
		,dtmDate = GETDATE()
		,intEntityId = @intUserId
		,intCompanyLocationId = CASE WHEN ISNULL(@CompanyLocation,0) = 0
									THEN (SELECT TOP 1 intWarehouseId FROM vyuARCustomerSearch WHERE intEntityId = A.intEntityId) 
								ELSE @CompanyLocation END
		,ysnPost = 1
		,intItemId = B.intItemId
		,[dblQtyShipped] = 1
		,[dblPrice] = B.dblReimbursementAmount
	FROM tblBBBuybackCharge B
	INNER JOIN tblBBBuyback A
		ON A.intBuybackId = A.intBuybackId
	WHERE A.intBuybackId = @intBuyBackId

	EXEC [dbo].[uspARProcessInvoices] @InvoiceEntries = @EntriesForInvoice
		,@UserId = @intUserId
		,@GroupingOption = 1
		,@RaiseError = 1
		,@LineItemTaxEntries = @LineItemTaxEntries
		,@ErrorMessage = @ErrorMessage OUTPUT
		,@CreatedIvoices = @CreatedIvoices OUTPUT
		,@UpdatedIvoices = @UpdatedIvoices OUTPUT

	IF(ISNULL(@ErrorMessage,'') = '')
	BEGIN
		UPDATE tblBBBuyback
		SET intInvoiceId = @CreatedIvoices
			,ysnPosted = 1
			,intConcurrencyId = intConcurrencyId + 1
		WHERE intBuybackId = @intBuyBackId
		SET @ysnSuccess = 1
	END

	SET @strPostingError = ISNULL(@ErrorMessage,'')
	SET @strCreatedInvoices = ISNULL(@CreatedIvoices,'')
GO
