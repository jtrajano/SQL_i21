﻿CREATE PROCEDURE [dbo].[uspGRSettlementReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
SET QUOTED_IDENTIFIER ON

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL


DECLARE @intBankAccountId AS INT
	,@strTransactionId AS NVARCHAR(MAX)
	,@strModule AS NVARCHAR(40)
	,@intPaymentKey INT
	,@strPaymentNo AS NVARCHAR(40)

DECLARE @xmlDocumentId AS INT
DECLARE @companyLogo varbinary(max)

DECLARE		@strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500),
			@strPhone				NVARCHAR(500)

			SELECT	
			 @strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END
			,@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = ''     THEN NULL ELSE LTRIM(RTRIM(strAddress))		END
			,@strCounty		    =	CASE WHEN LTRIM(RTRIM(strCounty)) = ''      THEN NULL ELSE LTRIM(RTRIM(strCounty))		END
			,@strCity		    =	CASE WHEN LTRIM(RTRIM(strCity)) = ''        THEN NULL ELSE LTRIM(RTRIM(strCity))		END
			,@strState		    =	CASE WHEN LTRIM(RTRIM(strState)) = ''       THEN NULL ELSE LTRIM(RTRIM(strState))		END
			,@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = ''         THEN NULL ELSE LTRIM(RTRIM(strZip))			END
			,@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = ''     THEN NULL ELSE LTRIM(RTRIM(strCountry))		END
			,@strPhone		    =   CASE WHEN LTRIM(RTRIM(strPhone)) = ''       THEN NULL ELSE LTRIM(RTRIM(strPhone))		END 
			FROM tblSMCompanySetup

DECLARE @temp_xml_table TABLE 
(
	[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)
	,[from] NVARCHAR(MAX)
	,[to] NVARCHAR(MAX)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
)
	
	DECLARE @Settlement AS TABLE 
	(
	   intBankAccountId					INT
	  ,intBillDetailId					INT
	  ,intTransactionId					INT		
	  ,strTransactionId					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strCompanyName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strCompanyAddress				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strItemNo						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,lblGrade							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strGrade							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strCommodity						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strDate							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strTime							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strAccountNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strReferenceNo					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strEntityName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strVendorAddress					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,dtmDeliveryDate					DATETIME NULL
	  ,intTicketId						INT 
	  ,strTicketNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strReceiptNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,intInventoryReceiptItemId		INT
	  ,intContractDetailId				INT
	  ,RecordId							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,lblSplitNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strSplitNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strCustomerReference				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,lblTicketComment					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strTicketComment					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strDiscountReadings				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,lblFarmField						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strFarmField						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,dtmDate							DATETIME NULL
	  ,dblGrossWeight					DECIMAL(24,10)
	  ,dblTareWeight					DECIMAL(24,10)
	  ,dblNetWeight						DECIMAL(24,10)
	  ,dblDockage						DECIMAL(24,3)
	  ,dblCost							DECIMAL(24,10)
	  ,Net								DECIMAL(24,10)
	  ,strUnitMeasure                   NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,dblTotal							DECIMAL(24,10)
	  ,dblTax							DECIMAL(24,10)
	  ,dblNetTotal						DECIMAL(24,10)
	  ,lblSourceType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,strSourceType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,TotalDiscount					DECIMAL(24,10)
	  ,NetDue							DECIMAL(24,10)
	  ,strId							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,intPaymentId						INT
	  ,InboundNetWeight					DECIMAL(24,10)
	  ,OutboundNetWeight				DECIMAL(24,10)
	  ,InboundGrossDollars				DECIMAL(24,10)
	  ,OutboundGrossDollars				DECIMAL(24,10)
	  ,InboundTax						DECIMAL(24,10)
	  ,OutboundTax						DECIMAL(24,10)
	  ,InboundDiscount					DECIMAL(24,10)
	  ,OutboundDiscount					DECIMAL(24,10)
	  ,InboundNetDue					DECIMAL(24,10)
	  ,OutboundNetDue					DECIMAL(24,10)
	  ,VoucherAdjustment				DECIMAL(24,10)
	  ,SalesAdjustment					DECIMAL(24,10)
	  ,CheckAmount						DECIMAL(24,10)
	  ,IsAdjustment						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,dblGradeFactorTax			    DECIMAL(24,10)
	  ,lblFactorTax					    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,dblVendorPrepayment				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,lblVendorPrepayment			    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,dblCustomerPrepayment			DECIMAL(24,10)
	  ,lblCustomerPrepayment		    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,dblPartialPrepaymentSubTotal		DECIMAL(24,10)
	  ,dblPartialPrepayment				DECIMAL(24,10)
	  ,lblPartialPrepayment			    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	  ,blbHeaderLogo				    VARBINARY(max)
	  ,strDeliveryDate					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	)
	
	DECLARE @tblPayment AS TABLE 
	(
		 intPaymentKey INT IDENTITY(1, 1)		
		,strPaymentNo NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	)

EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

  SELECT
  @companyLogo = blbFile
  FROM tblSMUpload
  WHERE intAttachmentId = 
  (
	  SELECT TOP 1
	  intAttachmentId
	  FROM tblSMAttachment
	  WHERE strScreen = 'SystemManager.CompanyPreference'
	  AND strComment = 'Header'
	  ORDER BY intAttachmentId DESC
  )

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH 
(
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
)


SELECT @intBankAccountId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intBankAccountId'

SELECT @strTransactionId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strTransactionId'

SELECT @strModule = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strModule'


SET @strTransactionId = CASE 
							 WHEN LTRIM(RTRIM(ISNULL(@strTransactionId, ''))) = '' THEN NULL
							 ELSE @strTransactionId
						END

SET @strModule = CASE 
					   WHEN LTRIM(RTRIM(ISNULL(@strModule, ''))) = '' THEN NULL
					   ELSE @strModule
				 END

-- Report Query:
  
INSERT INTO @tblPayment(strPaymentNo)
SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionId)

IF @strModule = 'Cash Management'
BEGIN
	--------------------------------------------------------
	-- FROM INVENTORY RECEIPT
	--------------------------------------------------------
	INSERT INTO @Settlement
	(
	   intBankAccountId					
	  ,intBillDetailId					
	  ,intTransactionId							
	  ,strTransactionId					
	  ,strCompanyName					
	  ,strCompanyAddress				
	  ,strItemNo						
	  ,lblGrade							
	  ,strGrade							
	  ,strCommodity						
	  ,strDate							
	  ,strTime							
	  ,strAccountNumber					
	  ,strReferenceNo					
	  ,strEntityName					
	  ,strVendorAddress					
	  ,dtmDeliveryDate					
	  ,intTicketId						 
	  ,strTicketNumber					
	  ,strReceiptNumber					
	  ,intInventoryReceiptItemId		
	  ,intContractDetailId				
	  ,RecordId							
	  ,lblSplitNumber					
	  ,strSplitNumber					
	  ,strCustomerReference				
	  ,lblTicketComment					
	  ,strTicketComment					
	  ,strDiscountReadings				
	  ,lblFarmField						
	  ,strFarmField						
	  ,dtmDate							
	  ,dblGrossWeight					
	  ,dblTareWeight					
	  ,dblNetWeight						
	  ,dblDockage						
	  ,dblCost							
	  ,Net								
	  ,strUnitMeasure                   
	  ,dblTotal							
	  ,dblTax							
	  ,dblNetTotal						
	  ,lblSourceType					
	  ,strSourceType					
	  ,TotalDiscount					
	  ,NetDue							
	  ,strId							
	  ,intPaymentId						
	  ,InboundNetWeight					
	  ,OutboundNetWeight				
	  ,InboundGrossDollars				
	  ,OutboundGrossDollars				
	  ,InboundTax						
	  ,OutboundTax						
	  ,InboundDiscount					
	  ,OutboundDiscount					
	  ,InboundNetDue					
	  ,OutboundNetDue					
	  ,VoucherAdjustment				
	  ,SalesAdjustment					
	  ,CheckAmount						
	  ,IsAdjustment						
	  ,dblGradeFactorTax			    
	  ,lblFactorTax					    
	  ,dblVendorPrepayment				
	  ,lblVendorPrepayment			    
	  ,dblCustomerPrepayment			
	  ,lblCustomerPrepayment		    
	  ,dblPartialPrepaymentSubTotal		
	  ,dblPartialPrepayment				
	  ,lblPartialPrepayment			    
	  ,blbHeaderLogo
	  ,strDeliveryDate
	)
	SELECT DISTINCT
		 intBankAccountId					= BNKTRN.intBankAccountId
		,intBillDetailId					= BillDtl.intBillDetailId
		,intTransactionId					= BNKTRN.intTransactionId
		,strTransactionId					= BNKTRN.strTransactionId
		,strCompanyName						= @strCompanyName
		,strCompanyAddress					= ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')+ CHAR(13)+ CHAR(10) + ISNULL(''+@strPhone,'') 
		,strItemNo							= Item.strItemNo
		,lblGrade							= CASE WHEN SC.intCommodityAttributeId >0 THEN 'Grade'				    ELSE NULL END
		,strGrade							= CASE WHEN SC.intCommodityAttributeId >0 THEN Attribute.strDescription ELSE NULL END
		,strCommodity						= Commodity.strCommodityCode
		,strDate							= CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime							= CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber					= dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo						= BNKTRN.strReferenceNo
		,strEntityName						= ENTITY.strName
		,strVendorAddress					= dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)		
		,dtmDeliveryDate					= SC.dtmTicketDateTime 
		,intTicketId						= SC.intTicketId		
		,strTicketNumber					= SC.strTicketNumber 
		,strReceiptNumber					= SC.strElevatorReceiptNumber
		,intInventoryReceiptItemId			= ISNULL(INVRCPTITEM.intInventoryReceiptItemId, 0) 
		,intContractDetailId				= ISNULL(BillDtl.intContractDetailId, 0) 
		,RecordId							= Bill.strBillId		
        ,lblSplitNumber						= CASE WHEN EM.strSplitNumber IS NOT NULL THEN 'Split' ELSE NULL END
		,strSplitNumber						= EM.strSplitNumber
		,strCustomerReference				= SC.strCustomerReference
		,lblTicketComment					= CASE WHEN ISNULL(SC.strTicketComment,'')<>'' THEN 'Comments' ELSE NULL END 
		,strTicketComment					= SC.strTicketComment
		,strDiscountReadings				= [dbo].[fnGRGetDiscountCodeReadings](SC.intTicketId,'Scale')
		,lblFarmField						= CASE WHEN EntityFarm.strFarmNumber IS NOT NULL THEN 'Farm \ Field' ELSE NULL END 
		,strFarmField						= EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber 
		,dtmDate							= Bill.dtmDate
		-- ,dblGrossWeight                     = ISNULL(SC.dblGrossWeight, 0)         
        -- ,dblTareWeight                      = ISNULL(SC.dblTareWeight, 0)         
        -- ,dblNetWeight                       = ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		,dblGrossWeight						= CASE 
												WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
													THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,INVRCPTITEM.dblGross)													
												ELSE
													ISNULL(SC.dblGrossWeight, 0)
											END
		,dblTareWeight						= ISNULL(SC.dblTareWeight, 0)						  								 
		,dblNetWeight						= CASE 
												WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
													THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,INVRCPTITEM.dblGross)
												ELSE
													ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
											END
		,dblDockage							= ROUND(SC.dblShrink,3)		 
		,dblCost							= BillDtl.dblCost
		,Net								= CASE WHEN ISNULL(BillDtl.intUnitOfMeasureId,0) >0 AND ISNULL(BillDtl.intCostUOMId,0) >0   THEN dbo.fnCTConvertQtyToTargetItemUOM(BillDtl.intUnitOfMeasureId,BillDtl.intCostUOMId,BillDtl.dblQtyOrdered) ELSE BillDtl.dblQtyOrdered END
		,strUnitMeasure						= ISNULL(CostUOM.strSymbol,UOM.strSymbol)
		,dblTotal							= BillDtl.dblTotal
		,dblTax								= BillDtl.dblTax
		,dblNetTotal						= BillDtl.dblTotal+ BillDtl.dblTax
		,lblSourceType						= CASE 
													 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN 'Dist Type'
											      ELSE 'Contract'
											  END							  								 
		,strSourceType						= CASE 
													 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN
														 CASE 
															WHEN INVRCPT.intSourceType = 4 THEN 'Settle Storage'
															WHEN INVRCPT.intSourceType = 3 THEN 'Transport'
															WHEN INVRCPT.intSourceType = 2 THEN 'Inboud Shipment'
															WHEN INVRCPT.intSourceType = 1 THEN SD.strDistributionType --'Scale'
															ELSE 'None'
														END
											      ELSE CNTRCT.strContractNumber
											  END
		,TotalDiscount					   = ISNULL(BillByReceipt.dblTotal, 0) 
		,NetDue							   = BillDtl.dblTotal + BillDtl.dblTax + ISNULL(BillByReceipt.dblTotal, 0)
		,strId							   = Bill.strBillId
		,intPaymentId					   = PYMT.intPaymentId
		,InboundNetWeight				   = CASE 
												   WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
												   ELSE BillDtl.dblQtyOrdered
											 END 
		,OutboundNetWeight				   = 0 
		,InboundGrossDollars			   = CASE 
										   		  WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
										   		  ELSE BillDtl.dblTotal
										     END 
		,OutboundGrossDollars			   = 0
		,InboundTax						   = CASE 
										   			WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
										   			ELSE BillDtl.dblTax
										     END 
		,OutboundTax					   = 0
		,InboundDiscount				   =  ISNULL(BillByReceipt.dblTotal, 0)
		,OutboundDiscount				   = 0 
		,InboundNetDue					   = CASE 
													WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
													ELSE BillDtl.dblTotal + BillDtl.dblTax + ISNULL(BillByReceipt.dblTotal, 0)
											 END 
		,OutboundNetDue					   = 0 
		,VoucherAdjustment				   =  ISNULL(BillByReceiptItem.dblTotal,0)
		,SalesAdjustment				   = Invoice.dblPayment 
		,CheckAmount					   = PYMT.dblAmountPaid 
		,IsAdjustment					   = CASE 
												  WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 'True'
												  ELSE 'False'
											 END
       
	   ,dblGradeFactorTax				   = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0    THEN ScaleDiscountTax.dblGradeFactorTax		            ELSE NULL END 
	   ,lblFactorTax					   = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0    THEN 'Factor Tax'							            ELSE NULL END
	   ,dblVendorPrepayment				   = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0  THEN VendorPrepayment.dblVendorPrepayment	            ELSE NULL END 
	   ,lblVendorPrepayment				   = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0  THEN 'Vendor Prepay'									ELSE NULL END
	   ,dblCustomerPrepayment			   = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					THEN Invoice.dblPayment									ELSE NULL END 
	   ,lblCustomerPrepayment			   = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					THEN 'Customer Prepay'									ELSE NULL END
	   ,dblPartialPrepaymentSubTotal	   = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0				THEN PartialPayment.dblTotals						    ELSE NULL END
	   ,dblPartialPrepayment			   = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0				THEN PartialPayment.dblPayment-PartialPayment.dblTotals ELSE NULL END 
	   ,lblPartialPrepayment			   = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0				THEN 'Partial Payment Adj'								ELSE NULL END						 
	   ,blbHeaderLogo					   = @companyLogo
	   ,strDeliveryDate				 = CONVERT(VARCHAR(10), SC.dtmTicketDateTime, 110)
	FROM tblCMBankTransaction BNKTRN
	JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON BNKTRN.strTransactionId = PRINTSPOOL.strTransactionId
		AND BNKTRN.intBankAccountId = PRINTSPOOL.intBankAccountId
	JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
	JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
	JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
	JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
	LEFT JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1	
	LEFT JOIN tblICItemUOM CostItemUOM ON BillDtl.intCostUOMId = CostItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostItemUOM.intUnitMeasureId = CostUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblSCTicket SC ON SC.intTicketId = INVRCPTITEM.intSourceId
	LEFT JOIN tblGRCustomerStorage CS ON CS.intTicketId = SC.intTicketId
	LEFT JOIN tblEMEntitySplit EM ON EM.intSplitId = SC.intSplitId AND SC.intSplitId <> 0
	LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)
	LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
	LEFT JOIN vyuSCGetScaleDistribution SD ON INVRCPTITEM.intInventoryReceiptItemId = SD.intInventoryReceiptItemId
	LEFT JOIN (
				SELECT intBillDetailId,SUM(dblAmount) dblTotal 
				FROM vyuGRSettlementSubReport 
				GROUP BY intBillDetailId
			  )BillByReceipt ON BillByReceipt.intBillDetailId=BillDtl.intBillDetailId
	
	LEFT JOIN (
				SELECT intBillId,SUM(dblTotal) dblTotal
				FROM tblAPBillDetail
				WHERE intInventoryReceiptChargeId IS NOT NULL AND intInventoryReceiptItemId IS NULL
				GROUP BY intBillId
			   )BillByReceiptItem ON BillByReceiptItem.intBillId=BillDtl.intBillId  
	
	LEFT JOIN (
				SELECT
				PYMT.intPaymentId
				,SUM(BillDtl.dblTax) AS dblGradeFactorTax	
				 FROM tblAPPayment PYMT
				 JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
				 JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = PYMTDTL.intBillId
				 JOIN tblICItem B ON B.intItemId = BillDtl.intItemId AND B.strType = 'Other Charge'
				 WHERE BillDtl.intInventoryReceiptChargeId IS NOT NULL 	 
				GROUP BY  PYMT.intPaymentId
				)ScaleDiscountTax ON ScaleDiscountTax.intPaymentId=PYMT.intPaymentId
	 
	 LEFT JOIN (
				 SELECT
				 intBillId
				,SUM(dblAmountApplied* -1) AS dblVendorPrepayment 
				 FROM tblAPAppliedPrepaidAndDebit WHERE ysnApplied=1
				 GROUP BY intBillId
				) VendorPrepayment ON VendorPrepayment.intBillId = Bill.intBillId

     LEFT JOIN (  SELECT 
				  intPaymentId
				 ,SUM(dblPayment) dblPayment 
				  FROM tblAPPaymentDetail
				  WHERE intInvoiceId IS NOT NULL
				  GROUP BY intPaymentId
			    ) Invoice ON Invoice.intPaymentId=PYMT.intPaymentId
    
	LEFT JOIN (  SELECT 
				  intPaymentId
				 ,SUM(dblTotal) dblTotals
				 ,SUM(dblPayment) dblPayment 
				  FROM tblAPPaymentDetail
				  WHERE intBillId IS NOT NULL
				  GROUP BY intPaymentId
			    ) PartialPayment ON PartialPayment.intPaymentId=PYMT.intPaymentId

	WHERE BNKTRN.intBankAccountId = @intBankAccountId
		AND (
			intInventoryReceiptChargeId IS NOT NULL
			OR BillDtl.intInventoryReceiptItemId IS NOT NULL
			)	
	--------------------------------------------------------
	-- SCALE --> Storage --> Settle Storage
	--------------------------------------------------------
	
	UNION ALL
	
	SELECT DISTINCT 
		 intBankAccountId					= BNKTRN.intBankAccountId
		,intBillDetailId					= BillDtl.intBillDetailId
		,intTransactionId					= BNKTRN.intTransactionId
		,strTransactionId					= BNKTRN.strTransactionId
		,strCompanyName						= @strCompanyName
		,strCompanyAddress					= ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')+ CHAR(13)+ CHAR(10) + ISNULL(''+@strPhone,'') 
		,strItemNo							= Item.strItemNo
		,lblGrade							= CASE WHEN SC.intCommodityAttributeId >0 THEN 'Grade'					ELSE NULL END
		,strGrade							= CASE WHEN SC.intCommodityAttributeId >0 THEN Attribute.strDescription ELSE NULL END
		,strCommodity						= Commodity.strCommodityCode
		,strDate							= CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime							= CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber				    = dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo					    = BNKTRN.strReferenceNo
		,strEntityName					    = ENTITY.strName
		,strVendorAddress				    = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)
		,dtmDeliveryDate					= SC.dtmTicketDateTime
		,intTicketId						= SC.intTicketId
		,strTicketNumber					= SC.strTicketNumber
		,strReceiptNumber					= SC.strElevatorReceiptNumber 
		,intInventoryReceiptItemId			= 0
		,intContractDetailId				= ISNULL(BillDtl.intContractDetailId, 0) 
		,RecordId							= Bill.strBillId
        ,lblSplitNumber						= NULL						 
		,strSplitNumber						= NULL 
		,strCustomerReference				= SC.strCustomerReference
		,lblTicketComment					= CASE WHEN ISNULL(SC.strTicketComment,'')<>'' THEN 'Comments' ELSE NULL END
		,strTicketComment					= SC.strTicketComment
		,strDiscountReadings				= [dbo].[fnGRGetDiscountCodeReadings](CS.intCustomerStorageId,'Storage')
		,lblFarmField						= CASE WHEN EntityFarm.strFarmNumber IS NOT NULL THEN 'Farm \ Field' ELSE NULL END 
		,strFarmField						= EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber
		,dtmDate							= Bill.dtmDate		
		,dblGrossWeight						= ISNULL(SC.dblGrossWeight, 0)		
		,dblTareWeight						= ISNULL(SC.dblTareWeight, 0)		
		,dblNetWeight						= ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		-- ,dblGrossWeight						= CASE 
		-- 										WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
		-- 											THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,StrgHstry.dblUnits)													
		-- 										ELSE
		-- 											ISNULL(SC.dblGrossWeight, 0)
		-- 									END
		-- ,dblTareWeight						= ISNULL(SC.dblTareWeight, 0)						  								 
		-- ,dblNetWeight						= CASE 
		-- 										WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
		-- 											THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,StrgHstry.dblUnits)
		-- 										ELSE
		-- 											ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		-- 									END
		,dblDockage							= [dbo].[fnRemoveTrailingZeroes](ROUND(SC.dblShrink,3))
		,dblCost							= BillDtl.dblCost
		,Net								= CASE WHEN ISNULL(BillDtl.intUnitOfMeasureId,0) >0 AND ISNULL(BillDtl.intCostUOMId,0) >0   THEN dbo.fnCTConvertQtyToTargetItemUOM(BillDtl.intUnitOfMeasureId,BillDtl.intCostUOMId,BillDtl.dblQtyOrdered) ELSE BillDtl.dblQtyOrdered END
		,strUnitMeasure						= ISNULL(CostUOM.strSymbol,UOM.strSymbol)
		,dblTotal							= BillDtl.dblTotal
		,dblTax								= BillDtl.dblTax
		,dblNetTotal						= BillDtl.dblTotal + BillDtl.dblTax
		,lblSourceType						= CASE 
													 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN 'Dist Type'
											      ELSE 'Contract'
											  END
        ,strSourceType						= CASE 
													 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN
														 CASE 
															WHEN StrgHstry.intTransactionTypeId = 4 THEN 'Settle Storage'
															WHEN StrgHstry.intTransactionTypeId = 3 THEN 'Transport'
															WHEN StrgHstry.intTransactionTypeId = 2 THEN 'Inboud Shipment'
															WHEN StrgHstry.intTransactionTypeId = 1 THEN SD.strDistributionType --'Scale'
															ELSE 'None'
														END
											      ELSE CNTRCT.strContractNumber
											  END
		,TotalDiscount					    =  ISNULL(tblOtherCharge.dblTotal, 0) *(BillDtl.dblQtyOrdered /tblInventory.dblTotalQty)
		,NetDue								= BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0) 
		,strId								= Bill.strBillId 
		,intPaymentId						= PYMT.intPaymentId
		,InboundNetWeight					= BillDtl.dblQtyOrdered
		,OutboundNetWeight					= 0 
		,InboundGrossDollars				= BillDtl.dblTotal 
		,OutboundGrossDollars				= 0 
		,InboundTax							= BillDtl.dblTax 
		,OutboundTax						= 0 
		,InboundDiscount					= ISNULL(tblOtherCharge.dblTotal, 0) 
		,OutboundDiscount					= 0 
		,InboundNetDue						= BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0)  
		,OutboundNetDue						= 0 
		,VoucherAdjustment					= ISNULL(tblAdjustment.dblTotal, 0)
		,SalesAdjustment					= Invoice.dblPayment 
		,CheckAmount						= PYMT.dblAmountPaid
		,IsAdjustment						= CASE 
													WHEN Item.strType <> 'Inventory' THEN 'True' 
													ELSE 'False'
											  END 
       
	   ,dblGradeFactorTax					= CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0   THEN  ScaleDiscountTax.dblGradeFactorTax				 ELSE NULL END 
	   ,lblFactorTax						= CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0   THEN 'Factor Tax'										 ELSE NULL END
	   ,dblVendorPrepayment					= CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN  VendorPrepayment.dblVendorPrepayment				 ELSE NULL END 
	   ,lblVendorPrepayment					= CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay'									 ELSE NULL END
	   ,dblCustomerPrepayment				= CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					THEN  Invoice.dblPayment								 ELSE NULL END 
	   ,lblCustomerPrepayment				= CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					THEN 'Customer Prepay'									 ELSE NULL END
	   ,dblPartialPrepaymentSubTotal		= CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			THEN  PartialPayment.dblTotals							 ELSE NULL END
	   ,dblPartialPrepayment				= CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			THEN  PartialPayment.dblPayment-PartialPayment.dblTotals ELSE NULL END 
	   ,lblPartialPrepayment				= CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			THEN 'Partial Payment Adj'								 ELSE NULL END
	   ,blbHeaderLogo						= @companyLogo
	   ,strDeliveryDate				 = CONVERT(VARCHAR(10), SC.dtmTicketDateTime, 110)
	FROM tblCMBankTransaction BNKTRN
	JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON BNKTRN.strTransactionId = PRINTSPOOL.strTransactionId AND BNKTRN.intBankAccountId = PRINTSPOOL.intBankAccountId
	JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
	JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
	JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
	JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge'
	JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
	JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=StrgHstry.intCustomerStorageId
	JOIN tblSCTicket SC ON SC.intTicketId = CS.intTicketId
	LEFT JOIN vyuSCGetScaleDistribution SD ON CS.intCustomerStorageId = SD.intCustomerStorageId
	LEFT JOIN (
			SELECT A.intBillId,SUM(dblTotal) dblTotal
			FROM tblAPBillDetail A
			JOIN tblICItem B ON A.intItemId = B.intItemId AND B.strType = 'Other Charge'
			GROUP BY A.intBillId
		  ) tblOtherCharge ON tblOtherCharge.intBillId = Bill.intBillId
    
	JOIN (
			SELECT A.intBillId,SUM(dblTax) dblTax
			FROM tblAPBillDetail A		  
			GROUP BY A.intBillId
		  ) tblTax ON tblTax.intBillId = Bill.intBillId
    
	LEFT JOIN (
				SELECT A.intBillId,SUM(dblTotal) dblTotal
				FROM tblAPBillDetail A
				JOIN tblICItem B ON A.intItemId = B.intItemId  AND B.strType NOT IN('Other Charge','Inventory')
				GROUP BY A.intBillId
		      ) tblAdjustment ON tblAdjustment.intBillId = BillDtl.intBillId
    
	LEFT JOIN (
				SELECT
				PYMT.intPaymentId
				,SUM(BillDtl.dblTax) AS dblGradeFactorTax	
				FROM tblAPPayment PYMT
				JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
				JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = PYMTDTL.intBillId
				JOIN tblICItem B ON B.intItemId = BillDtl.intItemId AND B.strType = 'Other Charge'
				GROUP BY  PYMT.intPaymentId
			  )ScaleDiscountTax ON ScaleDiscountTax.intPaymentId=PYMT.intPaymentId
    
	LEFT JOIN (
				SELECT				
				intBillId
				,SUM(dblAmountApplied* -1) AS dblVendorPrepayment 
				FROM tblAPAppliedPrepaidAndDebit WHERE ysnApplied=1
				GROUP BY intBillId
				) VendorPrepayment ON VendorPrepayment.intBillId = Bill.intBillId

	LEFT JOIN (	
				   SELECT 
				   intPaymentId
				  ,SUM(dblPayment) dblPayment 
				  FROM tblAPPaymentDetail
				  WHERE intInvoiceId IS NOT NULL
				  GROUP BY intPaymentId
			    ) Invoice ON Invoice.intPaymentId=PYMT.intPaymentId
    
	LEFT JOIN (  SELECT 
				  intPaymentId
				 ,SUM(dblTotal) dblTotals
				 ,SUM(dblPayment) dblPayment 
				  FROM tblAPPaymentDetail
				  WHERE intBillId IS NOT NULL
				  GROUP BY intPaymentId
			    ) PartialPayment ON PartialPayment.intPaymentId=PYMT.intPaymentId
    LEFT JOIN (
				SELECT A.intBillId,SUM(dblQtyOrdered) dblTotalQty
				FROM tblAPBillDetail A
				JOIN tblICItem B ON A.intItemId = B.intItemId  AND B.strType <> 'Other Charge'
				GROUP BY A.intBillId
		      ) tblInventory ON tblInventory.intBillId = BillDtl.intBillId

	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1
	LEFT JOIN tblICItemUOM CostItemUOM ON BillDtl.intCostUOMId = CostItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostItemUOM.intUnitMeasureId = CostUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)
	LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
	WHERE BNKTRN.intBankAccountId = @intBankAccountId 

	--------------------------------------------------------
	--Delivery Sheet --> SCALE -->Storage --> Settle Storage
	--------------------------------------------------------
	
	UNION ALL
	
	SELECT DISTINCT
		 intBankAccountId					= BNKTRN.intBankAccountId
		,intBillDetailId					= BillDtl.intBillDetailId
		,intTransactionId					= BNKTRN.intTransactionId
		,strTransactionId					= BNKTRN.strTransactionId
		,strCompanyName						= @strCompanyName
		,strCompanyAddress					= ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')+ CHAR(13)+ CHAR(10) + ISNULL(''+@strPhone,'') 
		,strItemNo							= Item.strItemNo
		,lblGrade							= NULL
		,strGrade							= NULL
		,strCommodity						= Commodity.strCommodityCode
		,strDate							= CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime							= CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber					= dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo						= BNKTRN.strReferenceNo
		,strEntityName						= ENTITY.strName
		,strVendorAddress					= dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)
		,dtmDeliveryDate					= CS.dtmDeliveryDate
		,intTicketId						= DS.intDeliverySheetId
		,strTicketNumber					= DS.strDeliverySheetNumber COLLATE Latin1_General_CI_AS
		,strReceiptNumber					= '' 
		,intInventoryReceiptItemId			= 0
		,intContractDetailId				= ISNULL(BillDtl.intContractDetailId, 0) 
		,RecordId							= Bill.strBillId
		,lblSplitNumber						= NULL
		,strSplitNumber						= NULL 
		,strCustomerReference				= ''
		,lblTicketComment					= NULL
		,strTicketComment					= NULL
		,strDiscountReadings				= [dbo].[fnGRGetDiscountCodeReadings](CS.intCustomerStorageId,'Storage')
		,lblFarmField						= CASE WHEN EntityFarm.strFarmNumber IS NOT NULL THEN 'Farm \ Field' ELSE NULL END 
		,strFarmField						= EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber		
		,dtmDate							= Bill.dtmDate		
		,dblGrossWeight						= ISNULL(SC.dblGrossWeight, 0)		
		,dblTareWeight						= ISNULL(SC.dblTareWeight, 0)		
		,dblNetWeight						= ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		-- ,dblGrossWeight						= CASE 
		-- 										WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
		-- 											THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,StrgHstry.dblUnits)													
		-- 										ELSE
		-- 											ISNULL(SC.dblGrossWeight, 0)
		-- 									END
		-- ,dblTareWeight						= ISNULL(SC.dblTareWeight, 0)						  								 
		-- ,dblNetWeight						= CASE 
		-- 										WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
		-- 											THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,StrgHstry.dblUnits)
		-- 										ELSE
		-- 											ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		-- 									END
		,dblDockage							= [dbo].[fnRemoveTrailingZeroes](ROUND(SC.dblShrink,3))
		,dblCost							= BillDtl.dblCost
		,Net								= CASE WHEN ISNULL(BillDtl.intUnitOfMeasureId,0) >0 AND ISNULL(BillDtl.intCostUOMId,0) >0   THEN dbo.fnCTConvertQtyToTargetItemUOM(BillDtl.intUnitOfMeasureId,BillDtl.intCostUOMId,BillDtl.dblQtyOrdered) ELSE BillDtl.dblQtyOrdered END
		,strUnitMeasure						= ISNULL(CostUOM.strSymbol,UOM.strSymbol)
		,dblTotal							= BillDtl.dblTotal
		,dblTax								= BillDtl.dblTax
		,dblNetTotal						= BillDtl.dblTotal + BillDtl.dblTax
		,lblSourceType						= CASE 
													 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN 'Dist Type'
											      ELSE 'Contract'
											  END
        ,strSourceType						= CASE 
													 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN
														 CASE 
															WHEN StrgHstry.intTransactionTypeId = 4 THEN 'Settle Storage'
															WHEN StrgHstry.intTransactionTypeId = 3 THEN 'Transport'
															WHEN StrgHstry.intTransactionTypeId = 2 THEN 'Inboud Shipment'
															WHEN StrgHstry.intTransactionTypeId = 1 THEN SD.strDistributionType --'Scale'
															ELSE 'None'
														END
											      ELSE CNTRCT.strContractNumber
											  END
		,TotalDiscount					   = ISNULL(tblOtherCharge.dblTotal, 0) *(BillDtl.dblQtyOrdered /tblInventory.dblTotalQty)
		,NetDue							   = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0) 
		,strId							   = Bill.strBillId 
		,intPaymentId					   = PYMT.intPaymentId
		,InboundNetWeight				   = BillDtl.dblQtyOrdered
		,OutboundNetWeight				   = 0 
		,InboundGrossDollars			   = BillDtl.dblTotal 
		,OutboundGrossDollars			   = 0 
		,InboundTax						   = BillDtl.dblTax 
		,OutboundTax					   = 0 
		,InboundDiscount				   = ISNULL(tblOtherCharge.dblTotal, 0) 
		,OutboundDiscount				   = 0 
		,InboundNetDue					   = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0)  
		,OutboundNetDue					   = 0 
		,VoucherAdjustment				   = ISNULL(tblAdjustment.dblTotal, 0)
		,SalesAdjustment				   = Invoice.dblPayment 
		,CheckAmount					   = PYMT.dblAmountPaid
		,IsAdjustment					   = CASE 
													WHEN Item.strType <> 'Inventory' THEN 'True' 
													ELSE 'False'
										     END 
	   ,dblGradeFactorTax				   = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0    THEN ScaleDiscountTax.dblGradeFactorTax					ELSE NULL END 
	   ,lblFactorTax					   = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0    THEN 'Factor Tax'										ELSE NULL END
	   ,dblVendorPrepayment				   = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0  THEN VendorPrepayment.dblVendorPrepayment				ELSE NULL END 
	   ,lblVendorPrepayment				   = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0  THEN 'Vendor Prepay'									ELSE NULL END
	   ,dblCustomerPrepayment              = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					THEN Invoice.dblPayment									ELSE NULL END 
	   ,lblCustomerPrepayment              = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					THEN 'Customer Prepay'									ELSE NULL END
	   ,dblPartialPrepaymentSubTotal       = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0				THEN PartialPayment.dblTotals							ELSE NULL END
	   ,dblPartialPrepayment               = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0				THEN PartialPayment.dblPayment-PartialPayment.dblTotals ELSE NULL END 
	   ,lblPartialPrepayment               = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0				THEN 'Partial Payment Adj'							    ELSE NULL END
	   ,blbHeaderLogo                      = @companyLogo
	   ,strDeliveryDate					   = CONVERT(VARCHAR(10), GETDATE(), 110)
	FROM tblCMBankTransaction BNKTRN
	JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON BNKTRN.strTransactionId = PRINTSPOOL.strTransactionId AND BNKTRN.intBankAccountId = PRINTSPOOL.intBankAccountId
	JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
	JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
	JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
	JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge'
	JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
	JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=StrgHstry.intCustomerStorageId
	LEFT JOIN vyuSCGetScaleDistribution SD ON CS.intCustomerStorageId = SD.intCustomerStorageId
	JOIN (
			 SELECT intDeliverySheetId
					,SUM(ISNULL(dblGrossWeight, 0)) dblGrossWeight
					,SUM(ISNULL(dblTareWeight, 0)) dblTareWeight
					,SUM(ISNULL(dblGrossWeight, 0) - ISNULL(dblTareWeight, 0)) dblNetWeight
					,SUM(dblShrink) dblShrink
					,intItemUOMIdFrom
					,intItemUOMIdTo
			FROM tblSCTicket
			GROUP BY intDeliverySheetId, intItemUOMIdFrom, intItemUOMIdTo
		)SC ON SC.intDeliverySheetId = CS.intDeliverySheetId
	JOIN tblSCDeliverySheet DS ON DS.intDeliverySheetId = SC.intDeliverySheetId AND CS.intDeliverySheetId =SC.intDeliverySheetId
	LEFT JOIN (
			SELECT 
				A.intBillId
				,SUM(dblTotal) dblTotal
			FROM tblAPBillDetail A
			JOIN tblICItem B ON A.intItemId = B.intItemId AND B.strType = 'Other Charge'
			GROUP BY A.intBillId
		  ) tblOtherCharge ON tblOtherCharge.intBillId = Bill.intBillId
    
	JOIN (
			SELECT 
				A.intBillId
				,SUM(dblTax) dblTax
			FROM tblAPBillDetail A		  
			GROUP BY A.intBillId
		  ) tblTax ON tblTax.intBillId = Bill.intBillId
    
	LEFT JOIN (
				SELECT 
					A.intBillId
					,SUM(dblTotal) dblTotal
				FROM tblAPBillDetail A
				JOIN tblICItem B ON A.intItemId = B.intItemId  AND B.strType NOT IN('Other Charge','Inventory')
				GROUP BY A.intBillId
		      ) tblAdjustment ON tblAdjustment.intBillId = BillDtl.intBillId
    
	LEFT JOIN (
				SELECT
					PYMT.intPaymentId
					,SUM(BillDtl.dblTax) AS dblGradeFactorTax	
				FROM tblAPPayment PYMT
				JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
				JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = PYMTDTL.intBillId
				JOIN tblICItem B ON B.intItemId = BillDtl.intItemId AND B.strType = 'Other Charge'
				GROUP BY  PYMT.intPaymentId
			  )ScaleDiscountTax ON ScaleDiscountTax.intPaymentId=PYMT.intPaymentId
    
	LEFT JOIN (
				SELECT				
					intBillId
					,SUM(dblAmountApplied* -1) AS dblVendorPrepayment 
				FROM tblAPAppliedPrepaidAndDebit WHERE ysnApplied=1
				GROUP BY intBillId
				) VendorPrepayment ON VendorPrepayment.intBillId = Bill.intBillId

	LEFT JOIN (	
				SELECT 
					intPaymentId
					,SUM(dblPayment) dblPayment 
				FROM tblAPPaymentDetail
				WHERE intInvoiceId IS NOT NULL
				GROUP BY intPaymentId
			    ) Invoice ON Invoice.intPaymentId=PYMT.intPaymentId
    
	LEFT JOIN (  
				SELECT 
					intPaymentId
					,SUM(dblTotal) dblTotals
					,SUM(dblPayment) dblPayment 
				FROM tblAPPaymentDetail
				WHERE intBillId IS NOT NULL
				GROUP BY intPaymentId
			    ) PartialPayment ON PartialPayment.intPaymentId=PYMT.intPaymentId
    LEFT JOIN (
				SELECT 
					A.intBillId
					,SUM(dblQtyOrdered) dblTotalQty
				FROM tblAPBillDetail A
				JOIN tblICItem B ON A.intItemId = B.intItemId  AND B.strType <> 'Other Charge'
				GROUP BY A.intBillId
		      ) tblInventory ON tblInventory.intBillId = BillDtl.intBillId

	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1	
	LEFT JOIN tblICItemUOM CostItemUOM ON BillDtl.intCostUOMId = CostItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostItemUOM.intUnitMeasureId = CostUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId	
	--LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId	
	LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(DS.intFarmFieldId, 0)
	WHERE BNKTRN.intBankAccountId = @intBankAccountId

END
ELSE
BEGIN
		
		SELECT @intPaymentKey = MIN(intPaymentKey)
		FROM @tblPayment
		
		WHILE @intPaymentKey > 0
		BEGIN
            
			SET @strPaymentNo = NULL
			SELECT @strPaymentNo =strPaymentNo FROM @tblPayment WHERE intPaymentKey = @intPaymentKey				
			
			INSERT INTO @Settlement
			(
			   intBankAccountId					
			  ,intBillDetailId					
			  ,intTransactionId							
			  ,strTransactionId					
			  ,strCompanyName					
			  ,strCompanyAddress				
			  ,strItemNo						
			  ,lblGrade							
			  ,strGrade							
			  ,strCommodity						
			  ,strDate							
			  ,strTime							
			  ,strAccountNumber					
			  ,strReferenceNo					
			  ,strEntityName					
			  ,strVendorAddress					
			  ,dtmDeliveryDate					
			  ,intTicketId						 
			  ,strTicketNumber					
			  ,strReceiptNumber					
			  ,intInventoryReceiptItemId		
			  ,intContractDetailId				
			  ,RecordId							
			  ,lblSplitNumber					
			  ,strSplitNumber					
			  ,strCustomerReference				
			  ,lblTicketComment					
			  ,strTicketComment					
			  ,strDiscountReadings				
			  ,lblFarmField						
			  ,strFarmField						
			  ,dtmDate							
			  ,dblGrossWeight					
			  ,dblTareWeight					
			  ,dblNetWeight						
			  ,dblDockage						
			  ,dblCost							
			  ,Net								
			  ,strUnitMeasure                   
			  ,dblTotal							
			  ,dblTax							
			  ,dblNetTotal						
			  ,lblSourceType					
			  ,strSourceType					
			  ,TotalDiscount					
			  ,NetDue							
			  ,strId							
			  ,intPaymentId						
			  ,InboundNetWeight					
			  ,OutboundNetWeight				
			  ,InboundGrossDollars				
			  ,OutboundGrossDollars				
			  ,InboundTax						
			  ,OutboundTax						
			  ,InboundDiscount					
			  ,OutboundDiscount					
			  ,InboundNetDue					
			  ,OutboundNetDue					
			  ,VoucherAdjustment				
			  ,SalesAdjustment					
			  ,CheckAmount						
			  ,IsAdjustment						
			  ,dblGradeFactorTax			    
			  ,lblFactorTax					    
			  ,dblVendorPrepayment				
			  ,lblVendorPrepayment			    
			  ,dblCustomerPrepayment			
			  ,lblCustomerPrepayment		    
			  ,dblPartialPrepaymentSubTotal		
			  ,dblPartialPrepayment				
			  ,lblPartialPrepayment			    
			  ,blbHeaderLogo
			  ,strDeliveryDate
			)
			--------------------------------------------------------
			-- FROM INVENTORY RECEIPT
			--------------------------------------------------------
			SELECT  DISTINCT 
				 intBankAccountId		    = BNKTRN.intBankAccountId
				,intBillDetailId		    = BillDtl.intBillDetailId
				,intTransactionId		    = BNKTRN.intTransactionId
				,strTransactionId		    = BNKTRN.strTransactionId
				,strCompanyName				= @strCompanyName
				,strCompanyAddress			= ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')+ CHAR(13)+ CHAR(10) + ISNULL(''+@strPhone,'') 
				,strItemNo				    = Item.strItemNo
				,lblGrade				    = CASE WHEN SC.intCommodityAttributeId >0 THEN 'Grade' ELSE NULL END
				,strGrade				    = CASE WHEN SC.intCommodityAttributeId >0 THEN Attribute.strDescription ELSE NULL END
				,strCommodity			    = Commodity.strCommodityCode
				,strDate				    = CONVERT(VARCHAR(10), GETDATE(), 110)
				,strTime				    = CONVERT(VARCHAR(8), GETDATE(), 108)
				,strAccountNumber		    = dbo.fnAESDecryptASym(EFT.strAccountNumber)
				,strReferenceNo			    = BNKTRN.strReferenceNo
				,strEntityName			    = ENTITY.strName
				,strVendorAddress		    = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)		
				,dtmDeliveryDate		    = SC.dtmTicketDateTime 
				,intTicketId			    = SC.intTicketId		
				,strTicketNumber		    = SC.strTicketNumber 
				,strReceiptNumber		    = SC.strElevatorReceiptNumber
				,intInventoryReceiptItemId  = ISNULL(INVRCPTITEM.intInventoryReceiptItemId, 0) 
				,intContractDetailId		= ISNULL(BillDtl.intContractDetailId, 0) 
				,RecordId					= Bill.strBillId
				,lblSplitNumber				= CASE WHEN EM.strSplitNumber IS NOT NULL THEN 'Split' ELSE NULL END		 
				,strSplitNumber				= EM.strSplitNumber
				,strCustomerReference		= SC.strCustomerReference
				,lblTicketComment			= CASE WHEN ISNULL(SC.strTicketComment,'')<>'' THEN 'Comments' ELSE NULL END  
				,strTicketComment			= SC.strTicketComment
				,strDiscountReadings		= [dbo].[fnGRGetDiscountCodeReadings](SC.intTicketId,'Scale')
				,lblFarmField				= CASE WHEN EntityFarm.strFarmNumber IS NOT NULL THEN 'Farm \ Field' ELSE NULL END
				,strFarmField				= EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber 
				,dtmDate					= Bill.dtmDate
				-- ,dblGrossWeight				= ISNULL(SC.dblGrossWeight, 0) 		
				-- ,dblTareWeight				= ISNULL(SC.dblTareWeight, 0) 		
				-- ,dblNetWeight				= ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
				,dblGrossWeight				= CASE 
												WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
													THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,INVRCPTITEM.dblGross)													
												ELSE
													ISNULL(SC.dblGrossWeight, 0)
											  END
				,dblTareWeight				= ISNULL(SC.dblTareWeight, 0)						  								 
				,dblNetWeight				= CASE 
												WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
													THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,INVRCPTITEM.dblGross)
												ELSE
													ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
											  END
				,dblDockage					= [dbo].[fnRemoveTrailingZeroes](ROUND(SC.dblShrink,3))		 
				,dblCost					= BillDtl.dblCost
				,Net						= CASE WHEN ISNULL(BillDtl.intUnitOfMeasureId,0) >0 AND ISNULL(BillDtl.intCostUOMId,0) >0   THEN dbo.fnCTConvertQtyToTargetItemUOM(BillDtl.intUnitOfMeasureId,BillDtl.intCostUOMId,BillDtl.dblQtyOrdered) ELSE BillDtl.dblQtyOrdered END
				,strUnitMeasure				= ISNULL(CostUOM.strSymbol,UOM.strSymbol)
				,dblTotal					= BillDtl.dblTotal
				,dblTax						= BillDtl.dblTax
				,dblNetTotal				= BillDtl.dblTotal+ BillDtl.dblTax
				,lblSourceType				= CASE 
													 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN 'Dist Type'
											      ELSE 'Contract'
											  END							  								 
				,strSourceType				= CASE 
													 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN
														 CASE 
															WHEN INVRCPT.intSourceType = 4 THEN 'Settle Storage'
															WHEN INVRCPT.intSourceType = 3 THEN 'Transport'
															WHEN INVRCPT.intSourceType = 2 THEN 'Inboud Shipment'
															WHEN INVRCPT.intSourceType = 1 THEN SD.strDistributionType --'Scale'
															ELSE 'None'
														END
											      ELSE CNTRCT.strContractNumber
											  END
				,TotalDiscount				= ISNULL(BillByReceipt.dblTotal, 0) 
				,NetDue						= BillDtl.dblTotal + BillDtl.dblTax + ISNULL(BillByReceipt.dblTotal, 0)
				,strId						= Bill.strBillId
				,intPaymentId				= PYMT.intPaymentId
				,InboundNetWeight			= CASE 
													WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
													ELSE BillDtl.dblQtyOrdered
												END 
				,OutboundNetWeight			 = 0 
				,InboundGrossDollars		= CASE 
													WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
													ELSE BillDtl.dblTotal
											  END 
				,OutboundGrossDollars		 = 0
				,InboundTax					= CASE 
												  WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
												  ELSE BillDtl.dblTax
											  END 
				,OutboundTax				 = 0
				,InboundDiscount			 =  ISNULL(BillByReceipt.dblTotal, 0)
				,OutboundDiscount			 = 0 
				,InboundNetDue				 = CASE 
													WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
												    ELSE BillDtl.dblTotal + BillDtl.dblTax + ISNULL(BillByReceipt.dblTotal, 0)
												 END 
				,OutboundNetDue				 = 0 
				,VoucherAdjustment			 =  ISNULL(BillByReceiptItem.dblTotal,0)
				,SalesAdjustment			 = Invoice.dblPayment 
				,CheckAmount				 = PYMT.dblAmountPaid 
				,IsAdjustment				 = CASE 
													WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 'True'
													ELSE 'False'
												END
			   
			   ,dblGradeFactorTax			 = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0   THEN  ScaleDiscountTax.dblGradeFactorTax					ELSE NULL END 
			   ,lblFactorTax				 = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0   THEN 'Factor Tax'						                    ELSE NULL END
			   ,dblVendorPrepayment			 = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN  VendorPrepayment.dblVendorPrepayment				    ELSE NULL END 
			   ,lblVendorPrepayment			 = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay'									    ELSE NULL END
			   ,dblCustomerPrepayment		 = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					 THEN  Invoice.dblPayment								    ELSE NULL END
			   ,lblCustomerPrepayment		 = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					 THEN 'Customer Prepay'									    ELSE NULL END
			   ,dblPartialPrepaymentSubTotal = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			 THEN  PartialPayment.dblTotals							    ELSE NULL END
			   ,dblPartialPrepayment		 = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			 THEN  PartialPayment.dblPayment-PartialPayment.dblTotals	ELSE NULL END 
			   ,lblPartialPrepayment		 = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			 THEN 'Partial Payment Adj'									ELSE NULL END
			   ,blbHeaderLogo				 = @companyLogo
			   ,strDeliveryDate				 = CONVERT(VARCHAR(10), SC.dtmTicketDateTime, 110)
			FROM tblCMBankTransaction BNKTRN
			JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
			JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
			JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
			LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
			LEFT JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			LEFT JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
			LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
			LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
			LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
			LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1			
			LEFT JOIN tblICItemUOM CostItemUOM ON BillDtl.intCostUOMId = CostItemUOM.intItemUOMId
			LEFT JOIN tblICUnitMeasure CostUOM ON CostItemUOM.intUnitMeasureId = CostUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
			LEFT JOIN tblSCTicket SC ON SC.intTicketId = INVRCPTITEM.intSourceId
			LEFT JOIN tblGRCustomerStorage CS ON CS.intTicketId = SC.intTicketId
			LEFT JOIN tblEMEntitySplit EM ON EM.intSplitId = SC.intSplitId AND SC.intSplitId <> 0
			LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)
			LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
			LEFT JOIN vyuSCGetScaleDistribution SD ON INVRCPTITEM.intInventoryReceiptItemId = SD.intInventoryReceiptItemId
			LEFT JOIN (
						SELECT intBillDetailId,SUM(dblAmount) dblTotal 
						FROM vyuGRSettlementSubReport 
						GROUP BY intBillDetailId
					  )BillByReceipt ON BillByReceipt.intBillDetailId=BillDtl.intBillDetailId
			LEFT JOIN (
						SELECT intBillId,SUM(dblTotal) dblTotal
						FROM tblAPBillDetail
						WHERE intInventoryReceiptChargeId IS NOT NULL AND intInventoryReceiptItemId IS NULL
						GROUP BY intBillId
					   )BillByReceiptItem ON BillByReceiptItem.intBillId=BillDtl.intBillId  
			LEFT JOIN (
						SELECT
						PYMT.intPaymentId
						,SUM(BillDtl.dblTax) AS dblGradeFactorTax	
						 FROM tblAPPayment PYMT
						 JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
						 JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = PYMTDTL.intBillId
						 JOIN tblICItem B ON B.intItemId = BillDtl.intItemId AND B.strType = 'Other Charge'
						 WHERE BillDtl.intInventoryReceiptChargeId IS NOT NULL 	 
						GROUP BY  PYMT.intPaymentId
						)ScaleDiscountTax ON ScaleDiscountTax.intPaymentId=PYMT.intPaymentId
			 
			 LEFT JOIN (
						 SELECT				
						 intBillId
						 ,SUM(dblAmountApplied* -1) AS dblVendorPrepayment 
						 FROM tblAPAppliedPrepaidAndDebit WHERE ysnApplied=1
						 GROUP BY intBillId
						) VendorPrepayment ON VendorPrepayment.intBillId = Bill.intBillId
			
			LEFT JOIN (
						  SELECT 
						  intPaymentId
						 ,SUM(dblPayment) dblPayment 
						  FROM tblAPPaymentDetail
						  WHERE intInvoiceId IS NOT NULL
						  GROUP BY intPaymentId
					    ) Invoice ON Invoice.intPaymentId=PYMT.intPaymentId
			
			LEFT JOIN (  SELECT 
						  intPaymentId
						 ,SUM(dblTotal) dblTotals 
						 ,SUM(dblPayment) dblPayment 
						  FROM tblAPPaymentDetail
						  WHERE intBillId IS NOT NULL
						  GROUP BY intPaymentId
					    ) PartialPayment ON PartialPayment.intPaymentId=PYMT.intPaymentId

			WHERE BNKTRN.intBankAccountId = @intBankAccountId
				AND BNKTRN.strTransactionId = @strPaymentNo-- IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionId))
				AND (
					intInventoryReceiptChargeId IS NOT NULL
					OR BillDtl.intInventoryReceiptItemId IS NOT NULL
					)
			--------------------------------------------------------
			-- SCALE --> Storage --> Settle Storage
			--------------------------------------------------------
			
			UNION ALL
			
			SELECT DISTINCT
				 intBankAccountId			 = BNKTRN.intBankAccountId
				,intBillDetailId			 = BillDtl.intBillDetailId
				,intTransactionId			 = BNKTRN.intTransactionId
				,strTransactionId			 = BNKTRN.strTransactionId
				,strCompanyName				 = @strCompanyName
				,strCompanyAddress			 = ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')+ CHAR(13)+ CHAR(10) + ISNULL(''+@strPhone,'') 
				,strItemNo					 = Item.strItemNo
				,lblGrade					 = CASE WHEN SC.intCommodityAttributeId >0 THEN 'Grade' ELSE NULL END
				,strGrade					 = CASE WHEN SC.intCommodityAttributeId >0 THEN Attribute.strDescription ELSE NULL END
				,strCommodity				 = Commodity.strCommodityCode
				,strDate					 = CONVERT(VARCHAR(10), GETDATE(), 110)
				,strTime					 = CONVERT(VARCHAR(8), GETDATE(), 108)
				,strAccountNumber			 = dbo.fnAESDecryptASym(EFT.strAccountNumber)
				,strReferenceNo				 = BNKTRN.strReferenceNo
				,strEntityName				 = ENTITY.strName
				,strVendorAddress			 = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)
				,dtmDeliveryDate			 = SC.dtmTicketDateTime		
				,intTicketId				 = SC.intTicketId		
				,strTicketNumber			 = SC.strTicketNumber
				,strReceiptNumber			 = SC.strElevatorReceiptNumber
				,intInventoryReceiptItemId   = 0 
				,intContractDetailId		 = ISNULL(BillDtl.intContractDetailId, 0) 
				,RecordId					 = Bill.strBillId 		 
				,lblSplitNumber				 = NULL						 
				,strSplitNumber				 = NULL 
				,strCustomerReference		 = SC.strCustomerReference
				,lblTicketComment			 = CASE WHEN ISNULL(SC.strTicketComment,'')<>'' THEN 'Comments' ELSE NULL END
				,strTicketComment			 = SC.strTicketComment
				,strDiscountReadings		 = [dbo].[fnGRGetDiscountCodeReadings](CS.intCustomerStorageId,'Storage')
				,lblFarmField				 = CASE WHEN EntityFarm.strFarmNumber IS NOT NULL THEN 'Farm \ Field' ELSE NULL END 
				,strFarmField				 = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber
				,dtmDate					 = Bill.dtmDate
				,dblGrossWeight				 = ISNULL(SC.dblGrossWeight, 0)
				,dblTareWeight				 =  ISNULL(SC.dblTareWeight, 0)
				,dblNetWeight				 = ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
				-- ,dblGrossWeight				= CASE 
				-- 								WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
				-- 									THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,StrgHstry.dblUnits)													
				-- 								ELSE
				-- 									ISNULL(SC.dblGrossWeight, 0)
				-- 							  END
				-- ,dblTareWeight				= ISNULL(SC.dblTareWeight, 0)						  								 
				-- ,dblNetWeight				= CASE 
				-- 								WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
				-- 									THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,StrgHstry.dblUnits)
				-- 								ELSE
				-- 									ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
				-- 							  END
				,dblDockage					 = [dbo].[fnRemoveTrailingZeroes](ROUND(SC.dblShrink,3))
				,dblCost					 = BillDtl.dblCost
				,Net						 = CASE WHEN ISNULL(BillDtl.intUnitOfMeasureId,0) >0 AND ISNULL(BillDtl.intCostUOMId,0) >0   THEN dbo.fnCTConvertQtyToTargetItemUOM(BillDtl.intUnitOfMeasureId,BillDtl.intCostUOMId,BillDtl.dblQtyOrdered) ELSE BillDtl.dblQtyOrdered END
				,strUnitMeasure				 = ISNULL(CostUOM.strSymbol,UOM.strSymbol)
				,dblTotal					 = BillDtl.dblTotal
				,dblTax						 = BillDtl.dblTax
				,dblNetTotal				 = BillDtl.dblTotal+ BillDtl.dblTax
				,lblSourceType				 = CASE 
											 		 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN 'Dist Type'
											       ELSE 'Contract'
											   END
				,strSourceType				 = CASE 
													 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN
														 CASE 
															WHEN StrgHstry.intTransactionTypeId = 4 THEN 'Settle Storage'
															WHEN StrgHstry.intTransactionTypeId = 3 THEN 'Transport'
															WHEN StrgHstry.intTransactionTypeId = 2 THEN 'Inboud Shipment'
															WHEN StrgHstry.intTransactionTypeId = 1 THEN SD.strDistributionType --'Scale'
															ELSE 'None'
														END
											      ELSE CNTRCT.strContractNumber
											  END 
				,TotalDiscount			     = ISNULL(tblOtherCharge.dblTotal, 0) *(BillDtl.dblQtyOrdered /tblInventory.dblTotalQty)
				,NetDue					     = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0)
				,strId					     = Bill.strBillId
				,intPaymentId			     = PYMT.intPaymentId
				,InboundNetWeight		     = BillDtl.dblQtyOrdered
				,OutboundNetWeight		     = 0 
				,InboundGrossDollars	     = BillDtl.dblTotal 
				,OutboundGrossDollars	     = 0 
				,InboundTax				     = BillDtl.dblTax 
				,OutboundTax			     = 0
				,InboundDiscount		     = ISNULL(tblOtherCharge.dblTotal, 0) 
				,OutboundDiscount		     = 0 
				,InboundNetDue			     = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0) 
				,OutboundNetDue			     = 0 
				,VoucherAdjustment		     = ISNULL(tblAdjustment.dblTotal, 0) 
				,SalesAdjustment		     = Invoice.dblPayment 
				,CheckAmount			     = PYMT.dblAmountPaid 
				,IsAdjustment			     = CASE 
										     		WHEN Item.strType <> 'Inventory' THEN 'True'
										     		ELSE 'False'
										      END
			   ,dblGradeFactorTax		     = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0	   THEN ScaleDiscountTax.dblGradeFactorTax					ELSE NULL END 
			   ,lblFactorTax			     = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0     THEN 'Factor Tax'										ELSE NULL END
			   ,dblVendorPrepayment		     = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0   THEN VendorPrepayment.dblVendorPrepayment				ELSE NULL END 
			   ,lblVendorPrepayment		     = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0   THEN 'Vendor Prepay'										ELSE NULL END
			   ,dblCustomerPrepayment	     = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					   THEN Invoice.dblPayment									ELSE NULL END 
			   ,lblCustomerPrepayment	     = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					   THEN 'Customer Prepay'									ELSE NULL END
			   ,dblPartialPrepaymentSubTotal = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			   THEN PartialPayment.dblTotals							ELSE NULL END
			   ,dblPartialPrepayment		 = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			   THEN PartialPayment.dblPayment-PartialPayment.dblTotals  ELSE NULL END 
			   ,lblPartialPrepayment		 = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			   THEN 'Partial Payment Adj'								ELSE NULL END
			   ,blbHeaderLogo				 = @companyLogo
			   ,strDeliveryDate				 = CONVERT(VARCHAR(10), SC.dtmTicketDateTime, 110)
			FROM tblCMBankTransaction BNKTRN	
			JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
			JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
			JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge'	
			JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
			JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=StrgHstry.intCustomerStorageId
			JOIN tblSCTicket SC ON SC.intTicketId = CS.intTicketId
			LEFT JOIN vyuSCGetScaleDistribution SD ON CS.intCustomerStorageId = SD.intCustomerStorageId
			LEFT JOIN (
					SELECT 
						A.intBillId
						,SUM(dblTotal) dblTotal
					FROM tblAPBillDetail A
					JOIN tblICItem B ON A.intItemId = B.intItemId AND B.strType = 'Other Charge'
					GROUP BY A.intBillId
				  ) tblOtherCharge ON tblOtherCharge.intBillId = Bill.intBillId
			
			JOIN (
					SELECT 
						A.intBillId
						,SUM(dblTax) dblTax
					FROM tblAPBillDetail A		  
					GROUP BY A.intBillId
				  ) tblTax ON tblTax.intBillId = Bill.intBillId
			
			LEFT JOIN (
						SELECT 
							A.intBillId
							,SUM(dblTotal) dblTotal
						FROM tblAPBillDetail A
						JOIN tblICItem B ON A.intItemId = B.intItemId  AND B.strType NOT IN('Other Charge','Inventory')
						GROUP BY A.intBillId
				      ) tblAdjustment ON tblAdjustment.intBillId = BillDtl.intBillId
			
			LEFT JOIN (
						SELECT
							PYMT.intPaymentId
							,SUM(BillDtl.dblTax) AS dblGradeFactorTax	
						FROM tblAPPayment PYMT
						JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
						JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = PYMTDTL.intBillId
						JOIN tblICItem B ON B.intItemId = BillDtl.intItemId AND B.strType = 'Other Charge'
						GROUP BY  PYMT.intPaymentId
					  )ScaleDiscountTax ON ScaleDiscountTax.intPaymentId=PYMT.intPaymentId
			
			LEFT JOIN (
						SELECT
							intBillId
							,SUM(dblAmountApplied* -1) AS dblVendorPrepayment 
						FROM tblAPAppliedPrepaidAndDebit WHERE ysnApplied=1
						GROUP BY intBillId
						) VendorPrepayment ON VendorPrepayment.intBillId = Bill.intBillId
			
			LEFT JOIN (
						SELECT 
							intPaymentId
							,SUM(dblPayment) dblPayment 
						FROM tblAPPaymentDetail WHERE intInvoiceId IS NOT NULL
						GROUP BY intPaymentId
					    ) Invoice ON Invoice.intPaymentId=PYMT.intPaymentId
			
			LEFT JOIN (  
						SELECT 
							intPaymentId
							,SUM(dblTotal) dblTotals
							,SUM(dblPayment) dblPayment 
						FROM tblAPPaymentDetail
						WHERE intBillId IS NOT NULL
						GROUP BY intPaymentId
					    ) PartialPayment ON PartialPayment.intPaymentId=PYMT.intPaymentId
			 LEFT JOIN (
						SELECT 
							A.intBillId
							,SUM(dblQtyOrdered) dblTotalQty
						FROM tblAPBillDetail A
						JOIN tblICItem B ON A.intItemId = B.intItemId  AND B.strType <> 'Other Charge'
						GROUP BY A.intBillId
				      ) tblInventory ON tblInventory.intBillId = BillDtl.intBillId
			LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
			LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
			LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
			LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
			LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1			
			LEFT JOIN tblICItemUOM CostItemUOM ON BillDtl.intCostUOMId = CostItemUOM.intItemUOMId
			LEFT JOIN tblICUnitMeasure CostUOM ON CostItemUOM.intUnitMeasureId = CostUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
			LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)	
			LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
			WHERE BNKTRN.intBankAccountId = @intBankAccountId AND BNKTRN.strTransactionId = @strPaymentNo -- IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionId))

			--------------------------------------------------------
			--Delivery Sheet --> SCALE -->Storage --> Settle Storage
			--------------------------------------------------------
			
			UNION ALL
			
			SELECT  DISTINCT
				 intBankAccountId			 = BNKTRN.intBankAccountId
				,intBillDetailId			 = BillDtl.intBillDetailId
				,intTransactionId			 = BNKTRN.intTransactionId
				,strTransactionId			 = BNKTRN.strTransactionId
				,strCompanyName				 = @strCompanyName
				,strCompanyAddress			 = ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')+ CHAR(13)+ CHAR(10) + ISNULL(''+@strPhone,'') 
				,strItemNo					 = Item.strItemNo
				,lblGrade					 = NULL
				,strGrade					 = NULL
				,strCommodity				 = Commodity.strCommodityCode
				,strDate					 = CONVERT(VARCHAR(10), GETDATE(), 110)
				,strTime					 = CONVERT(VARCHAR(8), GETDATE(), 108)
				,strAccountNumber			 = dbo.fnAESDecryptASym(EFT.strAccountNumber)
				,strReferenceNo				 = BNKTRN.strReferenceNo
				,strEntityName				 = ENTITY.strName
				,strVendorAddress			 = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)
				,dtmDeliveryDate			 = CS.dtmDeliveryDate		
				,intTicketId				 = DS.intDeliverySheetId		
				,strTicketNumber			 = DS.strDeliverySheetNumber COLLATE Latin1_General_CI_AS
				,strReceiptNumber			 = ''
				,intInventoryReceiptItemId   = 0 
				,intContractDetailId		 = ISNULL(BillDtl.intContractDetailId, 0) 
				,RecordId					 = Bill.strBillId 		 
				,lblSplitNumber				 = NULL
				,strSplitNumber				 = NULL 
				,strCustomerReference		 = ''
				,lblTicketComment			 = NULL
				,strTicketComment			 = NULL
				,strDiscountReadings		 = [dbo].[fnGRGetDiscountCodeReadings](CS.intCustomerStorageId,'Storage')
				,lblFarmField				 = CASE WHEN EntityFarm.strFarmNumber IS NOT NULL THEN 'Farm \ Field' ELSE NULL END 		
				,strFarmField				 = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber
				,dtmDate					 = Bill.dtmDate
				,dblGrossWeight				 = ISNULL(SC.dblGrossWeight, 0)
				,dblTareWeight				 = ISNULL(SC.dblTareWeight, 0)
				,dblNetWeight				 = ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
				-- ,dblGrossWeight				= CASE 
				-- 								WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
				-- 									THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,StrgHstry.dblUnits)													
				-- 								ELSE
				-- 									ISNULL(SC.dblGrossWeight, 0)
				-- 							  END
				-- ,dblTareWeight				= ISNULL(SC.dblTareWeight, 0)						  								 
				-- ,dblNetWeight				= CASE 
				-- 								WHEN (SC.dblTareWeight IS NULL) OR (SC.dblTareWeight = 0)
				-- 									THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,SC.intItemUOMIdFrom,StrgHstry.dblUnits)
				-- 								ELSE
				-- 									ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
				-- 							  END
				,dblDockage					 = [dbo].[fnRemoveTrailingZeroes](ROUND(SC.dblShrink,3))
				,dblCost					 = BillDtl.dblCost
				,Net						 = CASE WHEN ISNULL(BillDtl.intUnitOfMeasureId,0) >0 AND ISNULL(BillDtl.intCostUOMId,0) >0   THEN dbo.fnCTConvertQtyToTargetItemUOM(BillDtl.intUnitOfMeasureId,BillDtl.intCostUOMId,BillDtl.dblQtyOrdered) ELSE BillDtl.dblQtyOrdered END
				,strUnitMeasure				 = ISNULL(CostUOM.strSymbol,UOM.strSymbol)
				,dblTotal					 = BillDtl.dblTotal
				,dblTax						 = BillDtl.dblTax
				,dblNetTotal				 = BillDtl.dblTotal+ BillDtl.dblTax
				,lblSourceType				 = CASE 
											 		 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN 'Dist Type'
											       ELSE 'Contract'
											   END
				,strSourceType				 = CASE 
											 		 WHEN ISNULL(BillDtl.intContractHeaderId,0)= 0 THEN
											 			 CASE 
											 				WHEN StrgHstry.intTransactionTypeId = 4 THEN 'Settle Storage'
											 				WHEN StrgHstry.intTransactionTypeId = 3 THEN 'Transport'
											 				WHEN StrgHstry.intTransactionTypeId = 2 THEN 'Inboud Shipment'
											 				WHEN StrgHstry.intTransactionTypeId = 1 THEN SD.strDistributionType --'Scale'
											 				ELSE 'None'
											 			END
											       ELSE CNTRCT.strContractNumber
											   END
				,TotalDiscount				 = ISNULL(tblOtherCharge.dblTotal, 0) *(BillDtl.dblQtyOrdered /tblInventory.dblTotalQty)   
				,NetDue						 = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0)
				,strId						 = Bill.strBillId
				,intPaymentId				 = PYMT.intPaymentId
				,InboundNetWeight			 = BillDtl.dblQtyOrdered
				,OutboundNetWeight			 = 0 
				,InboundGrossDollars	     = BillDtl.dblTotal 
				,OutboundGrossDollars		 = 0 
				,InboundTax					 = BillDtl.dblTax 
				,OutboundTax				 = 0
				,InboundDiscount			 = ISNULL(tblOtherCharge.dblTotal, 0) 
				,OutboundDiscount			 = 0 
				,InboundNetDue				 = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0) 
				,OutboundNetDue				 = 0 
				,VoucherAdjustment			 = ISNULL(tblAdjustment.dblTotal, 0) 
				,SalesAdjustment			 = Invoice.dblPayment 
				,CheckAmount				 = PYMT.dblAmountPaid 
				,IsAdjustment				 = CASE 
											 		WHEN Item.strType <> 'Inventory' THEN 'True'
											 		ELSE 'False'
											   END
			   ,dblGradeFactorTax			 = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0   THEN  ScaleDiscountTax.dblGradeFactorTax				  ELSE NULL END 
			   ,lblFactorTax				 = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0   THEN 'Factor Tax'										  ELSE NULL END
			   ,dblVendorPrepayment			 = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN  VendorPrepayment.dblVendorPrepayment				  ELSE NULL END 
			   ,lblVendorPrepayment			 = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay'									  ELSE NULL END
			   ,dblCustomerPrepayment		 = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					 THEN  Invoice.dblPayment								  ELSE NULL END 
			   ,lblCustomerPrepayment		 = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					 THEN 'Customer Prepay'									  ELSE NULL END
			   ,dblPartialPrepaymentSubTotal = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			 THEN  PartialPayment.dblTotals							  ELSE NULL END
			   ,dblPartialPrepayment		 = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			 THEN  PartialPayment.dblPayment-PartialPayment.dblTotals ELSE NULL END 
			   ,lblPartialPrepayment		 = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			 THEN 'Partial Payment Adj'								  ELSE NULL END
			   ,blbHeaderLogo				 = @companyLogo
			   ,strDeliveryDate				 = CONVERT(VARCHAR(10), GETDATE(), 110)
			FROM tblCMBankTransaction BNKTRN	
			JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
			JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
			JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge'	
			JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
			JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=StrgHstry.intCustomerStorageId
			LEFT JOIN vyuSCGetScaleDistribution SD ON CS.intCustomerStorageId = SD.intCustomerStorageId
			JOIN (
					SELECT 
						intDeliverySheetId
						,SUM(ISNULL(dblGrossWeight, 0)) dblGrossWeight
						,SUM(ISNULL(dblTareWeight, 0)) dblTareWeight
						,SUM(ISNULL(dblGrossWeight, 0) - ISNULL(dblTareWeight, 0)) dblNetWeight
						,SUM(dblShrink) dblShrink
						,intItemUOMIdFrom
						,intItemUOMIdTo
					FROM tblSCTicket
					GROUP BY intDeliverySheetId, intItemUOMIdFrom, intItemUOMIdTo
				 )SC ON SC.intDeliverySheetId = CS.intDeliverySheetId
			JOIN tblSCDeliverySheet DS ON DS.intDeliverySheetId = SC.intDeliverySheetId AND CS.intDeliverySheetId =SC.intDeliverySheetId
			LEFT JOIN (
					SELECT 
						A.intBillId
						,SUM(dblTotal) dblTotal
					FROM tblAPBillDetail A
					JOIN tblICItem B ON A.intItemId = B.intItemId AND B.strType = 'Other Charge'
					GROUP BY A.intBillId
				  ) tblOtherCharge ON tblOtherCharge.intBillId = Bill.intBillId
			
			JOIN (
					SELECT 
						A.intBillId
						,SUM(dblTax) dblTax
					FROM tblAPBillDetail A		  
					GROUP BY A.intBillId
				  ) tblTax ON tblTax.intBillId = Bill.intBillId
			
			LEFT JOIN (
						SELECT 
							A.intBillId
							,SUM(dblTotal) dblTotal
						FROM tblAPBillDetail A
						JOIN tblICItem B ON A.intItemId = B.intItemId  AND B.strType NOT IN('Other Charge','Inventory')
						GROUP BY A.intBillId
				      ) tblAdjustment ON tblAdjustment.intBillId = BillDtl.intBillId
			
			LEFT JOIN (
						SELECT
							PYMT.intPaymentId
							,SUM(BillDtl.dblTax) AS dblGradeFactorTax	
						FROM tblAPPayment PYMT
						JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
						JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = PYMTDTL.intBillId
						JOIN tblICItem B ON B.intItemId = BillDtl.intItemId AND B.strType = 'Other Charge'
						GROUP BY  PYMT.intPaymentId
					  )ScaleDiscountTax ON ScaleDiscountTax.intPaymentId=PYMT.intPaymentId
			
			LEFT JOIN (
						SELECT
							intBillId
							,SUM(dblAmountApplied* -1) AS dblVendorPrepayment 
						FROM tblAPAppliedPrepaidAndDebit WHERE ysnApplied=1
						GROUP BY intBillId
						) VendorPrepayment ON VendorPrepayment.intBillId = Bill.intBillId
			
			LEFT JOIN (
						SELECT 
							intPaymentId
							,SUM(dblPayment) dblPayment 
						FROM tblAPPaymentDetail WHERE intInvoiceId IS NOT NULL
						GROUP BY intPaymentId
					    ) Invoice ON Invoice.intPaymentId=PYMT.intPaymentId
			
			LEFT JOIN (  
						SELECT 
							intPaymentId
							,SUM(dblTotal) dblTotals
							,SUM(dblPayment) dblPayment 
						FROM tblAPPaymentDetail
						WHERE intBillId IS NOT NULL
						GROUP BY intPaymentId
					    ) PartialPayment ON PartialPayment.intPaymentId=PYMT.intPaymentId
			LEFT JOIN (
						SELECT 
							A.intBillId
							,SUM(dblQtyOrdered) dblTotalQty
						FROM tblAPBillDetail A
						JOIN tblICItem B ON A.intItemId = B.intItemId  AND B.strType <> 'Other Charge'
						GROUP BY A.intBillId
				      ) tblInventory ON tblInventory.intBillId = BillDtl.intBillId

			LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
			LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
			LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
			LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
			LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1			
			LEFT JOIN tblICItemUOM CostItemUOM ON BillDtl.intCostUOMId = CostItemUOM.intItemUOMId
			LEFT JOIN tblICUnitMeasure CostUOM ON CostItemUOM.intUnitMeasureId = CostUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId		
			--LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
			LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(DS.intFarmFieldId, 0)	
			WHERE BNKTRN.intBankAccountId = @intBankAccountId AND BNKTRN.strTransactionId = @strPaymentNo --IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionId))

			SELECT @intPaymentKey = MIN(intPaymentKey)
			FROM @tblPayment
			WHERE intPaymentKey > @intPaymentKey
		END	
END

SELECT * FROM @Settlement
