CREATE PROCEDURE [dbo].[uspSOGetItemsFromSalesOrder]
	@SalesOrderId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT
	-- Header
	 [intSalesOrderId]				= Header.[intSalesOrderId]
	,[strSalesOrderNumber]			= Header.[strSalesOrderNumber]
	,[intEntityCustomerId]			= Header.[intEntityCustomerId]
	,[dtmDate]						= Header.[dtmDate]
	,[intCurrencyId]				= Header.[intCurrencyId]
	,[intCompanyLocationId]			= Header.[intCompanyLocationId]
	,[intQuoteTemplateId]			= Header.[intQuoteTemplateId]

	-- Detail 
	,[intSalesOrderDetailId]		= Detail.[intSalesOrderDetailId]			
	,[intItemId]					= Detail.[intItemId]					
	,[strItemDescription]			= Detail.[strItemDescription]						
	,[intItemUOMId]					= Detail.[intItemUOMId]					
	,[dblQtyOrdered]				= Detail.[dblQtyOrdered]				
	,[dblQtyAllocated]				= Detail.[dblQtyAllocated]				
	,[dblQtyShipped]				= Detail.[dblQtyShipped]				
	,[dblDiscount]					= Detail.[dblDiscount]					
	,[intTaxId]						= Detail.[intTaxId]					
	,[dblPrice]						= Detail.[dblPrice]						
	,[dblTotalTax]					= Detail.[dblTotalTax]					
	,[dblTotal]						= Detail.[dblTotal]													
	,[strComments]					= Detail.[strComments]													
	,[strMaintenanceType]           = Detail.[strMaintenanceType]           
	,[strFrequency]                 = Detail.[strFrequency]                 
	,[dtmMaintenanceDate]           = Detail.[dtmMaintenanceDate]           
	,[dblMaintenanceAmount]         = Detail.[dblMaintenanceAmount]         
	,[dblLicenseAmount]             = Detail.[dblLicenseAmount]             
	,[intContractHeaderId]			= Detail.[intContractHeaderId]			
	,[intContractDetailId]			= Detail.[intContractDetailId]			
	,[intStorageLocationId]			= Detail.[intStorageLocationId]					
FROM
	tblSOSalesOrder Header
INNER JOIN
	tblSOSalesOrderDetail Detail	
		ON Header.[intSalesOrderId] = Detail.[intSalesOrderId]
WHERE
	Header.[intSalesOrderId] = @SalesOrderId