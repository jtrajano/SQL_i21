CREATE VIEW [dbo].[vyuTRQuoteSelection]
	AS 
select QT.intCustomerRackQuoteHeaderId,QT.intEntityCustomerLocationId,QT.intSupplyPointId,QT.intItemId,QT.intCategoryId,QT.intEntityCustomerId,QT.ysnQuote from
             (select QH.intCustomerRackQuoteHeaderId,QV.intEntityCustomerLocationId, QV.intSupplyPointId,QI.intItemId,IC.intCategoryId,QH.intEntityCustomerId,QV.ysnQuote
                     from tblARCustomerRackQuoteHeader QH            
                         left join tblARCustomerRackQuoteItem QI on QI.intCustomerRackQuoteHeaderId = QH.intCustomerRackQuoteHeaderId
                         left join tblARCustomerRackQuoteVendor QV on QV.intCustomerRackQuoteHeaderId = QH.intCustomerRackQuoteHeaderId
             			 join vyuICGetItemStock IC on IC.intItemId = QI.intItemId
             UNION ALL
             select  QH.intCustomerRackQuoteHeaderId,QV.intEntityCustomerLocationId,QV.intSupplyPointId,IC.intItemId,QC.intCategoryId,QH.intEntityCustomerId,QV.ysnQuote
                     from tblARCustomerRackQuoteHeader QH
                         left join tblARCustomerRackQuoteCategory QC on QH.intCustomerRackQuoteHeaderId = QC.intCustomerRackQuoteHeaderId
             			 left join tblARCustomerRackQuoteVendor QV on QV.intCustomerRackQuoteHeaderId = QH.intCustomerRackQuoteHeaderId
                         join vyuICGetItemStock IC on IC.intCategoryId = QC.intCategoryId) QT
group by QT.intCustomerRackQuoteHeaderId,QT.intEntityCustomerLocationId,QT.intSupplyPointId,QT.intItemId,QT.intCategoryId,QT.intEntityCustomerId,QT.ysnQuote

