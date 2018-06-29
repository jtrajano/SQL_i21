CREATE VIEW [dbo].[vyuGRSettlementOutboundSubReport]
AS
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
															AND DS.intItemId = InvDtl.intItemId
										), 0)

			,dblGradeReading = ISNULL((
										SELECT dblGradeReading
										FROM tblQMTicketDiscount TD
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
											AND DS.intItemId = InvDtl.intItemId
										), 0)
			,InvDtl.dblTotal AS dblAmount
			,InvDtl.dblTotalTax AS dblTax
			,PYMTDTL.dblTotal AS Net
		FROM tblAPPayment PYMT
		JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
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

