CREATE TABLE tblIPBillStage (
	intBillStageId INT identity(1, 1)
	,strVendorAccountNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strVendorName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,ysnInvoiceCredit BIT
	,strInvoiceNo NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmInvoiceDate DATETIME
	,strPaymentTerms NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmDueDate DATETIME
	,strCurrency NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,strWeightTerms NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strINCOTerms NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strRemarks NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblTotalDiscount NUMERIC(18, 6)
	,dblTotalTax NUMERIC(18, 6)
	,dblVoucherTotal NUMERIC(18, 6)
	,strLIBORrate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblFinanceChargeAmount NUMERIC(18, 6)
	,strSalesOrderReference NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblFreightCharges NUMERIC(18, 6)
	,strBLNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblMiscCharges NUMERIC(18, 6)
	,strMiscChargesDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,intStatusId INT
	,ysnMail BIT
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,intBillId int
	,strVoucherNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strFileName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intDocAttached INT
	,ysnMailReq BIT
	,CONSTRAINT [PK_tblIPBillStage] PRIMARY KEY (intBillStageId)
	)