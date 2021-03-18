CREATE PROCEDURE [dbo].[uspARInterCompanyIntegrationDestination]
	 @InvoiceNumber NVARCHAR(40)
	,@BatchId	NVARCHAR(40)
	,@Post		BIT
	,@UserId	INT
	,@ReceiptNumber NVARCHAR(15) OUTPUT
AS
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @strReceiptNumber NVARCHAR(50)
	DECLARE @intInventoryReceiptId INT

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
	BEGIN 
		CREATE TABLE #tmpAddItemReceiptResult 
		(
			intSourceId INT,
			intInventoryReceiptId INT
		)
	END 

	INSERT INTO @ReceiptStagingTable (
		[strReceiptType]
		,[intEntityVendorId]
		,[intShipFromId]
		,[intLocationId]
		,[dtmDate]
		,[dblExchangeRate]
		,[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dblQty]
		,[dblCost]
		,[intSourceId]
		,[intSourceType]
		,[intTaxGroupId]
		,[intFreightTermId]
	)
	SELECT 
		[strReceiptType]		= 'Direct'
		,[intEntityVendorId]	= ARIRS.intVendorId
		,[intShipFromId]		= EMEL.intEntityLocationId
		,[intLocationId]		= SMCL.intCompanyLocationId
		,[dtmDate]				= ARIRS.dtmDate
		,[dblExchangeRate]		= ARIRS.dblExchangeRate
		,[intItemId]			= ICI.intItemId
		,[intItemLocationId]	= ICIL.intLocationId
		,[intItemUOMId]			= ICIU.intItemUOMId
		,[dblQty]				= ARIRS.dblQty
		,[dblCost]				= ARIRS.dblCost
		,[intSourceId]			= ARIRS.intInvoiceId
		,[intSourceType]		= 0
		,[intTaxGroupId]		= ISNULL([dbo].[fnGetTaxGroupIdForVendor](ARIRS.intVendorId, SMCL.intCompanyLocationId, ICI.intItemId, EMEL.intEntityLocationId, SMFT.intFreightTermId), SMTG.intTaxGroupId)
		,[intFreightTermId]		= SMFT.intFreightTermId
	FROM
		tblARInventoryReceiptStaging ARIRS
	INNER JOIN tblICItem ICI
		ON ARIRS.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = ICI.strItemNo
	INNER JOIN tblICItemUOM ICIU
		ON ICI.intItemId = ICIU.intItemId
	INNER JOIN tblSMCompanyLocation SMCL
		ON ARIRS.intCompanyLocationId = SMCL.intCompanyLocationId
	INNER JOIN tblICItemLocation ICIL
		ON ICI.intItemId = ICIL.intItemId
		AND SMCL.intCompanyLocationId = ICIL.intLocationId
	INNER JOIN tblSMFreightTerms SMFT
		ON ARIRS.strFreightTerm COLLATE SQL_Latin1_General_CP1_CS_AS = SMFT.strFreightTerm
	LEFT JOIN tblSMTaxGroup SMTG
		ON ARIRS.strTaxGroup COLLATE SQL_Latin1_General_CP1_CS_AS = SMTG.strTaxGroup
	OUTER APPLY (
		SELECT TOP 1 intEntityLocationId
		FROM tblEMEntityLocation 
		WHERE intEntityId = ARIRS.intVendorId
		AND ysnDefaultLocation = 1
	) EMEL
	WHERE ARIRS.strInvoiceNumber = @InvoiceNumber

	IF(@Post = 1)
	BEGIN
		EXEC dbo.uspICAddItemReceipt @ReceiptEntries = @ReceiptStagingTable
									,@intUserId = @UserId
	
		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId, @strReceiptNumber = strReceiptNumber
		FROM tblICInventoryReceipt 
		WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM #tmpAddItemReceiptResult)

		EXEC uspICPostInventoryReceipt 
			 @ysnPost = @Post
			,@ysnRecap = 0
			,@strTransactionId = @strReceiptNumber
			,@intEntityUserSecurityId = @UserId


		INSERT INTO tblARInventoryReceiptLog(
			 strInvoiceNumber
			,intInventoryReceiptId
			,strReceiptNumber
			,ysnDeleted
		)
		SELECT 
			 @InvoiceNumber
			,@intInventoryReceiptId
			,@strReceiptNumber
			,0
	END
	ELSE
	BEGIN
		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId, @strReceiptNumber = strReceiptNumber
		FROM tblARInventoryReceiptLog
		WHERE strInvoiceNumber = @InvoiceNumber
		ORDER BY intInventoryReceiptLogId DESC

		IF(EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE strReceiptNumber = @strReceiptNumber AND ysnPosted = 1))
		BEGIN
			EXEC uspICPostInventoryReceipt 
				 @ysnPost = @Post
				,@ysnRecap = 0
				,@strTransactionId = @strReceiptNumber
				,@intEntityUserSecurityId = @UserId
		END
		
		IF(EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE strReceiptNumber = @strReceiptNumber))
		BEGIN
			EXEC [dbo].[uspICDeleteInventoryReceipt] @InventoryReceiptId = @intInventoryReceiptId, @intEntityUserSecurityId = @UserId

			UPDATE tblARInventoryReceiptLog
			SET ysnDeleted = 1
			WHERE strInvoiceNumber = @InvoiceNumber
		END
	END

	DELETE FROM tblARInventoryReceiptStaging WHERE strInvoiceNumber = @InvoiceNumber

	SELECT @ReceiptNumber = @strReceiptNumber

RETURN 0
