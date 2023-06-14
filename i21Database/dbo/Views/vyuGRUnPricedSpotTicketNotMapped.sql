CREATE VIEW [dbo].[vyuGRUnPricedSpotTicketNotMapped]
AS
SELECT    
 intUnPricedId			 = S.intUnPricedId
,intUnPricedSpotTicketId = T.intUnPricedSpotTicketId
,intTicketId			 = T.intTicketId
,dtmTicketDateTime		 = V.dtmTicketDateTime
,strTicketNumber		 = V.strTicketNumber
,intEntityId			 = T.intEntityId
,strEntityName           = Entity.strName
,dblUnits				 = V.dblNetUnits
,intItemStockUomId		 = V.intItemUOMIdTo
,strItemStockUOM		 = UnitMeasure.strUnitMeasure
,intBillId				 = T.intBillId
,strBillId				 = Bill.strBillId
,intInvoiceId			 = T.intInvoiceId
,strInvoiceNumber		 = Invoice.strInvoiceNumber  
FROM tblGRUnPriced S
JOIN tblGRUnPricedSpotTicket T	  ON T.intUnPricedId			  = S.intUnPricedId
JOIN tblSCTicket V				  ON V.intTicketId				  = T.intTicketId
JOIN tblICItemUOM UOM			  ON UOM.intItemUOMId			  = V.intItemUOMIdTo
JOIN tblEMEntity Entity			  ON Entity.intEntityId			  = T.intEntityId
JOIN tblICUnitMeasure UnitMeasure ON UnitMeasure.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN tblAPBill Bill		  ON Bill.intBillId				  = T.intBillId
LEFT JOIN tblARInvoice Invoice	  ON Invoice.intInvoiceId		  = T.intInvoiceId
