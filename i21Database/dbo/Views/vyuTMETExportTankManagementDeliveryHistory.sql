CREATE VIEW [dbo].[vyuTMETExportTankManagementDeliveryHistory]  
AS 

SELECT 
	ISNULL(D.strEntityNo,'') CustomerNumber
	,REPLICATE('0',4-LEN(CAST(B.intSiteNumber  AS NVARCHAR(20)))) + CAST(B.intSiteNumber  AS NVARCHAR(20)) ConsumptionSiteNumber
	,ISNULL(A.strInvoiceNumber,'') InvoiceNumber
	,ISNULL(A.strBulkPlantNumber,'') LocationNumber
	,ISNULL(CONVERT(VARCHAR(10),A.dtmInvoiceDate, 101),'') InvoiceDate
	,ISNULL(A.strProductDelivered,'') Product
	,ISNULL(A.dblQuantityDelivered,0) Quantity
	,ISNULL(A.intDegreeDayOnDeliveryDate,0) DegreeDayOnDeliveryDate
	,ISNULL(A.dblGallonsInTankbeforeDelivery,0) GallonsBeforeDelivery
	,ISNULL(A.dblGallonsInTankAfterDelivery,0) GallonsAfterDelivery
	,ISNULL(A.dblEstimatedPercentBeforeDelivery,0) EstimatedPercentBeforeDelivery
	,ISNULL(A.dblActualPercentAfterDelivery,0) ActualPercentAfterDelivery
	,ISNULL(A.strSalesPersonID,'') DriverNumber
FROM tblTMDeliveryHistory A
INNER JOIN tblTMSite B
	ON A.intSiteID = B.intSiteID
INNER JOIN tblTMCustomer C	
	ON B.intCustomerID = C.intCustomerID
INNER JOIN (SELECT 
				Ent.strEntityNo
				,Ent.intEntityId
				,Cus.ysnActive
			FROM tblEMEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.[intEntityId]) D
	ON C.intCustomerNumber = D.intEntityId
UNION ALL
SELECT
	ISNULL(E.strEntityNo,'') CustomerNumber
	,REPLICATE('0',4-LEN(CAST(C.intSiteNumber  AS NVARCHAR(20)))) + CAST(C.intSiteNumber  AS NVARCHAR(20)) ConsumptionSiteNumber
	,ISNULL(A.strInvoiceNumber,'') InvoiceNumber
	,ISNULL(B.strBulkPlantNumber,'') LocationNumber
	,ISNULL(CONVERT(VARCHAR(10),B.dtmInvoiceDate, 101),'') InvoiceDate
	,ISNULL(A.strItemNumber,'') Product
	,ISNULL(A.dblQuantityDelivered,0) Quantity
	,ISNULL(B.intDegreeDayOnDeliveryDate,0) DegreeDayOnDeliveryDate
	,ISNULL(B.dblGallonsInTankbeforeDelivery,0) GallonsBeforeDelivery
	,ISNULL(B.dblGallonsInTankAfterDelivery,0) GallonsAfterDelivery
	,ISNULL(B.dblEstimatedPercentBeforeDelivery,0) EstimatedPercentBeforeDelivery
	,ISNULL(A.dblPercentAfterDelivery,0) ActualPercentAfterDelivery
	,ISNULL(B.strSalesPersonID,'') DriverNumber
FROM tblTMDeliveryHistoryDetail A
INNER JOIN tblTMDeliveryHistory B
	ON A.intDeliveryHistoryID =B.intDeliveryHistoryID
INNER JOIN tblTMSite C
	ON C.intSiteID = B.intSiteID
INNER JOIN tblTMCustomer D
	ON D.intCustomerID = C.intCustomerID
INNER JOIN (SELECT 
				Ent.strEntityNo
				,Ent.intEntityId
				,Cus.ysnActive
			FROM tblEMEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.[intEntityId]) E
	ON D.intCustomerNumber = E.intEntityId