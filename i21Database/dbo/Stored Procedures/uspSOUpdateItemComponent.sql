﻿CREATE PROCEDURE [dbo].[uspSOUpdateItemComponent]
	 @SalesOrderId	INT
	,@Delete	BIT = 0
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
				
	IF ISNULL(@Delete,0) <> 0
		BEGIN
			DELETE SOSODC
			FROM			
				tblSOSalesOrderDetailComponent SOSODC
			INNER JOIN
				tblSOSalesOrderDetail SOSOD
					ON SOSODC.[intSalesOrderDetailId] = SOSOD.[intSalesOrderDetailId]
			INNER JOIN
				tblSOSalesOrder SO
					ON SOSOD.intSalesOrderId = SO.intSalesOrderId
					AND SO.strTransactionType = 'Order'
			INNER JOIN
				tblARTransactionDetail ARTD
					ON SOSOD.intSalesOrderDetailId = ARTD.intTransactionDetailId 
					AND SOSOD.intSalesOrderId = ARTD.intTransactionId
			INNER JOIN
				tblICItem ICI
					ON ARTD.[intItemId] = ICI.[intItemId]
			WHERE 
				SO.intSalesOrderId = @SalesOrderId
				AND SOSOD.intItemId <> ARTD.intItemId
				AND ICI.strType = 'Bundle'		
				
				
			DELETE SOSODC
			FROM			
				tblSOSalesOrderDetailComponent SOSODC
			LEFT OUTER JOIN
				tblSOSalesOrderDetail SOSOD
					ON SOSODC.[intSalesOrderDetailId] = SOSOD.[intSalesOrderDetailId]
			LEFT OUTER JOIN
				tblSOSalesOrder SO
					ON SO.[intSalesOrderId] = SOSOD.[intSalesOrderId] 
					AND SO.strTransactionType = 'Order'
			WHERE 
				ISNULL(SOSOD.[intSalesOrderDetailId],0) = 0

			RETURN
		END		
			
	--New
	INSERT INTO [tblSOSalesOrderDetailComponent]
		([intSalesOrderDetailId]
		,[intComponentItemId]
		,[strComponentType]
		,[intItemUOMId]
		,[dblQuantity]
		,[dblUnitQuantity]
		,[intConcurrencyId])
	SELECT 
		 [intSalesOrderDetailId]	= SOSOD.[intSalesOrderDetailId] 
		,[intComponentItemId]	= ARGIC.[intComponentItemId] 
		,[strComponentType]		= ARGIC.[strType] 
		,[intItemUOMId]			= ARGIC.[intItemUnitMeasureId] 
		,[dblQuantity]			= ARGIC.[dblQuantity] 
		,[dblUnitQuantity]		= ARGIC.[dblUnitQty] 
		,[intConcurrencyId]		= 1
	FROM
		tblSOSalesOrderDetail SOSOD
	INNER JOIN
		tblSOSalesOrder SO
			ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]			
	INNER JOIN
		vyuARGetItemComponents ARGIC
			ON SOSOD.[intItemId] = ARGIC.[intItemId] 
			AND SO.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN
		tblICItem ICI
			ON SOSOD.[intItemId] = ICI.[intItemId]
	WHERE 
		SO.[intSalesOrderId] = @SalesOrderId
		AND SO.[strTransactionType] = 'Order'
		AND SOSOD.[intSalesOrderDetailId] NOT IN (SELECT [intTransactionDetailId] FROM tblARTransactionDetail WHERE [intTransactionId] = @SalesOrderId)
		AND (ISNULL(ICI.[ysnListBundleSeparately],0) = 0 OR ICI.strBundleType = 'Kit')
		AND ARGIC.[strType] IN ('Bundle') -- ('Bundle', 'Finished Good')
		AND ICI.strBundleType <> 'Option'


	--New > Item Changed
	INSERT INTO [tblSOSalesOrderDetailComponent]
		([intSalesOrderDetailId]
		,[intComponentItemId]
		,[strComponentType]
		,[intItemUOMId]
		,[dblQuantity]
		,[dblUnitQuantity]
		,[intConcurrencyId])
	SELECT 
		 [intSalesOrderDetailId]	= SOSOD.[intSalesOrderDetailId] 
		,[intComponentItemId]	= ARGIC.[intComponentItemId] 
		,[strComponentType]		= ARGIC.[strType] 
		,[intItemUOMId]			= ARGIC.[intItemUnitMeasureId] 
		,[dblQuantity]			= ARGIC.[dblQuantity] 
		,[dblUnitQuantity]		= ARGIC.[dblUnitQty] 
		,[intConcurrencyId]		= 1
	FROM
		tblSOSalesOrderDetail SOSOD
	INNER JOIN
		tblSOSalesOrder SO
			ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]
	INNER JOIN
		vyuARGetItemComponents ARGIC
			ON SOSOD.[intItemId] = ARGIC.[intItemId] 
			AND SO.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN
		tblARTransactionDetail ARTD
			ON SOSOD.[intSalesOrderDetailId] = ARTD.[intTransactionDetailId] 
			AND SOSOD.[intSalesOrderId] = ARTD.[intTransactionId]
	INNER JOIN
		tblICItem ICI
			ON SOSOD.[intItemId] = ICI.[intItemId]
	WHERE 
		SO.[intSalesOrderId] = @SalesOrderId
		AND SO.[strTransactionType] = 'Order'
		AND SOSOD.[intItemId] <> ARTD.[intItemId]
		AND (ISNULL(ICI.[ysnListBundleSeparately],0) = 0 OR ICI.strBundleType = 'Kit')
		AND ARGIC.[strType] IN ('Bundle') -- ('Bundle', 'Finished Good')
		AND ICI.strBundleType <> 'Option'

END

GO