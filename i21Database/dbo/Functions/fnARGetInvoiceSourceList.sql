CREATE FUNCTION [dbo].[fnARGetInvoiceSourceList]()
RETURNS @returntable TABLE
(
     [strInvoiceSource] NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN
    INSERT @returntable([strInvoiceSource])
    SELECT 'Standard'
    INSERT @returntable([strInvoiceSource])
    SELECT 'Software'
    INSERT @returntable([strInvoiceSource])
    SELECT 'Tank Delivery'
    INSERT @returntable([strInvoiceSource])
    SELECT 'Provisional'
    INSERT @returntable([strInvoiceSource])
    SELECT 'Service Charge'
    INSERT @returntable([strInvoiceSource])
    SELECT 'Transport Delivery'
    INSERT @returntable([strInvoiceSource])
    SELECT 'Store'
    INSERT @returntable([strInvoiceSource])
    SELECT 'Meter Billing'
    INSERT @returntable([strInvoiceSource])
    SELECT 'CF Tran'
    INSERT @returntable([strInvoiceSource])
    SELECT 'CF Invoice'
    INSERT @returntable([strInvoiceSource])
    SELECT 'POS'
    INSERT @returntable([strInvoiceSource])
    SELECT 'Store Checkout'
    RETURN
END


