CREATE FUNCTION [dbo].[fnGLGetRevalueTransactionType]()
RETURNS @tbl TABLE 
(
    strValue NVARCHAR(20) ,
    strDescription NVARCHAR(40)
)
AS
BEGIN

DECLARE @tblConfig TABLE
(
    ysnValue BIT NULL,
    intId INT 
)

INSERT INTO @tblConfig (ysnValue, intId)

SELECT ysnPurchasingRevalue,    1 FROM tblSMMultiCurrency UNION ALL
SELECT ysnSalesRevalue,         2 FROM tblSMMultiCurrency UNION ALL
SELECT ysnInventoryRevalue,     3 FROM tblSMMultiCurrency UNION ALL
SELECT ysnContractRevalue,      4 FROM tblSMMultiCurrency UNION ALL
SELECT ysnCashManagementRevalue,5 FROM tblSMMultiCurrency UNION ALL
SELECT ysnForwardRevalue,       6 FROM tblSMMultiCurrency UNION ALL
SELECT ysnInTransitRevalue,     7 FROM tblSMMultiCurrency UNION ALL
SELECT ysnSwapRevalue,          8 FROM tblSMMultiCurrency UNION ALL
SELECT ysnFixedAssetsRevalue,   9 FROM tblSMMultiCurrency UNION ALL
SELECT ysnGeneralLedgerRevalue, 10 
FROM tblSMMultiCurrency


INSERT INTO @tbl (strValue, strDescription)
SELECT A.strValue, A.strDescription
FROM (
    SELECT intId =1,    strValue ='AP'		        ,strDescription = 'Accounts Payables'    UNION ALL
    SELECT intId =2,    strValue ='AR'		        ,strDescription = 'Account Receivable'   UNION ALL
    SELECT intId =3,    strValue ='INV'	            ,strDescription = 'Inventory'            UNION ALL
    SELECT intId =4,    strValue ='CT'		        ,strDescription = 'Contract'             UNION ALL
    SELECT intId =5,    strValue ='CM'		        ,strDescription = 'Cash Management'      UNION ALL
    SELECT intId =6,    strValue ='CM Forwards'	    ,strDescription = 'Forwards'             UNION ALL
    SELECT intId =7,    strValue ='CM In-Transit'   ,strDescription = 'In-Transit'           UNION ALL
    SELECT intId =8,    strValue ='CM Swaps'		,strDescription = 'Swaps'                UNION ALL
    SELECT intId =9,    strValue ='FA'		        ,strDescription = 'Fixed Assets'         UNION ALL
    SELECT intId =10,   strValue ='GL'		        ,strDescription = 'General Ledger'       
) A
JOIN @tblConfig B ON A.intId = B.intId
WHERE ISNULL(B.ysnValue,0) = 1


RETURN
END
