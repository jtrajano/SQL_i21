CREATE TABLE [dbo].[tblGRAPISettlementReport]
(
	intSettlementReportId				INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,guiApiUniqueId						uniqueidentifier
	,intBankAccountId					INT
	,intBillDetailId					INT
	,intTransactionId					INT		
	,strTransactionId					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strCompanyName						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strCompanyAddress					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strItemNo							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,lblGrade							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strGrade							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strCommodity						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strDate							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strTime							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strAccountNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strReferenceNo						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strEntityName						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strVendorAddress					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dtmDeliveryDate					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intTicketId						INT 
	,strTicketNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strReceiptNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intInventoryReceiptItemId			INT
	,intContractDetailId				INT
	,RecordId							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,lblSplitNumber						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strSplitNumber						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strCustomerReference				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,lblTicketComment					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strTicketComment					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strDiscountReadings				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,lblFarmField						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strFarmField						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dtmDate							DATETIME NULL
	,dblGrossWeight						DECIMAL(24,10)
	,dblTareWeight						DECIMAL(24,10)
	,dblNetWeight						DECIMAL(24,10)
	,dblDockage							DECIMAL(24,3)
	,dblCost							DECIMAL(24,10)
	,Net								DECIMAL(24,10)
	,strUnitMeasure						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dblTotal							DECIMAL(24,10)
	,dblTax								DECIMAL(24,10)
	,dblNetTotal						DECIMAL(24,10)
	,lblSourceType						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strSourceType						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,TotalDiscount						DECIMAL(24,10)
	,NetDue								DECIMAL(24,10)
	,strId								NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intPaymentId						INT
	,InboundNetWeight					DECIMAL(24,10)
	,OutboundNetWeight					DECIMAL(24,10)
	,InboundGrossDollars				DECIMAL(24,10)
	,OutboundGrossDollars				DECIMAL(24,10)
	,InboundTax							DECIMAL(24,10)
	,OutboundTax						DECIMAL(24,10)
	,InboundDiscount					DECIMAL(24,10)
	,OutboundDiscount					DECIMAL(24,10)
	,InboundNetDue						DECIMAL(24,10)
	,OutboundNetDue						DECIMAL(24,10)
	,VoucherAdjustment					DECIMAL(24,10)
	,SalesAdjustment					DECIMAL(24,10)
	,CheckAmount						DECIMAL(24,10)
	,IsAdjustment						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dblGradeFactorTax					DECIMAL(24,10)
	,lblFactorTax					    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dblVendorPrepayment				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,lblVendorPrepayment			    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dblCustomerPrepayment				DECIMAL(24,10)
	,lblCustomerPrepayment				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dblPartialPrepaymentSubTotal		DECIMAL(24,10)
	,dblPartialPrepayment				DECIMAL(24,10)
	,lblPartialPrepayment			    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,blbHeaderLogo						VARBINARY(max)
	,intEntityId						INT
	,strDeliveryDate					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strDeliverySheetNumber				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strSplitDescription				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strDSSplitNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,ysnPosted							BIT
)
