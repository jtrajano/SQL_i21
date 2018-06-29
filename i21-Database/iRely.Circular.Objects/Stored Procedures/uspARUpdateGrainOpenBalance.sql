CREATE PROCEDURE [dbo].[uspARUpdateGrainOpenBalance]
     @InvoiceId		INT
	,@Delete		BIT	= 0
	,@UserId		INT = NULL    
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

IF @Delete = 1
BEGIN
	EXEC dbo.uspGRReverseTicketOpenBalance 
			@strSourceType	= 'Invoice',
			@IntSourceKey	= @InvoiceId,
			@intUserId		= @UserId																			

	RETURN 1
END

DECLARE @RecordsForReversal AS TABLE(intInvoiceDetailId INT)
INSERT INTO @RecordsForReversal(intInvoiceDetailId)
SELECT Detail.intInvoiceDetailId 
FROM 
	tblARInvoiceDetail Detail
INNER JOIN
	tblARInvoice Header
		ON Detail.intInvoiceId = Header.intInvoiceId
INNER JOIN
	tblARTransactionDetail TD
		ON Detail.intInvoiceDetailId = TD.intTransactionDetailId 
		AND Detail.intInvoiceId = TD.intTransactionId 
		AND TD.strTransactionType = Header.strTransactionType
WHERE 
	Header.intInvoiceId = @InvoiceId
	AND TD.intStorageScheduleTypeId IS NOT NULL		
	AND 
		(
		Detail.intItemId <> TD.intItemId
		OR
		Detail.intStorageScheduleTypeId <> TD.intStorageScheduleTypeId
		OR
		Detail.[dblQtyShipped] < dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, Detail.intItemUOMId, TD.dblQtyShipped)
		)	

UNION ALL

SELECT TD.intTransactionDetailId 
FROM 
	tblARTransactionDetail TD
INNER JOIN
	tblARInvoice Header
		ON TD.intTransactionId = Header.intInvoiceId							
WHERE 
	TD.intTransactionId = @InvoiceId
	AND TD.strTransactionType = Header.strTransactionType
	AND TD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)

DECLARE @InvoiceReversed BIT = 0
IF EXISTS(SELECT TOP 1 NULL FROM @RecordsForReversal)
BEGIN
	EXEC dbo.uspGRReverseTicketOpenBalance 
			@strSourceType	= 'Invoice',
			@IntSourceKey	= @InvoiceId,
			@intUserId		= @UserId
			
	SET @InvoiceReversed = 1																		
END	

DECLARE @GrainItems TABLE(
	 intEntityCustomerId		INT
	,intInvoiceId				INT	
	,intInvoiceDetailId			INT
	,intItemId					INT
	,dblQuantity				NUMERIC(18,6)
	,intItemUOMId				INT
	,intLocationId				INT
	,intStorageScheduleTypeId	INT
	,intCustomerStorageId		INT)

IF @InvoiceReversed = 1
	BEGIN
		DELETE FROM @GrainItems
		INSERT INTO @GrainItems
		SELECT
			 I.intEntityCustomerId 
			,I.intInvoiceId 
			,ID.intInvoiceDetailId
			,ID.intItemId
			,dbo.fnCalculateStockUnitQty(ID.dblQtyShipped, ICIU.dblUnitQty)
			,ID.intItemUOMId
			,I.intCompanyLocationId
			,ID.intStorageScheduleTypeId
			,ID.intCustomerStorageId 
		FROM 
			(SELECT intInvoiceId, intEntityCustomerId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) I
		INNER JOIN 
			(SELECT intInvoiceId, intInvoiceDetailId, intItemId, dblQtyShipped, intItemUOMId, intStorageScheduleTypeId, intCustomerStorageId FROM tblARInvoiceDetail WITH (NOLOCK)) ID ON I.intInvoiceId = ID.intInvoiceId
		INNER JOIN
			(SELECT intItemId, intItemUOMId, dblUnitQty FROM tblICItemUOM WITH (NOLOCK)) ICIU  ON ID.intItemId = ICIU.intItemId AND ID.intItemUOMId = ICIU.intItemUOMId				 		
		WHERE 
			I.intInvoiceId = @InvoiceId
			AND ID.intStorageScheduleTypeId IS NOT NULL
			AND ID.dblQtyShipped <> @ZeroDecimal
	END
ELSE
	BEGIN
		DELETE FROM @GrainItems
		INSERT INTO @GrainItems

		--New Item
		SELECT
			 I.intEntityCustomerId 
			,I.intInvoiceId 
			,ID.intInvoiceDetailId
			,ID.intItemId
			,dbo.fnCalculateStockUnitQty(ID.[dblQtyShipped], ICIU.dblUnitQty)
			,ID.intItemUOMId
			,I.intCompanyLocationId
			,ID.intStorageScheduleTypeId
			,ID.intCustomerStorageId 
		FROM 
			(SELECT intInvoiceId, intEntityCustomerId, intCompanyLocationId, strTransactionType FROM tblARInvoice WITH (NOLOCK)) I
		INNER JOIN 
			(SELECT intInvoiceId, intInvoiceDetailId, intItemId, dblQtyShipped, intItemUOMId, intStorageScheduleTypeId, intCustomerStorageId FROM tblARInvoiceDetail WITH (NOLOCK)) ID ON I.intInvoiceId = ID.intInvoiceId		
		INNER JOIN
			(SELECT intItemId, intItemUOMId, dblUnitQty FROM tblICItemUOM WITH (NOLOCK)) ICIU  ON ID.intItemId = ICIU.intItemId AND ID.intItemUOMId = ICIU.intItemUOMId				 		
		WHERE 
			I.intInvoiceId = @InvoiceId
			AND ID.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @InvoiceId AND strTransactionType = I.strTransactionType)
			AND ID.intItemId IS NOT NULL
			AND ID.intStorageScheduleTypeId IS NOT NULL
			AND ID.[dblQtyShipped] <> @ZeroDecimal

		UNION ALL

		--QTY/UOM Changed
		SELECT
			 I.intEntityCustomerId 
			,I.intInvoiceId 
			,ID.intInvoiceDetailId
			,ID.intItemId
			,dbo.fnCalculateStockUnitQty((ID.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, ID.intItemUOMId, TD.dblQtyShipped)), ICIU.dblUnitQty)
			,ID.intItemUOMId
			,I.intCompanyLocationId
			,ID.intStorageScheduleTypeId
			,ID.intCustomerStorageId 
		FROM 
			(SELECT intInvoiceId, intEntityCustomerId, intCompanyLocationId, strTransactionType FROM tblARInvoice WITH (NOLOCK)) I
		INNER JOIN 
			(SELECT intInvoiceId, intInvoiceDetailId, intItemId, dblQtyShipped, intItemUOMId, intStorageScheduleTypeId, intCustomerStorageId FROM tblARInvoiceDetail WITH (NOLOCK)) ID ON I.intInvoiceId = ID.intInvoiceId
		INNER JOIN
		tblARTransactionDetail TD
			ON ID.intInvoiceDetailId = TD.intTransactionDetailId 
			AND ID.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = I.strTransactionType
		INNER JOIN
			(SELECT intItemId, intItemUOMId, dblUnitQty FROM tblICItemUOM WITH (NOLOCK)) ICIU  ON ID.intItemId = ICIU.intItemId AND ID.intItemUOMId = ICIU.intItemUOMId				 		
		WHERE 
			I.intInvoiceId = @InvoiceId
			AND ID.intStorageScheduleTypeId IS NOT NULL
			AND ID.intItemId = TD.intItemId
			AND ID.intStorageScheduleTypeId = TD.intStorageScheduleTypeId
			AND ID.[dblQtyShipped] > dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, ID.intItemUOMId, TD.dblQtyShipped)
	END

WHILE EXISTS(SELECT NULL FROM @GrainItems)
BEGIN
				
	DECLARE
		 @EntityCustomerId		INT
		,@InvoiceDetailId		INT
		,@ItemId				INT
		,@Quantity				NUMERIC(18,6)
		,@ItemUOMId				INT
		,@LocationId			INT
		,@StorageScheduleTypeId	INT
		,@CustomerStorageId		INT
			
	SELECT TOP 1 
		 @InvoiceDetailId		= GI.intInvoiceDetailId
		,@EntityCustomerId		= GI.intEntityCustomerId 
		,@ItemId				= GI.intItemId
		,@Quantity				= GI.dblQuantity				
		,@ItemUOMId				= GI.intItemUOMId
		,@LocationId			= GI.intLocationId
		,@StorageScheduleTypeId	= GI.intStorageScheduleTypeId
		,@CustomerStorageId		= GI.intCustomerStorageId 
	FROM @GrainItems GI

				  						
	DECLARE @GrainStorageCharge TABLE  (
		intCustomerStorageId INT,
		strStorageTicketNumber NVARCHAR(100),
		dblOpeningBalance NUMERIC(18,6),
		intUnitMeasureId INT,
		strUnitMeasure NVARCHAR(100),
		strItemType NVARCHAR(100),
		intItemId INT,
		strItem NVARCHAR(100),
		dblCharge NUMERIC(18,6),
		dblFlatFee NUMERIC(18,6)
	);
						 
	INSERT INTO @GrainStorageCharge
	(
		intCustomerStorageId, 
		strStorageTicketNumber,
		dblOpeningBalance,
		intUnitMeasureId,
		strUnitMeasure, 
		strItemType,
		intItemId,
		strItem,
		dblCharge,
		dblFlatFee 
	)
	EXEC uspGRUpdateGrainOpenBalanceByFIFO 
		 @strOptionType		= 'Update'
		,@strSourceType		= 'Invoice'
		,@intEntityId		= @EntityCustomerId
		,@intItemId			= @ItemId
		,@intStorageTypeId	= @StorageScheduleTypeId
		,@dblUnitsConsumed	= @Quantity
		,@IntSourceKey		= @InvoiceId
		,@intUserId			= @UserId
		,@intCompanyLocationId	= @LocationId																																																									

	DELETE FROM @GrainItems WHERE intInvoiceDetailId = @InvoiceDetailId
END

END

GO