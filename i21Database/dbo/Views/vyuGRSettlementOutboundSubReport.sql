CREATE VIEW [dbo].[vyuGRSettlementOutboundSubReport]
AS

	-- We are using this view to directly insert table to an API Export table
	-- If there are changes in the view please update the insert in uspGRAPISettlementReportExport as well
SELECT intPaymentId
	,strDiscountCode
	,strDiscountCodeDescription
	,(SUM(WeightedAverageReading) / SUM(Net)) AS WeightedAverageReading
	,(SUM(WeightedAverageShrink) / SUM(Net)) AS WeightedAverageShrink
	,SUM(dblDiscountAmount) AS Discount
	,SUM(dblAmount) AS Amount
	,SUM(dblTax) AS Tax
FROM (
		 SELECT 
		 intPaymentId
		,strDiscountCode
		,strDiscountCodeDescription
		,Net
		,(Net * dblGradeReading) AS WeightedAverageReading
		,(Net * dblShrinkPercent) AS WeightedAverageShrink
		,dblDiscountAmount
		,dblAmount
		,dblTax
	FROM (
		SELECT --Discount Detail 
			 PYMT.intPaymentId
			,Inv.strInvoiceNumber AS strId
			,InvDtl.intInvoiceId
			,InvDtl.intItemId
			,Item.strShortName AS strDiscountCode
			,Item.strItemNo AS strDiscountCodeDescription
			,INVSHIPCHR.dblRate AS dblDiscountAmount
			,dblShrinkPercent = ISNULL((
										SELECT dblShrinkPercent
										FROM tblQMTicketDiscount TD
										LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
											on TD.intTicketDiscountId = QMII.intTicketDiscountId
										JOIN tblGRDiscountScheduleCode DS ON TD.intDiscountScheduleCodeId = DS.intDiscountScheduleCodeId
										WHERE TD.intTicketId =  CASE 
																	WHEN INVSHIP.intSourceType = 4 THEN (
																											SELECT TOP 1 SC.intTicketId
																											FROM tblGRCustomerStorage GR
																											JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
																											WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
																										)
																
																	ELSE								(
																										   SELECT TOP 1 SC.intTicketId
																										   FROM tblSCTicket SC
																										   WHERE intTicketId = INVSHIPITEM.intSourceId
																										 )
																END
															AND isnull(QMII.intItemId, DS.intItemId) = InvDtl.intItemId
										), 0)

			,dblGradeReading = ISNULL((
										SELECT dblGradeReading
										FROM tblQMTicketDiscount TD
										LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
											on TD.intTicketDiscountId = QMII.intTicketDiscountId
										JOIN tblGRDiscountScheduleCode DS ON TD.intDiscountScheduleCodeId = DS.intDiscountScheduleCodeId
										WHERE TD.intTicketId = CASE 
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
											AND isnull(QMII.intItemId, DS.intItemId) = InvDtl.intItemId
										), 0)
			,InvDtl.dblTotal AS dblAmount
			,InvDtl.dblTotalTax AS dblTax
			,PYMTDTL.dblTotal AS Net
		FROM tblAPPayment PYMT
		JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId				
					and PYMTDTL.dblPayment <> 0
		JOIN tblARInvoice Inv ON PYMTDTL.intInvoiceId = Inv.intInvoiceId
		JOIN tblARInvoiceDetail InvDtl ON InvDtl.intInvoiceId = Inv.intInvoiceId
		JOIN tblICInventoryShipmentCharge INVSHIPCHR ON InvDtl.intInventoryShipmentChargeId = INVSHIPCHR.intInventoryShipmentChargeId
		JOIN tblICItem Item ON InvDtl.intItemId = Item.intItemId
		JOIN tblICInventoryShipment INVSHIP ON INVSHIPCHR.intInventoryShipmentId = INVSHIP.intInventoryShipmentId
		JOIN tblICInventoryShipmentItem INVSHIPITEM ON INVSHIP.intInventoryShipmentId = INVSHIPITEM.intInventoryShipmentId
		--JOIN tblSCTicket TICKET ON INVSHIPITEM.intSourceId = TICKET.intTicketId 
		WHERE InvDtl.intInventoryShipmentChargeId IS NOT NULL
		) tbl
	) tbl
GROUP BY intPaymentId
	,strDiscountCode
	,strDiscountCodeDescription

