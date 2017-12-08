CREATE PROCEDURE [dbo].[uspGRSettlementReport]
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

DECLARE @xmlDocumentId AS INT
DECLARE @companyLogo varbinary(max)

DECLARE @strPhone NVARCHAR(500)

SELECT @strPhone = CASE 
						WHEN LTRIM(RTRIM(strPhone)) = '' THEN NULL 
						ELSE LTRIM(RTRIM(strPhone)) 
				   END 
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
IF @strModule = 'Cash Management'
BEGIN
	--------------------------------------------------------
	-- FROM INVENTORY RECEIPT
	--------------------------------------------------------
	SELECT 
		 intBankAccountId = BNKTRN.intBankAccountId
		,intTransactionId = BNKTRN.intTransactionId
		,strTransactionId = BNKTRN.strTransactionId
		,strCompanyName = COMPANY.strCompanyName
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip) + CHAR(13)+ CHAR(10) + @strPhone
		,strItemNo = Item.strItemNo
		,lblGrade  = CASE WHEN SC.intCommodityAttributeId >0 THEN 'Grade' ELSE NULL END
		,strGrade  = CASE WHEN SC.intCommodityAttributeId >0 THEN Attribute.strDescription ELSE NULL END
		,strCommodity = Commodity.strCommodityCode
		,strDate = CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime = CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo =BNKTRN.strReferenceNo
		,strEntityName = ENTITY.strName
		,strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)		
		,dtmDeliveryDate = SC.dtmTicketDateTime 
		,intTicketId = SC.intTicketId		
		,strTicketNumber = SC.strTicketNumber 
		,strReceiptNumber = INVRCPT.strReceiptNumber
		,intInventoryReceiptItemId = ISNULL(INVRCPTITEM.intInventoryReceiptItemId, 0) 
		,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0) 
		,RecordId = Bill.strBillId
		,strSourceType = CASE 
							  WHEN INVRCPT.intSourceType = 4 THEN 'Settle Storage'
							  WHEN INVRCPT.intSourceType = 3 THEN 'Transport'
							  WHEN INVRCPT.intSourceType = 2 THEN 'Inboud Shipment'
							  WHEN INVRCPT.intSourceType = 1 THEN 'Scale'
							  ELSE 'None'
						 END 
		,strSplitNumber = EM.strSplitNumber
		,strCustomerReference = SC.strCustomerReference 
		,strTicketComment = SC.strTicketComment
		,strDiscountReadings =[dbo].[fnGRGetDiscountCodeReadings](SC.intTicketId,'Scale')
		,strFarmField = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber 
		,dtmDate = Bill.dtmDate
		,dblGrossWeight = ISNULL(SC.dblGrossWeight, 0) 		
		,dblTareWeight = ISNULL(SC.dblTareWeight, 0) 		
		,dblNetWeight= ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		,dblDockage = ROUND(SC.dblShrink,3)		 
		,dblCost = BillDtl.dblCost
		,Net = BillDtl.dblQtyOrdered
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = BillDtl.dblTotal
		,dblTax = BillDtl.dblTax
		,dblNetTotal = BillDtl.dblTotal+ BillDtl.dblTax
		,strContractNumber = CNTRCT.strContractNumber
		,TotalDiscount = ISNULL(BillByReceipt.dblTotal, 0) 
		,NetDue = BillDtl.dblTotal + BillDtl.dblTax + ISNULL(BillByReceipt.dblTotal, 0)
		,strId = Bill.strBillId
		,intPaymentId = PYMT.intPaymentId
		,
		--Settlement Total
		 InboundNetWeight = CASE 
								WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
								ELSE BillDtl.dblQtyOrdered
							END 
		,OutboundNetWeight = 0 
		,InboundGrossDollars = CASE 
									WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
									ELSE BillDtl.dblTotal
							   END 
		,OutboundGrossDollars = 0
		,InboundTax = CASE 
						  WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
						  ELSE BillDtl.dblTax
					  END 
		,OutboundTax = 0
		,InboundDiscount =  ISNULL(BillByReceipt.dblTotal, 0)
		,OutboundDiscount = 0 
		,InboundNetDue = CASE 
							WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
						    ELSE BillDtl.dblTotal + BillDtl.dblTax + ISNULL(BillByReceipt.dblTotal, 0)
						 END 
		,OutboundNetDue = 0 
		,VoucherAdjustment =  ISNULL(BillByReceiptItem.dblTotal,0)
		,SalesAdjustment = Invoice.dblPayment 
		,CheckAmount = PYMT.dblAmountPaid 
		,IsAdjustment = CASE 
							WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 'True'
							ELSE 'False'
						END
       
	   ,dblGradeFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN ScaleDiscountTax.dblGradeFactorTax ELSE NULL END 
	   ,lblFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN 'Factor Tax' ELSE NULL END
	   ,dblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN VendorPrepayment.dblVendorPrepayment ELSE NULL END 
	   ,lblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay' ELSE NULL END
	   ,dblCustomerPrepayment = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0 THEN Invoice.dblPayment ELSE NULL END 
	   ,lblCustomerPrepayment = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0 THEN 'Customer Prepay' ELSE NULL END
	   ,dblPartialPrepaymentSubTotal = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN PartialPayment.dblTotals ELSE NULL END
	   ,dblPartialPrepayment = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN PartialPayment.dblPayment-PartialPayment.dblTotals ELSE NULL END 
	   ,lblPartialPrepayment = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN 'Partial Payment Adj' ELSE NULL END						 
	   ,blbHeaderLogo = @companyLogo						 	   						 
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
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup )
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblSCTicket SC ON SC.intTicketId = INVRCPTITEM.intSourceId
	LEFT JOIN tblGRCustomerStorage CS ON CS.intTicketId = SC.intTicketId
	LEFT JOIN tblEMEntitySplit EM ON EM.intSplitId = SC.intSplitId AND SC.intSplitId <> 0
	LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)
	LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
	
	LEFT JOIN (
				SELECT intBillId,SUM(dblTotal) dblTotal
				FROM tblAPBillDetail
				WHERE intInventoryReceiptChargeId IS NOT NULL
				GROUP BY intBillId
			  )BillByReceipt ON BillByReceipt.intBillId=BillDtl.intBillId
	
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
	
	SELECT 
		 intBankAccountId = BNKTRN.intBankAccountId
		,intTransactionId = BNKTRN.intTransactionId
		,strTransactionId = BNKTRN.strTransactionId
		,strCompanyName = COMPANY.strCompanyName
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)+ CHAR(13)+ CHAR(10) + @strPhone
		,strItemNo= Item.strItemNo
		,lblGrade  = CASE WHEN SC.intCommodityAttributeId >0 THEN 'Grade' ELSE NULL END
		,strGrade  = CASE WHEN SC.intCommodityAttributeId >0 THEN Attribute.strDescription ELSE NULL END
		,strCommodity = Commodity.strCommodityCode
		,strDate = CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime = CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo = BNKTRN.strReferenceNo
		,strEntityName = ENTITY.strName
		,strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)
		,dtmDeliveryDate = SC.dtmTicketDateTime
		,intTicketId = SC.intTicketId
		,strTicketNumber = SC.strTicketNumber
		,strReceiptNumber = '' 
		,intInventoryReceiptItemId=0
		,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0) 
		,RecordId = Bill.strBillId 
		,strSourceType= CASE 
							WHEN StrgHstry.intTransactionTypeId = 4 THEN 'Settle Storage'
							WHEN StrgHstry.intTransactionTypeId = 3 THEN 'Transport'
							WHEN StrgHstry.intTransactionTypeId = 2 THEN 'Inboud Shipment'
							WHEN StrgHstry.intTransactionTypeId = 1 THEN 'Scale'
							ELSE 'None'
						END 
		,strSplitNumber = '' 
		,strCustomerReference = SC.strCustomerReference
		,strTicketComment = SC.strTicketComment
		,strDiscountReadings =[dbo].[fnGRGetDiscountCodeReadings](CS.intCustomerStorageId,'Storage')
		,strFarmField = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber
		,dtmDate = Bill.dtmDate		
		,dblGrossWeight = ISNULL(SC.dblGrossWeight, 0)		
		,dblTareWeight = ISNULL(SC.dblTareWeight, 0)		
		,dblNetWeight = ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		,dblDockage = [dbo].[fnRemoveTrailingZeroes](ROUND(SC.dblShrink,3))
		,dblCost = BillDtl.dblCost
		,Net = BillDtl.dblQtyOrdered 
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = BillDtl.dblTotal
		,dblTax = BillDtl.dblTax
		,dblNetTotal = BillDtl.dblTotal + BillDtl.dblTax 
		,strContractNumber = CNTRCT.strContractNumber
		,TotalDiscount =  ISNULL(tblOtherCharge.dblTotal, 0)
		,NetDue = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0) 
		,strId = Bill.strBillId 
		,intPaymentId = PYMT.intPaymentId
		,
		--Settlement Total
		 InboundNetWeight=BillDtl.dblQtyOrdered
		,OutboundNetWeight= 0 
		,InboundGrossDollars = BillDtl.dblTotal 
		,OutboundGrossDollars= 0 
		,InboundTax = BillDtl.dblTax 
		,OutboundTax = 0 
		,InboundDiscount = ISNULL(tblOtherCharge.dblTotal, 0) 
		,OutboundDiscount = 0 
		,InboundNetDue = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0)  
		,OutboundNetDue = 0 
		,VoucherAdjustment = ISNULL(tblAdjustment.dblTotal, 0)
		,SalesAdjustment = Invoice.dblPayment 
		,CheckAmount = PYMT.dblAmountPaid
		,IsAdjustment= CASE 
							WHEN Item.strType <> 'Inventory' THEN 'True' 
							ELSE 'False'
					   END 
       
	   ,dblGradeFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN ScaleDiscountTax.dblGradeFactorTax ELSE NULL END 
	   ,lblFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN 'Factor Tax' ELSE NULL END
	   ,dblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN VendorPrepayment.dblVendorPrepayment ELSE NULL END 
	   ,lblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay' ELSE NULL END
	   ,dblCustomerPrepayment = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0 THEN Invoice.dblPayment ELSE NULL END 
	   ,lblCustomerPrepayment = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0 THEN 'Customer Prepay' ELSE NULL END
	   ,dblPartialPrepaymentSubTotal = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN PartialPayment.dblTotals ELSE NULL END
	   ,dblPartialPrepayment = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN PartialPayment.dblPayment-PartialPayment.dblTotals ELSE NULL END 
	   ,lblPartialPrepayment = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN 'Partial Payment Adj' ELSE NULL END
	   ,blbHeaderLogo = @companyLogo
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

	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)
	LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
	WHERE BNKTRN.intBankAccountId = @intBankAccountId 

   --------------------------------------------------------
	--Delivery Sheet --> SCALE -->Storage --> Settle Storage
	--------------------------------------------------------	
	UNION ALL
	
	SELECT 
		 intBankAccountId = BNKTRN.intBankAccountId
		,intTransactionId = BNKTRN.intTransactionId
		,strTransactionId = BNKTRN.strTransactionId
		,strCompanyName = COMPANY.strCompanyName
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)
		,strItemNo= Item.strItemNo
		,strCommodity = Commodity.strCommodityCode
		,strDate = CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime = CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo = BNKTRN.strReferenceNo
		,strEntityName = ENTITY.strName
		,strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)
		,dtmDeliveryDate = SC.dtmTicketDateTime
		,intTicketId = SC.intTicketId
		,strTicketNumber = SC.strTicketNumber
		,strReceiptNumber = '' 
		,intInventoryReceiptItemId=0
		,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0) 
		,RecordId = Bill.strBillId 
		,strSourceType= CASE 
							WHEN StrgHstry.intTransactionTypeId = 4 THEN 'Settle Storage'
							WHEN StrgHstry.intTransactionTypeId = 3 THEN 'Transport'
							WHEN StrgHstry.intTransactionTypeId = 2 THEN 'Inboud Shipment'
							WHEN StrgHstry.intTransactionTypeId = 1 THEN 'Scale'
							ELSE 'None'
						END 
		,strSplitNumber = '' 
		,strCustomerReference = SC.strCustomerReference
		,strTicketComment = SC.strTicketComment
		,strFarmField = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber
		,dtmDate = Bill.dtmDate		
		,dblGrossWeight = ISNULL(SC.dblGrossWeight, 0)		
		,dblTareWeight = ISNULL(SC.dblTareWeight, 0)		
		,dblNetWeight = ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		,dblCost = BillDtl.dblCost
		,Net = BillDtl.dblQtyOrdered 
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = BillDtl.dblTotal
		,dblTax = BillDtl.dblTax 
		,strContractNumber = CNTRCT.strContractNumber
		,TotalDiscount =  ISNULL(tblOtherCharge.dblTotal, 0)
		,NetDue = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0) 
		,strId = Bill.strBillId 
		,intPaymentId = PYMT.intPaymentId
		,
		--Settlement Total
		 InboundNetWeight=BillDtl.dblQtyOrdered
		,OutboundNetWeight= 0 
		,InboundGrossDollars = BillDtl.dblTotal 
		,OutboundGrossDollars= 0 
		,InboundTax = BillDtl.dblTax 
		,OutboundTax = 0 
		,InboundDiscount = ISNULL(tblOtherCharge.dblTotal, 0) 
		,OutboundDiscount = 0 
		,InboundNetDue = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0)  
		,OutboundNetDue = 0 
		,VoucherAdjustment = ISNULL(tblAdjustment.dblTotal, 0)
		,SalesAdjustment = Invoice.dblPayment 
		,CheckAmount = PYMT.dblAmountPaid
		,IsAdjustment= CASE 
							WHEN Item.strType <> 'Inventory' THEN 'True' 
							ELSE 'False'
					   END 
       
	   ,dblGradeFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN ScaleDiscountTax.dblGradeFactorTax ELSE NULL END 
	   ,lblFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN 'Factor Tax' ELSE NULL END
	   ,dblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN VendorPrepayment.dblVendorPrepayment ELSE NULL END 
	   ,lblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay' ELSE NULL END
	   ,dblCustomerPrepayment = NULL
	   ,lblCustomerPrepayment = NULL

	FROM tblCMBankTransaction BNKTRN
	JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON BNKTRN.strTransactionId = PRINTSPOOL.strTransactionId AND BNKTRN.intBankAccountId = PRINTSPOOL.intBankAccountId
	JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
	JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
	JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
	JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge'
	JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
	JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=StrgHstry.intCustomerStorageId
	JOIN tblSCTicket SC ON SC.intDeliverySheetId = CS.intDeliverySheetId
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
				PYMTDTL.intPaymentId
			   ,PYMTDTL.intBillId
			   ,SUM(PYMTDTL.dblPayment * -1) AS dblVendorPrepayment
			   FROM tblAPPayment PYMT
			   JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId			
			   AND PYMT.ysnPrepay = 1 AND PYMT.ysnPosted = 1
			   GROUP BY PYMTDTL.intPaymentId,PYMTDTL.intBillId
			  ) VendorPrepayment ON VendorPrepayment.intPaymentId=PYMT.intPaymentId AND  VendorPrepayment.intBillId = Bill.intBillId
	LEFT JOIN (
					SELECT intPaymentId,SUM(dblPayment) dblPayment FROM tblAPPaymentDetail
					WHERE intBillId IS NULL
					GROUP BY intPaymentId
			    ) Invoice ON Invoice.intPaymentId=PYMT.intPaymentId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)
	WHERE BNKTRN.intBankAccountId = @intBankAccountId

END
ELSE
BEGIN
	--------------------------------------------------------
	-- FROM INVENTORY RECEIPT
	--------------------------------------------------------
	SELECT 
		 intBankAccountId = BNKTRN.intBankAccountId
		,intTransactionId = BNKTRN.intTransactionId
		,strTransactionId = BNKTRN.strTransactionId
		,strCompanyName = COMPANY.strCompanyName
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)+ CHAR(13)+ CHAR(10) + @strPhone
		,strItemNo = Item.strItemNo
		,lblGrade  = CASE WHEN SC.intCommodityAttributeId >0 THEN 'Grade' ELSE NULL END
		,strGrade  = CASE WHEN SC.intCommodityAttributeId >0 THEN Attribute.strDescription ELSE NULL END
		,strCommodity = Commodity.strCommodityCode
		,strDate = CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime = CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo =BNKTRN.strReferenceNo
		,strEntityName = ENTITY.strName
		,strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)		
		,dtmDeliveryDate = SC.dtmTicketDateTime 
		,intTicketId = SC.intTicketId		
		,strTicketNumber = SC.strTicketNumber 
		,strReceiptNumber = INVRCPT.strReceiptNumber
		,intInventoryReceiptItemId = ISNULL(INVRCPTITEM.intInventoryReceiptItemId, 0) 
		,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0) 
		,RecordId = Bill.strBillId
		,strSourceType = CASE 
							  WHEN INVRCPT.intSourceType = 4 THEN 'Settle Storage'
							  WHEN INVRCPT.intSourceType = 3 THEN 'Transport'
							  WHEN INVRCPT.intSourceType = 2 THEN 'Inboud Shipment'
							  WHEN INVRCPT.intSourceType = 1 THEN 'Scale'
							  ELSE 'None'
						 END 
		,strSplitNumber = EM.strSplitNumber
		,strCustomerReference = SC.strCustomerReference 
		,strTicketComment = SC.strTicketComment
		,strDiscountReadings =[dbo].[fnGRGetDiscountCodeReadings](SC.intTicketId,'Scale')
		,strFarmField = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber 
		,dtmDate = Bill.dtmDate
		,dblGrossWeight = ISNULL(SC.dblGrossWeight, 0) 		
		,dblTareWeight = ISNULL(SC.dblTareWeight, 0) 		
		,dblNetWeight = ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		,dblDockage = [dbo].[fnRemoveTrailingZeroes](ROUND(SC.dblShrink,3))		 
		,dblCost = BillDtl.dblCost
		,Net = BillDtl.dblQtyOrdered
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = BillDtl.dblTotal
		,dblTax = BillDtl.dblTax
		,dblNetTotal = BillDtl.dblTotal+ BillDtl.dblTax
		,strContractNumber = CNTRCT.strContractNumber
		,TotalDiscount = ISNULL(BillByReceipt.dblTotal, 0) 
		,NetDue = BillDtl.dblTotal + BillDtl.dblTax + ISNULL(BillByReceipt.dblTotal, 0)
		,strId = Bill.strBillId
		,intPaymentId = PYMT.intPaymentId
		,
		--Settlement Total
		 InboundNetWeight = CASE 
								WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
								ELSE BillDtl.dblQtyOrdered
							END 
		,OutboundNetWeight = 0 
		,InboundGrossDollars = CASE 
									WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
									ELSE BillDtl.dblTotal
							   END 
		,OutboundGrossDollars = 0
		,InboundTax = CASE 
						  WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
						  ELSE BillDtl.dblTax
					  END 
		,OutboundTax = 0
		,InboundDiscount =  ISNULL(BillByReceipt.dblTotal, 0)
		,OutboundDiscount = 0 
		,InboundNetDue = CASE 
							WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0
						    ELSE BillDtl.dblTotal + BillDtl.dblTax + ISNULL(BillByReceipt.dblTotal, 0)
						 END 
		,OutboundNetDue = 0 
		,VoucherAdjustment =  ISNULL(BillByReceiptItem.dblTotal,0)
		,SalesAdjustment = Invoice.dblPayment 
		,CheckAmount = PYMT.dblAmountPaid 
		,IsAdjustment = CASE 
							WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 'True'
							ELSE 'False'
						END
       
	   ,dblGradeFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN ScaleDiscountTax.dblGradeFactorTax ELSE NULL END 
	   ,lblFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN 'Factor Tax' ELSE NULL END
	   ,dblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN VendorPrepayment.dblVendorPrepayment ELSE NULL END 
	   ,lblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay' ELSE NULL END
	   ,dblCustomerPrepayment = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0 THEN Invoice.dblPayment ELSE NULL END
	   ,lblCustomerPrepayment = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0 THEN 'Customer Prepay' ELSE NULL END
	   ,dblPartialPrepaymentSubTotal = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN PartialPayment.dblTotals ELSE NULL END
	   ,dblPartialPrepayment = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN PartialPayment.dblPayment-PartialPayment.dblTotals ELSE NULL END 
	   ,lblPartialPrepayment = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN 'Partial Payment Adj' ELSE NULL END
	   ,blbHeaderLogo = @companyLogo
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
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = ( SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblSCTicket SC ON SC.intTicketId = INVRCPTITEM.intSourceId
	LEFT JOIN tblGRCustomerStorage CS ON CS.intTicketId = SC.intTicketId
	LEFT JOIN tblEMEntitySplit EM ON EM.intSplitId = SC.intSplitId AND SC.intSplitId <> 0
	LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)
	LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
	LEFT JOIN (
				SELECT intBillId,SUM(dblTotal) dblTotal
				FROM tblAPBillDetail
				WHERE intInventoryReceiptChargeId IS NOT NULL
				GROUP BY intBillId
			  )BillByReceipt ON BillByReceipt.intBillId=BillDtl.intBillId
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
		AND BNKTRN.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionId))
		AND (
			intInventoryReceiptChargeId IS NOT NULL
			OR BillDtl.intInventoryReceiptItemId IS NOT NULL
			)
	--------------------------------------------------------
	-- FROM SETTLE STORAGE
	--------------------------------------------------------
	
	UNION ALL
	
	SELECT 
		 intBankAccountId = BNKTRN.intBankAccountId
		,intTransactionId = BNKTRN.intTransactionId
		,strTransactionId = BNKTRN.strTransactionId
		,strCompanyName = COMPANY.strCompanyName
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)+ CHAR(13)+ CHAR(10) + @strPhone
		,strItemNo = Item.strItemNo
		,lblGrade  = CASE WHEN SC.intCommodityAttributeId >0 THEN 'Grade' ELSE NULL END
		,strGrade  = CASE WHEN SC.intCommodityAttributeId >0 THEN Attribute.strDescription ELSE NULL END
		,strCommodity = Commodity.strCommodityCode
		,strDate = CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime = CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo = BNKTRN.strReferenceNo
		,strEntityName = ENTITY.strName
		,strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)
		,dtmDeliveryDate = SC.dtmTicketDateTime		
		,intTicketId = SC.intTicketId		
		,strTicketNumber = SC.strTicketNumber
		,strReceiptNumber = ''
		,intInventoryReceiptItemId = 0 
		,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0) 
		,RecordId = Bill.strBillId 
		,strSourceType = CASE 
							WHEN StrgHstry.intTransactionTypeId = 4 THEN 'Settle Storage'
							WHEN StrgHstry.intTransactionTypeId = 3 THEN 'Transport'
							WHEN StrgHstry.intTransactionTypeId = 2 THEN 'Inboud Shipment'
							WHEN StrgHstry.intTransactionTypeId = 1 THEN 'Scale'
							ELSE 'None'
						 END 
		,strSplitNumber = '' 
		,strCustomerReference = SC.strCustomerReference
		,strTicketComment = SC.strTicketComment
		,strDiscountReadings =[dbo].[fnGRGetDiscountCodeReadings](CS.intCustomerStorageId,'Storage')
		,strFarmField = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber
		,dtmDate = Bill.dtmDate
		,dblGrossWeight = ISNULL(SC.dblGrossWeight, 0)
		,dblTareWeight =  ISNULL(SC.dblTareWeight, 0)
		,dblNetWeight = ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		,dblDockage = [dbo].[fnRemoveTrailingZeroes](ROUND(SC.dblShrink,3))
		,dblCost = BillDtl.dblCost
		,Net = BillDtl.dblQtyOrdered 
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = BillDtl.dblTotal
		,dblTax = BillDtl.dblTax
		,dblNetTotal = BillDtl.dblTotal+ BillDtl.dblTax 
		,strContractNumber = CNTRCT.strContractNumber
		,TotalDiscount = ISNULL(tblOtherCharge.dblTotal, 0) 
		,NetDue = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0)
		,strId = Bill.strBillId
		,intPaymentId = PYMT.intPaymentId
		,
		--Settlement Total
		 InboundNetWeight = BillDtl.dblQtyOrdered
		,OutboundNetWeight = 0 
		,InboundGrossDollars = BillDtl.dblTotal 
		,OutboundGrossDollars = 0 
		,InboundTax = BillDtl.dblTax 
		,OutboundTax = 0
		,InboundDiscount = ISNULL(tblOtherCharge.dblTotal, 0) 
		,OutboundDiscount = 0 
		,InboundNetDue = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0) 
		,OutboundNetDue = 0 
		,VoucherAdjustment = ISNULL(tblAdjustment.dblTotal, 0) 
		,SalesAdjustment = Invoice.dblPayment 
		,CheckAmount = PYMT.dblAmountPaid 
		,IsAdjustment= CASE 
							WHEN Item.strType <> 'Inventory' THEN 'True'
							ELSE 'False'
					   END
	   ,dblGradeFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN ScaleDiscountTax.dblGradeFactorTax ELSE NULL END 
	   ,lblFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN 'Factor Tax' ELSE NULL END
	   ,dblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN VendorPrepayment.dblVendorPrepayment ELSE NULL END 
	   ,lblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay' ELSE NULL END
	   ,dblCustomerPrepayment = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0 THEN Invoice.dblPayment ELSE NULL END 
	   ,lblCustomerPrepayment = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0 THEN 'Customer Prepay' ELSE NULL END
	   ,dblPartialPrepaymentSubTotal = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN PartialPayment.dblTotals ELSE NULL END
	   ,dblPartialPrepayment = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN PartialPayment.dblPayment-PartialPayment.dblTotals ELSE NULL END 
	   ,lblPartialPrepayment = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN 'Partial Payment Adj' ELSE NULL END
	   ,blbHeaderLogo = @companyLogo					    	   					    
	FROM tblCMBankTransaction BNKTRN	
	JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
	JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
	JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
	JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge'	
	JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
	JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=StrgHstry.intCustomerStorageId
	JOIN tblSCTicket SC ON SC.intTicketId = CS.intTicketId
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
				 FROM tblAPPaymentDetail WHERE intInvoiceId IS NOT NULL
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

	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = ( SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup )
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)	
	LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
	WHERE BNKTRN.intBankAccountId = @intBankAccountId AND BNKTRN.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionId))

	--------------------------------------------------------
	--Delivery Sheet --> SCALE -->Storage --> Settle Storage
	--------------------------------------------------------
	
	UNION ALL
	SELECT 
		 intBankAccountId = BNKTRN.intBankAccountId
		,intTransactionId = BNKTRN.intTransactionId
		,strTransactionId = BNKTRN.strTransactionId
		,strCompanyName = COMPANY.strCompanyName
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)
		,strItemNo = Item.strItemNo
		,strCommodity = Commodity.strCommodityCode
		,strDate = CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime = CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo = BNKTRN.strReferenceNo
		,strEntityName = ENTITY.strName
		,strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode)
		,dtmDeliveryDate = SC.dtmTicketDateTime		
		,intTicketId = SC.intTicketId		
		,strTicketNumber = SC.strTicketNumber
		,strReceiptNumber = ''
		,intInventoryReceiptItemId = 0 
		,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0) 
		,RecordId = Bill.strBillId 
		,strSourceType = CASE 
							WHEN StrgHstry.intTransactionTypeId = 4 THEN 'Settle Storage'
							WHEN StrgHstry.intTransactionTypeId = 3 THEN 'Transport'
							WHEN StrgHstry.intTransactionTypeId = 2 THEN 'Inboud Shipment'
							WHEN StrgHstry.intTransactionTypeId = 1 THEN 'Scale'
							ELSE 'None'
						 END 
		,strSplitNumber = '' 
		,strCustomerReference = SC.strCustomerReference
		,strTicketComment = SC.strTicketComment
		,strFarmField = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber
		,dtmDate = Bill.dtmDate
		,dblGrossWeight = ISNULL(SC.dblGrossWeight, 0)
		,dblTareWeight =  ISNULL(SC.dblTareWeight, 0)
		,dblNetWeight = ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
		,dblCost = BillDtl.dblCost
		,Net = BillDtl.dblQtyOrdered 
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = BillDtl.dblTotal
		,dblTax = BillDtl.dblTax 
		,strContractNumber = CNTRCT.strContractNumber
		,TotalDiscount = ISNULL(tblOtherCharge.dblTotal, 0) 
		,NetDue = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0)
		,strId = Bill.strBillId
		,intPaymentId = PYMT.intPaymentId
		,
		--Settlement Total
		 InboundNetWeight = BillDtl.dblQtyOrdered
		,OutboundNetWeight = 0 
		,InboundGrossDollars = BillDtl.dblTotal 
		,OutboundGrossDollars = 0 
		,InboundTax = BillDtl.dblTax 
		,OutboundTax = 0
		,InboundDiscount = ISNULL(tblOtherCharge.dblTotal, 0) 
		,OutboundDiscount = 0 
		,InboundNetDue = BillDtl.dblTotal + ISNULL(tblTax.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0) 
		,OutboundNetDue = 0 
		,VoucherAdjustment = ISNULL(tblAdjustment.dblTotal, 0) 
		,SalesAdjustment = Invoice.dblPayment 
		,CheckAmount = PYMT.dblAmountPaid 
		,IsAdjustment= CASE 
							WHEN Item.strType <> 'Inventory' THEN 'True'
							ELSE 'False'
					   END
	   ,dblGradeFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN ScaleDiscountTax.dblGradeFactorTax ELSE NULL END 
	   ,lblFactorTax = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN 'Factor Tax' ELSE NULL END
	   ,dblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN VendorPrepayment.dblVendorPrepayment ELSE NULL END 
	   ,lblVendorPrepayment = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay' ELSE NULL END
	   ,dblCustomerPrepayment = NULL
	   ,lblCustomerPrepayment = NULL					    
	
	FROM tblCMBankTransaction BNKTRN	
	JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
	JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
	JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
	JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge'	
	JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
	JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=StrgHstry.intCustomerStorageId
	JOIN tblSCTicket SC ON SC.intDeliverySheetId = CS.intDeliverySheetId
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
				PYMTDTL.intPaymentId
			   ,PYMTDTL.intBillId
			   ,SUM(PYMTDTL.dblPayment * -1) AS dblVendorPrepayment
			   FROM tblAPPayment PYMT
			   JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId			
			   AND PYMT.ysnPrepay = 1 AND PYMT.ysnPosted = 1
			   GROUP BY PYMTDTL.intPaymentId,PYMTDTL.intBillId
			  ) VendorPrepayment ON VendorPrepayment.intPaymentId=PYMT.intPaymentId AND  VendorPrepayment.intBillId = Bill.intBillId
    
	LEFT JOIN (
					SELECT intPaymentId,SUM(dblPayment) dblPayment FROM tblAPPaymentDetail
					WHERE intBillId IS NULL
					GROUP BY intPaymentId
			    ) Invoice ON Invoice.intPaymentId=PYMT.intPaymentId

	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId=Item.intCommodityId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = ( SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup )
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblEMEntityFarm EntityFarm ON EntityFarm.intEntityId=VENDOR.intEntityId AND EntityFarm.intFarmFieldId=ISNULL(SC.intFarmFieldId, 0)	
	WHERE BNKTRN.intBankAccountId = @intBankAccountId AND BNKTRN.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionId))
END

