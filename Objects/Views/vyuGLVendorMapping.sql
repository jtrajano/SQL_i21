CREATE VIEW dbo.[vyuGLVendorMapping]
AS
SELECT
AP.intEntityId
,GL.intVendorMappingId
,GL.strMapVendorName
 from tblAPVendor AP
JOIN tblGLVendorMappingDetail GL 
on GL.intEntityVendorId = AP.intEntityId