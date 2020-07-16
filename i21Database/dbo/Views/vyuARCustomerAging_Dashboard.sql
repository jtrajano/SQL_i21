CREATE VIEW vyuARCustomerAging_DashBoard
AS
SELECT  
TOP 5 
dblARBalance dblTotalDue, 
C.intEntityId intEntityCustomerId, 
E.strName strCustomerName 
FROM
tblARCustomer C JOIN
tblEMEntity E ON E.intEntityId = C.intEntityId
ORDER BY dblARBalance DESC