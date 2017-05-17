/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ETTranslateSDToInvoiceTable] AS TABLE
(
	[strInvoiceNumber] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strCustomerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL , 
    [strSiteNumber] NVARCHAR(5) COLLATE Latin1_General_CI_AS  NULL , 
    [dtmDate] DATETIME NULL, 
    [strUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [dblUnitPrice] NUMERIC(18, 6) NULL, 
    [strItemDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS  NULL, 
    [dblPercentFullAfterDelivery] NUMERIC(18, 6) NULL, 
	[strLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [strTermCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    [strSalesAccount] NVARCHAR(40) COLLATE Latin1_General_CI_AS  NULL, 
    [strItemNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [strSalesTaxId] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [strDriverNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    [strType] NVARCHAR(10) COLLATE Latin1_General_CI_AS  NULL, 
    [dblQuantity] NUMERIC(18, 6) NULL, 
    [dblTotal] NUMERIC(18, 6) NULL, 
    [intLineItem] INT NULL, 
    [dblPrice] NUMERIC(18, 6) NULL, 
    [strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL,
	[strDetailType] NVARCHAR(2) COLLATE Latin1_General_CI_AS  NULL,
	[strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	[intContractSequence] INT NULL 
)


    