CREATE PROCEDURE [dbo].[uspARUpdateTaxGroup]
	 @intInvoiceDetailId	INT
	,@intTaxGroupId			INT
	,@strMessage			NVARCHAR(250) = '' OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION

DECLARE  @intInvoiceId			INT
		,@intItemId				INT
		,@intCompanyLocationId	INT
		,@intEntityCustomerId	INT
		,@intShipToLocationId	INT
		,@intSiteId				INT
		,@intFreightTermId		INT
		,@intOriginalTaxGroupId	INT
		,@strOldTaxGroup		NVARCHAR(50)
		,@strNewTaxGroup		NVARCHAR(50)

SELECT
	 @intInvoiceId			= ARI.intInvoiceId
	,@intItemId				= ARID.intItemId
	,@intCompanyLocationId	= ARI.intCompanyLocationId
	,@intEntityCustomerId	= ARI.intEntityCustomerId
	,@intShipToLocationId	= ARI.intShipToLocationId
	,@intSiteId				= ARID.intSiteId
	,@intFreightTermId		= ARI.intFreightTermId
	,@strOldTaxGroup		= SMTG.strTaxGroup
FROM tblARInvoice ARI
INNER JOIN tblARInvoiceDetail ARID ON ARI.intInvoiceId = ARID.intInvoiceId
INNER JOIN tblSMTaxGroup SMTG ON ARID.intTaxGroupId = SMTG.intTaxGroupId
WHERE ARID.intInvoiceDetailId = @intInvoiceDetailId

EXEC [dbo].[uspSMGetOriginalTax] 
	 @ItemId			= @intItemId
	,@LocationId		= @intCompanyLocationId
	,@TransactionType	= 'Sale'
	,@EntityId 			= @intEntityCustomerId
	,@ShipLocationId	= @intShipToLocationId
	,@SiteId			= @intSiteId
	,@FreightTermId		= @intFreightTermId
	,@OriginalTaxGroupId= @intOriginalTaxGroupId OUTPUT

UPDATE ARID
SET 
	 intTaxGroupId			= @intTaxGroupId
	,ysnOverrideTaxGroup	= CASE WHEN @intTaxGroupId <> @intOriginalTaxGroupId THEN 1 ELSE 0 END
	,@strNewTaxGroup		= SMTG.strTaxGroup
FROM tblARInvoiceDetail ARID
INNER JOIN tblSMTaxGroup SMTG ON @intTaxGroupId = SMTG.intTaxGroupId
WHERE intInvoiceDetailId = @intInvoiceDetailId

EXEC [dbo].[uspARReComputeInvoiceTaxes] @intInvoiceId, @intInvoiceDetailId

DECLARE @AuditLogDetails NVARCHAR(MAX) = '
											{
												"change": "tblARInvoiceDetail"
												,"iconCls":"small-tree-grid"
												,"changeDescription": "Details"
												,"children": [
													{
														"change": "Tax Group"
														,"from": "' + @strOldTaxGroup + '"
														,"to": "' + @strNewTaxGroup + '"
														,"leaf": true
														,"iconCls": "small-gear"
													}
												]
											}
										'
--@UserEntityID
EXEC uspSMAuditLog
	@screenName = 'AccountsReceivable.view.Invoice',
	@entityId = 1,
	@actionType = 'Updated',
	@actionIcon = 'small-tree-modified',
	@keyValue = @intInvoiceId,
	@details = @AuditLogDetails

IF EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId AND dblTotalTax <> 0)
BEGIN
	SET @strMessage = 'New tax group should have zero computed tax.'

	ROLLBACK TRANSACTION
END
ELSE
	COMMIT TRANSACTION

RETURN 0