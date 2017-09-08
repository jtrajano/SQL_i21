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
	,@strTransactionId AS NVARCHAR(40)
	,@strModule AS NVARCHAR(40)

DECLARE @xmlDocumentId AS INT
DECLARE @companyLogo varbinary(max)

DECLARE @temp_xml_table TABLE 
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
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)
		,strItemNo = Item.strItemNo
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
		,strFarmField = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber 
		,dtmDate = Bill.dtmDate
		,dblGrossWeight = ISNULL(SC.dblGrossWeight, 0) 		
		,dblTareWeight = ISNULL(SC.dblTareWeight, 0) 		
		,dblNetWeight= ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)		 
		,dblCost = BillDtl.dblCost
		,Net = BillDtl.dblQtyOrdered
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = BillDtl.dblTotal
		,dblTax = BillDtl.dblTax
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
	   ,dblCustomerPrepayment = NULL
	   ,lblCustomerPrepayment = NULL
	   ,blbHeaderLogo = @companyLogo						 
	   ,lblCustomerPrepayment = NULL						 
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

	WHERE BNKTRN.intBankAccountId = @intBankAccountId
		AND (
			intInventoryReceiptChargeId IS NOT NULL
			OR BillDtl.intInventoryReceiptItemId IS NOT NULL
			)
	/*
	--------------------------------------------------------
	-- FROM INVENTORY SHIPMENT
	--------------------------------------------------------
	
	UNION ALL
	
	SELECT 
		 intBankAccountId = BNKTRN.intBankAccountId
		,intTransactionId = BNKTRN.intTransactionId
		,strTransactionId = BNKTRN.strTransactionId
		,strCompanyName = COMPANY.strCompanyName
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)
		,strItemNo= Item.strItemNo
		,strCommodity = (
						  SELECT strCommodityCode
						  FROM tblICCommodity
						  WHERE intCommodityId = Item.intCommodityId
						 )
		,strDate = CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime = CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,BNKTRN.strReferenceNo
		,strEntityName = ENTITY.strName
		,strVendorAddress = ''
		,dtmDeliveryDate =  CASE 
								WHEN INVSHIP.intSourceType = 4
									THEN (
											SELECT TOP 1 SC.dtmTicketDateTime
											FROM tblGRCustomerStorage GR
											JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
											WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
										 )
							ELSE (
										SELECT TOP 1 SC.dtmTicketDateTime
										FROM tblSCTicket SC
										WHERE intTicketId = INVSHIPITEM.intSourceId
								 )
							END 
		,intTicketId = CASE 
							WHEN INVSHIP.intSourceType = 4
							THEN (
									SELECT TOP 1 SC.intTicketId
									FROM tblGRCustomerStorage GR
									JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
									WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
								  )
					    ELSE (
								SELECT TOP 1 SC.intTicketId
								FROM tblSCTicket SC
								WHERE intTicketId = INVSHIPITEM.intSourceId
							  )
					    END 
		
		,strTicketNumber =  CASE 
								WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 SC.strTicketNumber
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
									  )
							ELSE (
									SELECT TOP 1 SC.strTicketNumber
									FROM tblSCTicket SC
									WHERE intTicketId = INVSHIPITEM.intSourceId
								  )
							END 
		
		,strShipmentNumber = INVSHIP.strShipmentNumber
		,0
		,intContractDetailId=ISNULL(INVDTL.intContractDetailId, 0)
		,RecordId = INV.strInvoiceNumber 
		,strSourceType = CASE 
							WHEN INVSHIP.intSourceType = 4 THEN 'Settle Storage'
							WHEN INVSHIP.intSourceType = 3 THEN 'Transport'
							WHEN INVSHIP.intSourceType = 2 THEN 'Inboud Shipment'
							WHEN INVSHIP.intSourceType = 1 THEN 'Scale'
							ELSE 'None'
						 END 
		,strSplitNumber = CASE 
								WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 EM.strSplitNumber
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId
											AND SC.intSplitId <> 0
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
										)
						  ELSE (
									SELECT TOP 1 EM.strSplitNumber
									FROM tblSCTicket SC
									JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId
										AND SC.intSplitId <> 0
									WHERE intTicketId = INVSHIPITEM.intSourceId
									)
						  END 
		,strCustomerReference = 
			CASE 
				WHEN INVSHIP.intSourceType = 4
					THEN (
							SELECT TOP 1 SC.strCustomerReference
							FROM tblGRCustomerStorage GR
							JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
							WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
							)
			ELSE (
					SELECT TOP 1 SC.strCustomerReference
					FROM tblSCTicket SC
					WHERE intTicketId = INVSHIPITEM.intSourceId
					)
			END 
		
		,strTicketComment = CASE 
							WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 SC.strTicketComment
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
										)
							ELSE (
									SELECT TOP 1 SC.strTicketComment
									FROM tblSCTicket SC
									WHERE intTicketId = INVSHIPITEM.intSourceId
									)
							END 
		,strFarmField= CASE 
						WHEN INVSHIP.intSourceType = 4
							THEN (
									SELECT strFarmNumber + '\' + strFieldNumber
									FROM tblEMEntityFarm
									WHERE intEntityId = VENDOR.[intEntityId]
										AND intFarmFieldId = (
											SELECT TOP 1 ISNULL(SC.intFarmFieldId, 0)
											FROM tblGRCustomerStorage GR
											JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
											WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
											)
									)
						ELSE (
								SELECT strFarmNumber + '\' + strFieldNumber
								FROM tblEMEntityFarm
								WHERE intEntityId = VENDOR.[intEntityId]
									AND intFarmFieldId = (
										SELECT TOP 1 ISNULL(SC.intFarmFieldId, 0)
										FROM tblSCTicket SC
										WHERE intTicketId = INVSHIPITEM.intSourceId
										)
								)
						END 
		
		,dtmDate = INV.dtmDate
		
		,dblGrossWeight = CASE 
								WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 ISNULL(SC.dblGrossWeight, 0)
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
										)
						  ELSE (
									SELECT TOP 1 ISNULL(SC.dblGrossWeight, 0)
									FROM tblSCTicket SC
									WHERE intTicketId = INVSHIPITEM.intSourceId
								)
						  END 
		
		,dblTareWeight = CASE 
							WHEN INVSHIP.intSourceType = 4
							THEN (
									SELECT TOP 1 ISNULL(SC.dblTareWeight, 0)
									FROM tblGRCustomerStorage GR
									JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
									WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
								 )
						ELSE (
								SELECT TOP 1 ISNULL(SC.dblTareWeight, 0)
								FROM tblSCTicket SC
								WHERE intTicketId = INVSHIPITEM.intSourceId
							 )
						END
		
		,dblNetWeight = CASE 
								WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
									 )
						ELSE (
									SELECT TOP 1 ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
									FROM tblSCTicket SC
									WHERE intTicketId = INVSHIPITEM.intSourceId
							 )
						END 
		
		,dblCost = INVDTL.dblPrice 
		,Net = INVDTL.dblQtyShipped
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = INVDTL.dblTotal
		,dblTotalTax = ISNULL((
								SELECT SUM(dblTotalTax)
								FROM tblARInvoiceDetail
								WHERE intInvoiceId = INVDTL.intInvoiceId
								), 0) 
		,strContractNumber = CNTRCT.strContractNumber
		,TotalDiscount = ISNULL((
									SELECT SUM(dblTotal)
									FROM tblARInvoiceDetail
									WHERE intInvoiceId = INVDTL.intInvoiceId
										AND intInventoryShipmentChargeId IS NOT NULL
									), 0) 
		,NetDue = (
					INVDTL.dblTotal + ISNULL((
												SELECT SUM(dblTotalTax)
												FROM tblARInvoiceDetail
												WHERE intInvoiceId = INVDTL.intInvoiceId
												), 0) + ISNULL((
																SELECT SUM(dblTotal)
																FROM tblARInvoiceDetail
																WHERE intInvoiceId = INVDTL.intInvoiceId
																	AND intInventoryShipmentChargeId IS NOT NULL
																), 0)
					) 
		,strId = INV.strInvoiceNumber
		,intPaymentId = PYMT.intPaymentId
		,
		--Settlement Total
		 InboundNetWeight = 0 
		
		,OutboundNetWeight = CASE 
								WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 0
								ELSE INVDTL.dblQtyShipped
							 END 
		
		,InboundGrossDollars = 0 
		
		,OutboundGrossDollars = CASE 
									WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 0
									ELSE INVDTL.dblTotal
								END 
		
		,InboundTax = 0 
		
		,OutboundTax = CASE 
							WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 0
							ELSE INVDTL.dblTotalTax
						END 
		
		,InboundDiscount = 0 
		
		,OutboundDiscount = ISNULL((
									SELECT SUM(dblTotal)
									FROM tblARInvoiceDetail
									WHERE intInvoiceId = INVDTL.intInvoiceId
										AND intInventoryShipmentChargeId IS NOT NULL
									), 0) 
		
		,InboundNetDue = 0 
		
		,OutboundNetDue = CASE 
								WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 0
						  ELSE (
									INVDTL.dblTotal + INVDTL.dblTotalTax + ISNULL((
																					SELECT SUM(dblTotal)
																					FROM tblARInvoiceDetail
																					WHERE intInvoiceId = INVDTL.intInvoiceId
																						AND intInventoryShipmentChargeId IS NOT NULL
																					), 0)
							   )
						  END 
		,VoucherAdjustment = 0 
		,SalesAdjustment = ISNULL((
									SELECT dblTotal
									FROM tblARInvoiceDetail
									WHERE intInvoiceDetailId = INVDTL.intInvoiceDetailId
										AND (
											intInventoryShipmentItemId IS NULL
											AND intInventoryShipmentChargeId IS NULL
											)
									), 0) 
		,CheckAmount = PYMT.dblAmountPaid 
		,IsAdjustment = CASE 
							WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 'True'
							ELSE 'False'
						END
       
	   ,dblGradeFactorTax = NULL
	   ,lblFactorTax = NULL
	   ,dblVendorPrepayment = NULL
	   ,lblVendorPrepayment = NULL
	   ,dblCustomerPrepayment = NULL
	   ,lblCustomerPrepayment = NULL
	   						 
	FROM tblCMBankTransaction BNKTRN
	JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON BNKTRN.strTransactionId = PRINTSPOOL.strTransactionId AND BNKTRN.intBankAccountId = PRINTSPOOL.intBankAccountId
	JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
	JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	JOIN tblARInvoice INV ON PYMTDTL.intInvoiceId = INV.intInvoiceId
	JOIN tblARInvoiceDetail INVDTL ON INV.intInvoiceId = INVDTL.intInvoiceId AND INVDTL.intInventoryShipmentChargeId IS NULL
	JOIN tblICItem Item ON INVDTL.intItemId = Item.intItemId
	LEFT JOIN tblICInventoryShipmentItem INVSHIPITEM ON INVDTL.intInventoryShipmentItemId = INVSHIPITEM.intInventoryShipmentItemId
	LEFT JOIN tblICInventoryShipment INVSHIP ON INVSHIPITEM.intInventoryShipmentId = INVSHIP.intInventoryShipmentId
	LEFT JOIN tblCTContractHeader CNTRCT ON INVDTL.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (
																		 SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup
																		)
	LEFT JOIN tblICItemUOM ItemUOM ON INVDTL.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE BNKTRN.intBankAccountId = @intBankAccountId 
	*/
	--------------------------------------------------------
	-- FROM SETTLE STORAGE
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
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)
		,strItemNo = Item.strItemNo
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
		,strFarmField = EntityFarm.strFarmNumber + '\' + EntityFarm.strFieldNumber 
		,dtmDate = Bill.dtmDate
		,dblGrossWeight = ISNULL(SC.dblGrossWeight, 0) 		
		,dblTareWeight = ISNULL(SC.dblTareWeight, 0) 		
		,dblNetWeight= ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)		 
		,dblCost = BillDtl.dblCost
		,Net = BillDtl.dblQtyOrdered
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = BillDtl.dblTotal
		,dblTax = BillDtl.dblTax
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
	   ,dblCustomerPrepayment = NULL
	   ,lblCustomerPrepayment = NULL
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

	WHERE BNKTRN.intBankAccountId = @intBankAccountId
		AND BNKTRN.strTransactionId = @strTransactionId
		AND (
			intInventoryReceiptChargeId IS NOT NULL
			OR BillDtl.intInventoryReceiptItemId IS NOT NULL
			)
     /*
	--------------------------------------------------------
	-- FROM INVENTORY SHIPMENT
	--------------------------------------------------------
	
	UNION ALL
	
	SELECT 
		 intBankAccountId = BNKTRN.intBankAccountId
		,intTransactionId = BNKTRN.intTransactionId
		,strTransactionId = BNKTRN.strTransactionId
		,strCompanyName = COMPANY.strCompanyName
		,strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)
		,strItemNo = Item.strItemNo
		,strCommodity = (
							SELECT strCommodityCode
							FROM tblICCommodity
							WHERE intCommodityId = Item.intCommodityId
						 )
		,strDate = CONVERT(VARCHAR(10), GETDATE(), 110)
		,strTime = CONVERT(VARCHAR(8), GETDATE(), 108)
		,strAccountNumber = dbo.fnAESDecryptASym(EFT.strAccountNumber)
		,strReferenceNo = BNKTRN.strReferenceNo
		,strEntityName = ENTITY.strName
		,strVendorAddress = ''
		,dtmDeliveryDate=
						CASE 
							WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 SC.dtmTicketDateTime
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
										)
						ELSE (
									SELECT TOP 1 SC.dtmTicketDateTime
									FROM tblSCTicket SC
									WHERE intTicketId = INVSHIPITEM.intSourceId
									)
						 END 
		,intTicketId = 
						CASE 
							WHEN INVSHIP.intSourceType = 4
							THEN (
									SELECT TOP 1 SC.intTicketId
									FROM tblGRCustomerStorage GR
									JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
									WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
								 )
						ELSE (
								SELECT TOP 1 SC.intTicketId
								FROM tblSCTicket SC
								WHERE intTicketId = INVSHIPITEM.intSourceId
							 )
						END
		
		,strTicketNumber = 
							CASE 
								WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 SC.strTicketNumber
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
									 )
							ELSE (
									SELECT TOP 1 SC.strTicketNumber
									FROM tblSCTicket SC
									WHERE intTicketId = INVSHIPITEM.intSourceId
								 )
							END
		,strShipmentNumber = INVSHIP.strShipmentNumber
		,0
		,intContractDetailId = ISNULL(INVDTL.intContractDetailId, 0) 
		,RecordId= INV.strInvoiceNumber
		,strSourceType= CASE 
							WHEN INVSHIP.intSourceType = 4 THEN 'Settle Storage'
							WHEN INVSHIP.intSourceType = 3 THEN 'Transport'
							WHEN INVSHIP.intSourceType = 2 THEN 'Inboud Shipment'
							WHEN INVSHIP.intSourceType = 1 THEN 'Scale'
							ELSE 'None'
						END
		,strSplitNumber = CASE 
								WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 EM.strSplitNumber
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
									 )
							ELSE (
									SELECT TOP 1 EM.strSplitNumber
									FROM tblSCTicket SC
									JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0
									WHERE intTicketId = INVSHIPITEM.intSourceId
								  )
							END
		
		,strCustomerReference = CASE 
									WHEN INVSHIP.intSourceType = 4
									THEN (
											SELECT TOP 1 SC.strCustomerReference
											FROM tblGRCustomerStorage GR
											JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
											WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
										 )
								 ELSE (
										SELECT TOP 1 SC.strCustomerReference
										FROM tblSCTicket SC
										WHERE intTicketId = INVSHIPITEM.intSourceId
									 )
								 END 
		,strTicketComment = CASE 
								WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 SC.strTicketComment
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
									 )
							ELSE (
									SELECT TOP 1 SC.strTicketComment
									FROM tblSCTicket SC
									WHERE intTicketId = INVSHIPITEM.intSourceId
								 )
							END
		
		,strFarmField = CASE 
							WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT strFarmNumber + '\' + strFieldNumber
										FROM tblEMEntityFarm
										WHERE intEntityId = VENDOR.[intEntityId]
											AND intFarmFieldId = (
																	SELECT TOP 1 ISNULL(SC.intFarmFieldId, 0)
																	FROM tblGRCustomerStorage GR
																	JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
																	WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
																  )
										)
							ELSE (
									SELECT TOP 1 strFarmNumber + '\' + strFieldNumber
									FROM tblEMEntityFarm
									WHERE intEntityId = VENDOR.[intEntityId]
										AND intFarmFieldId = (
																SELECT TOP 1 ISNULL(SC.intFarmFieldId, 0)
																FROM tblSCTicket SC
																WHERE intTicketId = INVSHIPITEM.intSourceId
															  )
									)
							END
		,dtmDate= INV.dtmDate
		,dblGrossWeight = CASE 
								WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 ISNULL(SC.dblGrossWeight, 0)
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
										)
						  ELSE (
									SELECT TOP 1 ISNULL(SC.dblGrossWeight, 0)
									FROM tblSCTicket SC
									WHERE intTicketId = INVSHIPITEM.intSourceId
							   )
						  END
		
		,dblTareWeight= CASE 
							WHEN INVSHIP.intSourceType = 4
								THEN (
										SELECT TOP 1 ISNULL(SC.dblTareWeight, 0)
										FROM tblGRCustomerStorage GR
										JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
										WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
									 )
						 ELSE (
									SELECT TOP 1 ISNULL(SC.dblTareWeight, 0)
									FROM tblSCTicket SC
									WHERE intTicketId = INVSHIPITEM.intSourceId
							   )
						 END
		    
		,dblNetWeight = CASE 
							WHEN INVSHIP.intSourceType = 4
							THEN (
									SELECT TOP 1 ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
									FROM tblGRCustomerStorage GR
									JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
									WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
								  )
						ELSE (
								SELECT TOP 1 ISNULL(SC.dblGrossWeight, 0) - ISNULL(SC.dblTareWeight, 0)
								FROM tblSCTicket SC
								WHERE intTicketId = INVSHIPITEM.intSourceId
							  )
						END
		,dblCost = INVDTL.dblPrice
		,Net = INVDTL.dblQtyShipped
		,strUnitMeasure = UOM.strUnitMeasure
		,dblTotal = INVDTL.dblTotal
		,dblTotalTax = INVDTL.dblTotalTax
		,strContractNumber = CNTRCT.strContractNumber
		,TotalDiscount =ISNULL((
								SELECT SUM(dblTotal)
								FROM tblARInvoiceDetail
								WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL
								), 0)
		,NetDue = (
					INVDTL.dblTotal + INVDTL.dblTotalTax + ISNULL((
																	SELECT SUM(dblTotal)
																	FROM tblARInvoiceDetail
																	WHERE intInvoiceId = INVDTL.intInvoiceId
																		AND intInventoryShipmentChargeId IS NOT NULL
																	), 0)
				  ) 
		,strId = INV.strInvoiceNumber
		,intPaymentId = PYMT.intPaymentId
		,
		--Settlement Total
		InboundNetWeight = 0 
		,OutboundNetWeight=CASE 
								WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 0
								ELSE INVDTL.dblQtyShipped
						   END 
		,InboundGrossDollars = 0 
		,OutboundGrossDollars = CASE 
									WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 0
									ELSE INVDTL.dblTotal
								END 
		,InboundTax = 0 
		,OutboundTax =  CASE 
							WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 0
							ELSE INVDTL.dblTotalTax
						END
		,InboundDiscount = 0
		,OutboundDiscount = ISNULL((
									SELECT SUM(dblTotal)
									FROM tblARInvoiceDetail
									WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL
									), 0) 
		,InboundNetDue = 0 
		,OutboundNetDue = CASE 
								WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 0
						  ELSE (
									INVDTL.dblTotal + INVDTL.dblTotalTax + ISNULL((
																					SELECT SUM(dblTotal)
																					FROM tblARInvoiceDetail
																					WHERE intInvoiceId = INVDTL.intInvoiceId
																						AND intInventoryShipmentChargeId IS NOT NULL
																					), 0)
							   )
						  END
		,VoucherAdjustment = 0 
		,SalesAdjustment = ISNULL((
									SELECT dblTotal
									FROM tblARInvoiceDetail
									WHERE intInvoiceDetailId = INVDTL.intInvoiceDetailId
										AND (
											intInventoryShipmentItemId IS NULL
											AND intInventoryShipmentChargeId IS NULL
											)
									), 0)
		,CheckAmount = PYMT.dblAmountPaid
		,IsAdjustment = CASE 
							WHEN INVDTL.intInventoryShipmentItemId IS NULL AND INVDTL.intInventoryShipmentChargeId IS NULL THEN 'True'
							ELSE 'False'
						END
       ,dblGradeFactorTax = NULL
	   ,lblFactorTax = NULL
	   ,dblVendorPrepayment = NULL
	   ,lblVendorPrepayment = NULL
	   ,dblCustomerPrepayment = NULL
	   ,lblCustomerPrepayment = NULL

	FROM tblCMBankTransaction BNKTRN
	JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId = PYMT.strPaymentRecordNum
	JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	JOIN tblARInvoice INV ON PYMTDTL.intInvoiceId = INV.intInvoiceId
	JOIN tblARInvoiceDetail INVDTL ON INV.intInvoiceId = INVDTL.intInvoiceId AND INVDTL.intInventoryShipmentChargeId IS NULL
	JOIN tblICItem Item ON INVDTL.intItemId = Item.intItemId
	LEFT JOIN tblICInventoryShipmentItem INVSHIPITEM ON INVDTL.intInventoryShipmentItemId = INVSHIPITEM.intInventoryShipmentItemId
	LEFT JOIN tblICInventoryShipment INVSHIP ON INVSHIPITEM.intInventoryShipmentId = INVSHIP.intInventoryShipmentId
	LEFT JOIN tblCTContractHeader CNTRCT ON INVDTL.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (
																		SELECT TOP 1 intCompanySetupID
																		FROM tblSMCompanySetup
																		)
	LEFT JOIN tblICItemUOM ItemUOM ON INVDTL.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId	
	WHERE BNKTRN.intBankAccountId = @intBankAccountId
		AND BNKTRN.strTransactionId = @strTransactionId
	
	*/
	--------------------------------------------------------
	-- FROM SETTLE STORAGE
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
	   ,blbHeaderLogo = @companyLogo					    
	   ,lblCustomerPrepayment = NULL					    
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
	WHERE BNKTRN.intBankAccountId = @intBankAccountId AND BNKTRN.strTransactionId = @strTransactionId
END
