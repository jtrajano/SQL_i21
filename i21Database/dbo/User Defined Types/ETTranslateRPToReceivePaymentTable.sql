/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ETTranslateRPToReceivePaymentTable] AS TABLE
(
	[strInvoiceNumber] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strCustomerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL , 
    [dtmPaymentDate] DATETIME NULL, 
	[dblPaymentAmount] NUMERIC(18, 6) NULL, 
	[strDescriptionCheckNum] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
	[strRecordType] NVARCHAR(10) COLLATE Latin1_General_CI_AS  NULL, 
	[strLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
	[strPaymentType] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
	[strTermCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    [strAccount] NVARCHAR(40) COLLATE Latin1_General_CI_AS  NULL 
)


    