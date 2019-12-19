CREATE FUNCTION fnAPGetCheckPayee(@strPaymentRecordNum NVARCHAR(50), @dtmDate DATETIME , @intEntityVendorId INT, @intPayToAddressId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
DECLARE @checkPayee nvarchar(max)


select @checkPayee = ISNULL(
 STUFF( (SELECT DISTINCT ' and ' + strName
                        FROM tblAPVendorLien LIEN
						INNER JOIN tblEMEntity ENT ON LIEN.intEntityLienId = ENT.intEntityId
						WHERE LIEN.intEntityVendorId = @intEntityVendorId AND LIEN.ysnActive = 1 AND @dtmDate BETWEEN LIEN.dtmStartDate AND LIEN.dtmEndDate
						AND LIEN.intCommodityId IN (SELECT intCommodityId FROM
													tblAPPayment Pay 
													INNER JOIN tblAPPaymentDetail PayDtl ON Pay.intPaymentId = PayDtl.intPaymentId
													INNER JOIN vyuAPVoucherCommodity VC ON PayDtl.intBillId = VC.intBillId
													WHERE strPaymentRecordNum = @strPaymentRecordNum)
                        --ORDER BY intEntityVendorLienId
                        FOR XML PATH('')), 
                    1, 1, ''),'')


SELECT TOP 1 @checkPayee  = strCheckPayeeName + ' '  +   @checkPayee + CHAR(13) +  CHAR(10)+ +  ISNULL(dbo.fnConvertToFullAddress(A.strAddress, A.strCity, A.strState, A.strZipCode),'')
FROM tblEMEntityLocation A join
tblAPPayment B ON A.intEntityLocationId = B.intPayToAddressId
WHERE strPaymentRecordNum = @strPaymentRecordNum

RETURN @checkPayee
END
