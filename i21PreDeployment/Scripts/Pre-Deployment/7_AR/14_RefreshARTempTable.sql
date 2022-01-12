PRINT '********************** BEGIN - DROP AR TEMPORARY TABLES **********************'
GO


IF(OBJECT_ID('tempdb..##ARPostInvoiceHeader') IS NOT NULL)
BEGIN
    DROP TABLE ##ARPostInvoiceHeader
END

IF(OBJECT_ID('tempdb..##ARPostInvoiceDetail') IS NOT NULL)
BEGIN
    DROP TABLE ##ARPostInvoiceDetail
END

IF(OBJECT_ID('tempdb..##ARInvoiceItemAccount') IS NOT NULL)
BEGIN
    DROP TABLE ##ARInvoiceItemAccount
END

IF(OBJECT_ID('tempdb..##ARInvalidInvoiceData') IS NOT NULL)
BEGIN
    DROP TABLE ##ARInvalidInvoiceData
END

IF(OBJECT_ID('tempdb..##ARItemsForCosting') IS NOT NULL)
BEGIN
    DROP TABLE ##ARItemsForCosting
END

IF(OBJECT_ID('tempdb..##ARItemsForInTransitCosting') IS NOT NULL)
BEGIN
    DROP TABLE ##ARItemsForInTransitCosting
END

IF(OBJECT_ID('tempdb..##ARItemsForStorageCosting') IS NOT NULL)
BEGIN
    DROP TABLE ##ARItemsForStorageCosting
END

IF(OBJECT_ID('tempdb..##ARItemsForContracts') IS NOT NULL)
BEGIN
    DROP TABLE ##ARItemsForContracts
END

IF(OBJECT_ID('tempdb..##ARInvoiceGLEntries') IS NOT NULL)
BEGIN
    DROP TABLE ##ARInvoiceGLEntries
END


PRINT ' ********************** END - DROP AR TEMPORARY TABLES  **********************'
GO